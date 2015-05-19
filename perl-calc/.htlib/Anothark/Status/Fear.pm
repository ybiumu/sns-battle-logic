package Anothark::Status::Fear;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::Status;
use base qw( Anothark::Status );

my $status = undef;

our $id = 17;
our $no_move     = sub{$_[0]->isSmallerThanHalf()};
our $no_target   = 0;
our $effect_span = 4;
our $long_label  = '‹°•|';
our $short_label = '‹°';
our $system_name = 'fear';
our $stat_msg    = '‹°•|‚Å“®‚¯‚È‚¢';
our $array_order = 16;
our $cancel_by   = 0;
our $triggered_by = 0;
our $effect      = sub{0};
our $enchant_effect      = sub{0};


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
    $class->debug("CALL_INIT Fear");
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
