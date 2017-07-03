package File::Path;

use 5.005_04;
use strict;

use Cwd 'getcwd';
use File::Basename ();
use File::Spec     ();

BEGIN {
    if ($] < 5.006) {
        # can't say 'opendir my $dh, $dirname'
        # need to initialise $dh
        eval "use Symbol";
    }
}

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
$VERSION   = '2.09';
@ISA       = qw(Exporter);
@EXPORT    = qw(mkpath rmtree);
@EXPORT_OK = qw(make_path remove_tree);

my $Is_VMS     = $^O eq 'VMS';
my $Is_MacOS   = $^O eq 'MacOS';

# These OSes complain if you want to remove a file that you have no
# write permission to:
my $Force_Writeable = grep {$^O eq $_} qw(amigaos dos epoc MSWin32 MacOS os2);

# Unix-like systems need to stat each directory in order to detect
# race condition. MS-Windows is immune to this particular attack.
my $Need_Stat_Check = !($^O eq 'MSWin32');

sub _carp {
    require Carp;
    goto &Carp::carp;
}

sub _croak {
    require Carp;
    goto &Carp::croak;
}

sub _error {
    my $arg     = shift;
    my $message = shift;
    my $object  = shift;

    if ($arg->{error}) {
        $object = '' unless defined $object;
        $message .= ": $!" if $!;
        push @{${$arg->{error}}}, {$object => $message};
    }
    else {
        _carp(defined($object) ? "$message for $object: $!" : "$message: $!");
    }
}

sub make_path {
    push @_, {} unless @_ and UNIVERSAL::isa($_[-1],'HASH');
    goto &mkpath;
}

sub mkpath {
    my $old_style = !(@_ and UNIVERSAL::isa($_[-1],'HASH'));

    my $arg;
    my $paths;

    if ($old_style) {
        my ($verbose, $mode);
        ($paths, $verbose, $mode) = @_;
        $paths = [$paths] unless UNIVERSAL::isa($paths,'ARRAY');
        $arg->{verbose} = $verbose;
        $arg->{mode}    = defined $mode ? $mode : 0777;
    }
    else {
        $arg = pop @_;
        $arg->{mode}      = delete $arg->{mask} if exists $arg->{mask};
        $arg->{mode}      = 0777 unless exists $arg->{mode};
        ${$arg->{error}}  = [] if exists $arg->{error};
        $arg->{owner}     = delete $arg->{user} if exists $arg->{user};
        $arg->{owner}     = delete $arg->{uid}  if exists $arg->{uid};
        if (exists $arg->{owner} and $arg->{owner} =~ /\D/) {
            my $uid = (getpwnam $arg->{owner})[2];
            if (defined $uid) {
                $arg->{owner} = $uid;
            }
            else {
                _error($arg, "unable to map $arg->{owner} to a uid, ownership not changed");
                delete $arg->{owner};
            }
        }
        if (exists $arg->{group} and $arg->{group} =~ /\D/) {
            my $gid = (getgrnam $arg->{group})[2];
            if (defined $gid) {
                $arg->{group} = $gid;
            }
            else {
                _error($arg, "unable to map $arg->{group} to a gid, group ownership not changed");
                delete $arg->{group};
            }
        }
        if (exists $arg->{owner} and not exists $arg->{group}) {
            $arg->{group} = -1; # chown will leave group unchanged
        }
        if (exists $arg->{group} and not exists $arg->{owner}) {
            $arg->{owner} = -1; # chown will leave owner unchanged
        }
        $paths = [@_];
    }
    return _mkpath($arg, $paths);
}

sub _mkpath {
    my $arg   = shift;
    my $paths = shift;

    my(@created,$path);
    foreach $path (@$paths) {
        next unless defined($path) and length($path);
        $path .= '/' if $^O eq 'os2' and $path =~ /^\w:\z/s; # feature of CRT 
        # Logic wants Unix paths, so go with the flow.
        if ($Is_VMS) {
            next if $path eq '/';
            $path = VMS::Filespec::unixify($path);
        }
        next if -d $path;
        my $parent = File::Basename::dirname($path);
        unless (-d $parent or $path eq $parent) {
            push(@created,_mkpath($arg, [$parent]));
        }
        print "mkdir $path\n" if $arg->{verbose};
        if (mkdir($path,$arg->{mode})) {
            push(@created, $path);
            if (exists $arg->{owner}) {
				# NB: $arg->{group} guaranteed to be set during initialisation
                if (!chown $arg->{owner}, $arg->{group}, $path) {
                    _error($arg, "Cannot change ownership of $path to $arg->{owner}:$arg->{group}");
                }
            }
        }
        else {
            my $save_bang = $!;
            my ($e, $e1) = ($save_bang, $^E);
            $e .= "; $e1" if $e ne $e1;
            # allow for another process to have created it meanwhile
            if (!-d $path) {
                $! = $save_bang;
                if ($arg->{error}) {
                    push @{${$arg->{error}}}, {$path => $e};
                }
                else {
                    _croak("mkdir $path: $e");
                }
            }
        }
    }
    return @created;
}

