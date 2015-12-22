package Anothark::ItemCallback;
#
# ��
#
$|=1;
use strict;


use LoggingObjMethod;
use base qw( LoggingObjMethod );


#
# At ���󂯎���āA�e���v���[�g��ݒ肵�āA���v���C�X���ݒ肷��H
# �X�e�[�^�X�̕ۑ���At����StatsIO�l���H
#
#
# 1. �g�p����ƃX�e�[�^�X�ύX
# 2. �g�p����Ɠ��͉�ʕ\��
#   2-1. ���͂���Ɗm�F��ʕ\��
#   2-2. �R�~�b�g����ƕύX�A�L�����Z������Ǝg�p���Ȃ�
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
