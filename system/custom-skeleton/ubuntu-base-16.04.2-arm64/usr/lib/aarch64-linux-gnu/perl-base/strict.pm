package strict;

$strict::VERSION = "1.09";

# Verify that we're called correctly so that strictures will work.
unless ( __FILE__ =~ /(^|[\/\\])\Q${\__PACKAGE__}\E\.pmc?$/ ) {
    # Can't use Carp, since Carp uses us!
    my (undef, $f, $l) = caller;
    die("Incorrect use of pragma '${\__PACKAGE__}' at $f line $l.\n");
}

my ( %bitmask, %explicit_bitmask );

BEGIN {
    %bitmask = (
        refs => 0x00000002,
        subs => 0x00000200,
        vars => 0x00000400,
    );

    %explicit_bitmask = (
        refs => 0x00000020,
        subs => 0x00000040,
        vars => 0x00000080,
    );

    my $bits = 0;
    $bits |= $_ for values %bitmask;

    my $inline_all_bits = $bits;
    *all_bits = sub () { $inline_all_bits };

    $bits = 0;
    $bits |= $_ for values %explicit_bitmask;

    my $inline_all_explicit_bits = $bits;
    *all_explicit_bits = sub () { $inline_all_explicit_bits };
}

sub bits {
    my $bits = 0;
    my @wrong;
    foreach my $s (@_) {
        if (exists $bitmask{$s}) {
            $^H |= $explicit_bitmask{$s};

            $bits |= $bitmask{$s};
        }
        else {
            push @wrong, $s;
        }
    }
    if (@wrong) {
        require Carp;
        Carp::croak("Unknown 'strict' tag(s) '@wrong'");
    }
    $bits;
}

sub import {
    shift;
    $^H |= @_ ? &bits : all_bits | all_explicit_bits;
}

sub unimport {
    shift;

    if (@_) {
        $^H &= ~&bits;
    }
    else {
        $^H &= ~all_bits;
        $^H |= all_explicit_bits;
    }
}

1;
__END__