sub remove_tree {
    push @_, {} unless @_ and UNIVERSAL::isa($_[-1],'HASH');
    goto &rmtree;
}

sub _is_subdir {
    my($dir, $test) = @_;

    my($dv, $dd) = File::Spec->splitpath($dir, 1);
    my($tv, $td) = File::Spec->splitpath($test, 1);

    # not on same volume
    return 0 if $dv ne $tv;

    my @d = File::Spec->splitdir($dd);
    my @t = File::Spec->splitdir($td);

    # @t can't be a subdir if it's shorter than @d
    return 0 if @t < @d;

    return join('/', @d) eq join('/', splice @t, 0, +@d);
}

sub rmtree {
    my $old_style = !(@_ and UNIVERSAL::isa($_[-1],'HASH'));

    my $arg;
    my $paths;

    if ($old_style) {
        my ($verbose, $safe);
        ($paths, $verbose, $safe) = @_;
        $arg->{verbose} = $verbose;
        $arg->{safe}    = defined $safe    ? $safe    : 0;

        if (defined($paths) and length($paths)) {
            $paths = [$paths] unless UNIVERSAL::isa($paths,'ARRAY');
        }
        else {
            _carp ("No root path(s) specified\n");
            return 0;
        }
    }
    else {
        $arg = pop @_;
        ${$arg->{error}}  = [] if exists $arg->{error};
        ${$arg->{result}} = [] if exists $arg->{result};
        $paths = [@_];
    }

    $arg->{prefix} = '';
    $arg->{depth}  = 0;

    my @clean_path;
    $arg->{cwd} = getcwd() or do {
        _error($arg, "cannot fetch initial working directory");
        return 0;
    };
    for ($arg->{cwd}) { /\A(.*)\Z/; $_ = $1 } # untaint

    for my $p (@$paths) {
        # need to fixup case and map \ to / on Windows
        my $ortho_root = $^O eq 'MSWin32' ? _slash_lc($p)          : $p;
        my $ortho_cwd  = $^O eq 'MSWin32' ? _slash_lc($arg->{cwd}) : $arg->{cwd};
        my $ortho_root_length = length($ortho_root);
        $ortho_root_length-- if $^O eq 'VMS'; # don't compare '.' with ']'
        if ($ortho_root_length && _is_subdir($ortho_root, $ortho_cwd)) {
            local $! = 0;
            _error($arg, "cannot remove path when cwd is $arg->{cwd}", $p);
            next;
        }

        if ($Is_MacOS) {
            $p  = ":$p" unless $p =~ /:/;
            $p .= ":"   unless $p =~ /:\z/;
        }
        elsif ($^O eq 'MSWin32') {
            $p =~ s{[/\\]\z}{};
        }
        else {
            $p =~ s{/\z}{};
        }
        push @clean_path, $p;
    }

    @{$arg}{qw(device inode perm)} = (lstat $arg->{cwd})[0,1] or do {
        _error($arg, "cannot stat initial working directory", $arg->{cwd});
        return 0;
    };

    return _rmtree($arg, \@clean_path);
}

