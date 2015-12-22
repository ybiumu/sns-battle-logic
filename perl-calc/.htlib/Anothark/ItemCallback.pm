package Anothark::ItemCallback;
#
# 愛
#
$|=1;
use strict;


use LoggingObjMethod;
use base qw( LoggingObjMethod );


#
# At を受け取って、テンプレートを設定して、リプレイスも設定する？
# ステータスの保存はAtからStatsIO獲得？
#
#
# 1. 使用するとステータス変更
# 2. 使用すると入力画面表示
#   2-1. 入力すると確認画面表示
#   2-2. コミットすると変更、キャンセルすると使用しない
#
#
#

sub new
{
    my $class = shift;
    my $at    = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

    $self->setAt($at);
    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
}



my $at = undef;
sub setAt
{
    my $class = shift;
    return $class->setAttribute( 'at', shift );
}

sub getAt
{
    return $_[0]->getAttribute( 'at' );
}

my $self_name = undef;
my $base_page = undef;
sub setSelfName
{
    my $class = shift;
    return $class->setAttribute( 'self_name', shift );
}

sub getSelfName
{
    return $_[0]->getAttribute( 'self_name' );
}


sub setBasePage
{
    my $class = shift;
    return $class->setAttribute( 'base_page', shift );
}

sub getBasePage
{
    return $_[0]->getAttribute( 'base_page' );
}


sub using
{
}

sub confirm
{
}

sub commit
{
}

sub cancel
{
}


1;
