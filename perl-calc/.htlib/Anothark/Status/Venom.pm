package Anothark::Status::Venom;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::Status;
use base qw( Anothark::Status );

my $status = undef;

our $id = 15;
our $no_move     = sub{0};
our $no_target   = 0;
our $effect_span = 4;
our $long_label  = '–Ò“Å';
our $short_label = '–Ò';
our $system_name = 'venom';
our $stat_msg    = '';
our $array_order = 14;
our $cancel_by   = 0;
our $triggered_by = 1;
our $effect      = sub{$_[1]->Affected( (-10) * $_[0]->{count}, 3 );$_[0]->{count}++;};
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
    $class->debug("CALL_INIT Venom");
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