sub _rmtree {
    my $arg   = shift;
    my $paths = shift;

    my $count  = 0;
    my $curdir = File::Spec->curdir();
    my $updir  = File::Spec->updir();

    my (@files, $root);
    ROOT_DIR:
    foreach $root (@$paths) {
        # since we chdir into each directory, it may not be obvious
        # to figure out where we are if we generate a message about
        # a file name. We therefore construct a semi-canonical
        # filename, anchored from the directory being unlinked (as
        # opposed to being truly canonical, anchored from the root (/).

        my $canon = $arg->{prefix}
            ? File::Spec->catfile($arg->{prefix}, $root)
            : $root
        ;

        my ($ldev, $lino, $perm) = (lstat $root)[0,1,2] or next ROOT_DIR;

        if ( -d _ ) {
            $root = VMS::Filespec::vmspath(VMS::Filespec::pathify($root)) if $Is_VMS;

            if (!chdir($root)) {
                # see if we can escalate privileges to get in
                # (e.g. funny protection mask such as -w- instead of rwx)
                $perm &= 07777;
                my $nperm = $perm | 0700;
                if (!($arg->{safe} or $nperm == $perm or chmod($nperm, $root))) {
                    _error($arg, "cannot make child directory read-write-exec", $canon);
                    next ROOT_DIR;
                }
                elsif (!chdir($root)) {
                    _error($arg, "cannot chdir to child", $canon);
                    next ROOT_DIR;
                }
            }

            my ($cur_dev, $cur_inode, $perm) = (stat $curdir)[0,1,2] or do {
                _error($arg, "cannot stat current working directory", $canon);
                next ROOT_DIR;
            };

            if ($Need_Stat_Check) {
                ($ldev eq $cur_dev and $lino eq $cur_inode)
                    or _croak("directory $canon changed before chdir, expected dev=$ldev ino=$lino, actual dev=$cur_dev ino=$cur_inode, aborting.");
            }

            $perm &= 07777; # don't forget setuid, setgid, sticky bits
            my $nperm = $perm | 0700;

            # notabene: 0700 is for making readable in the first place,
            # it's also intended to change it to writable in case we have
            # to recurse in which case we are better than rm -rf for 
            # subtrees with strange permissions

            if (!($arg->{safe} or $nperm == $perm or chmod($nperm, $curdir))) {
                _error($arg, "cannot make directory read+writeable", $canon);
                $nperm = $perm;
            }

            my $d;
            $d = gensym() if $] < 5.006;
            if (!opendir $d, $curdir) {
                _error($arg, "cannot opendir", $canon);
                @files = ();
            }
            else {
                no strict 'refs';
                if (!defined ${"\cTAINT"} or ${"\cTAINT"}) {
                    # Blindly untaint dir names if taint mode is
                    # active, or any perl < 5.006
                    @files = map { /\A(.*)\z/s; $1 } readdir $d;
                }
                else {
                    @files = readdir $d;
                }
                closedir $d;
            }

            if ($Is_VMS) {
                # Deleting large numbers of files from VMS Files-11
                # filesystems is faster if done in reverse ASCIIbetical order.
                # include '.' to '.;' from blead patch #31775
                @files = map {$_ eq '.' ? '.;' : $_} reverse @files;
            }

            @files = grep {$_ ne $updir and $_ ne $curdir} @files;

            if (@files) {
                # remove the contained files before the directory itself
                my $narg = {%$arg};
                @{$narg}{qw(device inode cwd prefix depth)}
                    = ($cur_dev, $cur_inode, $updir, $canon, $arg->{depth}+1);
                $count += _rmtree($narg, \@files);
            }

            # restore directory permissions of required now (in case the rmdir
            # below fails), while we are still in the directory and may do so
            # without a race via '.'
            if ($nperm != $perm and not chmod($perm, $curdir)) {
                _error($arg, "cannot reset chmod", $canon);
            }

            # don't leave the client code in an unexpected directory
            chdir($arg->{cwd})
                or _croak("cannot chdir to $arg->{cwd} from $canon: $!, aborting.");

            # ensure that a chdir upwards didn't take us somewhere other
            # than we expected (see CVE-2002-0435)
            ($cur_dev, $cur_inode) = (stat $curdir)[0,1]
                or _croak("cannot stat prior working directory $arg->{cwd}: $!, aborting.");

            if ($Need_Stat_Check) {
                ($arg->{device} eq $cur_dev and $arg->{inode} eq $cur_inode)
                    or _croak("previous directory $arg->{cwd} changed before entering $canon, expected dev=$ldev ino=$lino, actual dev=$cur_dev ino=$cur_inode, aborting.");
            }

            if ($arg->{depth} or !$arg->{keep_root}) {
                if ($arg->{safe} &&
                    ($Is_VMS ? !&VMS::Filespec::candelete($root) : !-w $root)) {
                    print "skipped $root\n" if $arg->{verbose};
                    next ROOT_DIR;
                }
                if ($Force_Writeable and !chmod $perm | 0700, $root) {
                    _error($arg, "cannot make directory writeable", $canon);
                }
                print "rmdir $root\n" if $arg->{verbose};
                if (rmdir $root) {
                    push @{${$arg->{result}}}, $root if $arg->{result};
                    ++$count;
                }
                else {
                    _error($arg, "cannot remove directory", $canon);
                    if ($Force_Writeable && !chmod($perm, ($Is_VMS ? VMS::Filespec::fileify($root) : $root))
                    ) {
                        _error($arg, sprintf("cannot restore permissions to 0%o",$perm), $canon);
                    }
                }
            }
        }
        else {
            # not a directory
            $root = VMS::Filespec::vmsify("./$root")
                if $Is_VMS
                   && !File::Spec->file_name_is_absolute($root)
                   && ($root !~ m/(?<!\^)[\]>]+/);  # not already in VMS syntax

            if ($arg->{safe} &&
                ($Is_VMS ? !&VMS::Filespec::candelete($root)
                         : !(-l $root || -w $root)))
            {
                print "skipped $root\n" if $arg->{verbose};
                next ROOT_DIR;
            }

            my $nperm = $perm & 07777 | 0600;
            if ($Force_Writeable and $nperm != $perm and not chmod $nperm, $root) {
                _error($arg, "cannot make file writeable", $canon);
            }
            print "unlink $canon\n" if $arg->{verbose};
            # delete all versions under VMS
            for (;;) {
                if (unlink $root) {
                    push @{${$arg->{result}}}, $root if $arg->{result};
                }
                else {
                    _error($arg, "cannot unlink file", $canon);
                    $Force_Writeable and chmod($perm, $root) or
                        _error($arg, sprintf("cannot restore permissions to 0%o",$perm), $canon);
                    last;
                }
                ++$count;
                last unless $Is_VMS && lstat $root;
            }
        }
    }
    return $count;
}

sub _slash_lc {
    # fix up slashes and case on MSWin32 so that we can determine that
    # c:\path\to\dir is underneath C:/Path/To
    my $path = shift;
    $path =~ tr{\\}{/};
    return lc($path);
}

1;
__END__

