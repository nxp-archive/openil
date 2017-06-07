

package Debconf::FrontEnd::Kde::Ui_DebconfWizard;

use strict;
use warnings;

use QtCore4;
use QtGui4;

sub vboxLayout {
    return shift->{vboxLayout};
}

sub title {
    return shift->{title};
}

sub line1 {
    return shift->{line1};
}

sub mainFrame {
    return shift->{mainFrame};
}

sub hboxLayout {
    return shift->{hboxLayout};
}

sub bHelp {
    return shift->{bHelp};
}

sub spacer1 {
    return shift->{spacer1};
}

sub bBack {
    return shift->{bBack};
}

sub bNext {
    return shift->{bNext};
}

sub bCancel {
    return shift->{bCancel};
}


sub setupUi {
    my ( $class, $debconfWizard ) = @_;
    my $self = bless {}, $class;
    if ( !defined $debconfWizard->objectName() ) {
        $debconfWizard->setObjectName( "debconfWizard" );
    }
    $debconfWizard->resize( 660, 460 );
    my $vboxLayout = Qt::VBoxLayout( $debconfWizard );
    $self->{vboxLayout} = $vboxLayout;
    $vboxLayout->setSpacing( 6 );
    $vboxLayout->setMargin( 11 );
    $vboxLayout->setObjectName( "vboxLayout" );
    my $title = Qt::Label( $debconfWizard );
    $self->{title} = $title;
    $title->setObjectName( "title" );
    my $sizePolicy = Qt::SizePolicy( Qt::SizePolicy::Preferred(), Qt::SizePolicy::Fixed() );
    $self->{$sizePolicy} = $sizePolicy;
    $sizePolicy->setHorizontalStretch( 0 );
    $sizePolicy->setVerticalStretch( 0 );
    $sizePolicy->setHeightForWidth( $title->sizePolicy()->hasHeightForWidth() );
    $title->setSizePolicy( $sizePolicy );
    $title->setWordWrap( 0 );

    $vboxLayout->addWidget( $title );

    my $line1 = Qt::Frame( $debconfWizard );
    $self->{line1} = $line1;
    $line1->setObjectName( "line1" );
    $sizePolicy->setHeightForWidth( $line1->sizePolicy()->hasHeightForWidth() );
    $line1->setSizePolicy( $sizePolicy );
    $line1->setFrameShape( Qt::Frame::HLine() );
    $line1->setFrameShadow( Qt::Frame::Sunken() );

    $vboxLayout->addWidget( $line1 );

    my $mainFrame = Qt::Widget( $debconfWizard );
    $self->{mainFrame} = $mainFrame;
    $mainFrame->setObjectName( "mainFrame" );

    $vboxLayout->addWidget( $mainFrame );

    my $hboxLayout = Qt::HBoxLayout(  );
    $self->{hboxLayout} = $hboxLayout;
    $hboxLayout->setSpacing( 6 );
    $hboxLayout->setObjectName( "hboxLayout" );
    my $bHelp = Qt::PushButton( $debconfWizard );
    $self->{bHelp} = $bHelp;
    $bHelp->setObjectName( "bHelp" );

    $hboxLayout->addWidget( $bHelp );

    my $spacer1 = Qt::SpacerItem( 161, 20, Qt::SizePolicy::Expanding(), Qt::SizePolicy::Minimum() );

    $hboxLayout->addItem( $spacer1 );

    my $bBack = Qt::PushButton( $debconfWizard );
    $self->{bBack} = $bBack;
    $bBack->setObjectName( "bBack" );

    $hboxLayout->addWidget( $bBack );

    my $bNext = Qt::PushButton( $debconfWizard );
    $self->{bNext} = $bNext;
    $bNext->setObjectName( "bNext" );

    $hboxLayout->addWidget( $bNext );

    my $bCancel = Qt::PushButton( $debconfWizard );
    $self->{bCancel} = $bCancel;
    $bCancel->setObjectName( "bCancel" );

    $hboxLayout->addWidget( $bCancel );


    $vboxLayout->addLayout( $hboxLayout );


    $self->retranslateUi( $debconfWizard );

    Qt::MetaObject::connectSlotsByName( $debconfWizard );
    return $self;
} # setupUi

sub setup_ui {
    my ( $debconfWizard ) = @_;
    return setupUi( $debconfWizard );
}

sub retranslateUi {
    my ( $self, $debconfWizard ) = @_;
    $debconfWizard->setWindowTitle( Qt::Application::translate( 'DebconfWizard', "Debconf", undef, Qt::Application::UnicodeUTF8() ) );
    $self->{title}->setText( Qt::Application::translate( 'DebconfWizard', "title", undef, Qt::Application::UnicodeUTF8() ) );
    $self->{bHelp}->setText( Qt::Application::translate( 'DebconfWizard', "Help", undef, Qt::Application::UnicodeUTF8() ) );
    $self->{bBack}->setText( Qt::Application::translate( 'DebconfWizard', "< Back", undef, Qt::Application::UnicodeUTF8() ) );
    $self->{bNext}->setText( Qt::Application::translate( 'DebconfWizard', "Next >", undef, Qt::Application::UnicodeUTF8() ) );
    $self->{bCancel}->setText( Qt::Application::translate( 'DebconfWizard', "Cancel", undef, Qt::Application::UnicodeUTF8() ) );
} # retranslateUi

sub retranslate_ui {
    my ( $debconfWizard ) = @_;
    retranslateUi( $debconfWizard );
}

1;