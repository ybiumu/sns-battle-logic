package Anothark::Status::Confuse;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::Status;
use base qw( Anothark::Status );

my $status = undef;

our $id = 12;
our $no_move     = sub{0};
our $no_target   = 2;
our $effect_span = 2;
our $long_label  = 'Œ¶Šo';
our $short_label = 'Œ¶';
our $system_name = 'confuse';
our $stat_msg    = '';
our $array_order = 11;
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
    $class->debug("CALL_INIT Confuse");
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
