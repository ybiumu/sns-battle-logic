package Anothark::BaseLoader;
#
# 愛
#
$|=1;
use strict;

=pod
 xxxLoader, xxxManager 系の基底クラス
 基本的なdbアクセス機能を有する
=cut

use LoggingObjMethod;
use base qw( LoggingObjMethod );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setDbHandler($db_handle);

    return $self;
}


my $db_handler = undef;
my $sth_skill = undef;
my $sth_child = undef;


sub setSthSkill
{
    my $class = shift;
    return $class->setAttribute( 'sth_skill', shift );
}

sub getSthSkill
{
    return $_[0]->getAttribute( 'sth_skill' );
}

sub setSthChild
{
    my $class = shift;
    return $class->setAttribute( 'sth_child', shift );
}

sub getSthChild
{
    return $_[0]->getAttribute( 'sth_child' );
}



sub setDbHandler
{
    my $class = shift;
    return $class->setAttribute( 'db_handler', shift );
}

sub getDbHandler
{
    return $_[0]->getAttribute( 'db_handler' );
}


sub finish
{
    my $class = shift;
    $class->getSthSkill()->finish();
    $class->getSthChild()->finish();
}



1;
