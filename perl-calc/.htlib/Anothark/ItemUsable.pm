package Anothark::ItemUsable;
#
# ˆ¤
#
$|=1;
use strict;


use LoggingObjMethod;
use base qw( LoggingObjMethod );


use constant USABLE => {
    ""   => 0,
    "0"  => 0,
};

use constant CALLBACK => {
    "" => 0,
};




sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
}


1;
