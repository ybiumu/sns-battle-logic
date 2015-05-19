package Anothark::Status::_UCFIRST_;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::Status;
use base qw( Anothark::Status );

my $status = undef;

our $id = _ID_;
our $no_move     = _NO_MOVE_;
our $no_target   = _NO_TARGET_;
our $effect_span = _EFFECT_SPAN_;
our $long_label  = _LONG_LABEL_;
our $short_label = _SHORT_LABEL_;
our $system_name = _SYSTEM_NAME_;
our $stat_msg    = _STAT_MSG_;
our $array_order = _ARRAY_ORDER_;
our $cancel_by   = _CANCEL_BY_;
our $triggered_by = _TRIGGERED_BY_;
our $effect      = _MAIN_EFFECT_;
our $enchant_effect      = _ENCHANT_EFFECT_;


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
    $class->debug("CALL_INIT _UCFIRST_");
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
