package Anothark::Status::Poison;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::Status;
use base qw( Anothark::Status );

my $status = undef;

our $id = 14;
our $no_move     = sub{0};
our $no_target   = 0;
our $effect_span = 4;
our $long_label  = '“Å';
our $short_label = '“Å';
our $system_name = 'poison';
our $stat_msg    = '';
our $array_order = 13;
our $cancel_by   = 0;
our $triggered_by = 1;
our $effect      = sub{0};
our $enchant_effect      = sub{$_[0]->{count}++;};


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
    $class->debug("CALL_INIT Poison");
    $class->setLongLabel($long_label);
    $class->setShortLabel($short_label);
    $class->setSystemName($system_name);

    $class->setNoMove($no_move);
    $class->setNoTarget($no_target);

    $class->setEffectSpan($effect_span);
    $class->setTriggeredBy($triggered_by);
    $class->setCancelBy($cancel_by);

    $class->setEffect($effect);
    $class->setEnchantEffect($enchant_effect);

    $class->setArrayOrder($array_order);

}


1;
