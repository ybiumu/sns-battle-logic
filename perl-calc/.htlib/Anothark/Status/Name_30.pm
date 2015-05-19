package Anothark::Status::Name_30;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::Status;
use base qw( Anothark::Status );

my $status = undef;

our $id = 31;
our $no_move     = sub{0};
our $no_target   = 0;
our $effect_span = 1;
our $long_label  = 'ó30';
our $short_label = '30';
our $system_name = 'name_30';
our $stat_msg    = '';
our $array_order = 30;
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
    $class->debug("CALL_INIT Name_30");
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
