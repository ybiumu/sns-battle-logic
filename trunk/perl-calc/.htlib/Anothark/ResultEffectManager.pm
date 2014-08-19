package Anothark::ResultEffectManager;
#
# 愛
#
#
=pod
t_result_effectの管理クラス
result_effect自体はリザルト時に発生する「取得」「損失」等を制御する機構
=cut
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
