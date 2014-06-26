package Anothark::ResultEffectManager;
#
# 愛
#
$|=1;
use strict;

use Anothark::BaseLoader;
use DBI qw( SQL_INTEGER );
use base qw( Anothark::BaseLoader );
sub new
{
    my $class   = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;


    return $self;
}



1;
