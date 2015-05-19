package Anothark::Status;
#
# 愛
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use base qw( LoggingObjMethod );

my $status = undef;

# 動けるか否か
# 狙えるか否か
# 終了条件
# XXX時に発生する効果
#  XXX:
#    行動時
#    ターゲッティング時
#    被ダメ時
#    被ターゲティング時
#    付与時


sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    return $self;
}

our $long_label  = "NoStatus";
our $short_label = "NO";
our $system_name = "no_status";


# Constraint.
our $no_move     = 0; #0:no_effect, 1: cannot move
our $no_target   = 0; #0:no_effect, 1: cannot target, 2:swap target 

our $effect_span = 0; #1: 1 action, 2: 1turn, 3: 1 battle, 4: never clear

# effectance timing
our $triggered_by = 0; # 0: no toriggerd, 1: before action, 2: after enchant, 3: toriggered

# Other ways for clear status 
our $cancel_by   = 0; #0: cannot cancel, 1: targetted,  2: hp damaged, 

our $effect = sub{0};
our $enchant_effect = sub{0};
# XXX for example XXX

use constant ADD   => 0;
use constant CLEAR => 1;
use constant ANTI  => 2;
=pod

$_[0] : class
$_[1] : enchanted target.
$_[2] : turns owner.

 - venom
sub {
    $_[0]->{count}++;
    $_[1]->Affected( (-10) * $_[0]->{count}, 3 );
}


=cut

#our $acction_effect = sub{0};
#our $trigger_effect = sub{0};
#our $init_effect    = sub{0};

our $array_order = 0;




sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->debug("CALL_INIT");
    $class->setLongLabel($long_label);
#    $class->setLongLabel(LONG_LABEL);
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


sub setLongLabel
{
    my $class = shift;
    return $class->setAttribute( 'long_label', shift );
}

sub getLongLabel
{
    return $_[0]->getAttribute( 'long_label' );
}

sub setShortLabel
{
    my $class = shift;
    return $class->setAttribute( 'short_label', shift );
}

sub getShortLabel
{
    return $_[0]->getAttribute( 'short_label' );
}

sub setSystemName
{
    my $class = shift;
    return $class->setAttribute( 'system_name', shift );
}

sub getSystemName
{
    return $_[0]->getAttribute( 'system_name' );
}

sub setNoMove
{
    my $class = shift;
    return $class->setAttribute( 'no_move', shift );
}

sub getNoMove
{
    return $_[0]->getAttribute( 'no_move' );
}

sub setNoTarget
{
    my $class = shift;
    return $class->setAttribute( 'no_target', shift );
}

sub getNoTarget
{
    return $_[0]->getAttribute( 'no_target' );
}

sub setEffectSpan
{
    my $class = shift;
    return $class->setAttribute( 'effect_span', shift );
}

sub getEffectSpan
{
    return $_[0]->getAttribute( 'effect_span' );
}

sub setTriggeredBy
{
    my $class = shift;
    return $class->setAttribute( 'triggered_by', shift );
}

sub getTriggeredBy
{
    return $_[0]->getAttribute( 'triggered_by' );
}

sub setCancelBy
{
    my $class = shift;
    return $class->setAttribute( 'cancel_by', shift );
}

sub getCancelBy
{
    return $_[0]->getAttribute( 'cancel_by' );
}

sub setEffect
{
    my $class = shift;
    return $class->setAttribute( 'effect', shift );
}

sub getEffect
{
    return $_[0]->getAttribute( 'effect' );
}

sub setEnchantEffect
{
    my $class = shift;
    return $class->setAttribute( 'enchant_effect', shift );
}

sub getEnchantEffect
{
    return $_[0]->getAttribute( 'enchant_effect' );
}

sub setArrayOrder
{
    my $class = shift;
    return $class->setAttribute( 'array_order', shift );
}

sub getArrayOrder
{
    return $_[0]->getAttribute( 'array_order' );
}





#sub setArrayOrder
#{
#    my $class = shift;
#    return $main::array_order = shift;
#}
#
#sub getArrayOrder
#{
#    return $main::array_order;
#}
#
#sub setCancelBy
#{
#    my $class = shift;
#    return $main::cancel_by = shift;
#}
#
#sub getCancelBy
#{
#    return $main::cancel_by;
#}
#
#sub setSystemName
#{
#    my $class = shift;
#    return $main::system_name = shift;
#}
#
#sub getSystemName
#{
#    return $main::system_name;
#}
#
#sub setShortLabel
#{
#    my $class = shift;
#    return $main::short_label = shift;
#}
#
#sub getShortLabel
#{
#    return $main::short_label;
#}
#
#sub setLongLabel
#{
#    my $class = shift;
#    return $main::long_label = shift;
#}
#
#sub getLongLabel
#{
#    return $main::long_label;
#}
#
#sub setEffectSpan
#{
#    my $class = shift;
#    return $main::effect_span = shift;
#}
#
#sub getEffectSpan
#{
#    return $main::effect_span;
#}
#
#sub setNoTarget
#{
#    my $class = shift;
#    return $main::no_target = shift;
#}
#
#sub getNoTarget
#{
#    return $main::no_target;
#}
#
#sub setNoMove
#{
#    my $class = shift;
#    return $main::no_move = shift;
#}
#
#sub getNoMove
#{
#    return $main::no_move;
#}












my $current_vector = undef;
#0:none, 1: add, 2:clear, 4 anti
# 0: do nothing
# 1: add this status
# 2: clear this status
# 3: add anti status
# 4: clear anti status
sub setCurrentVector
{
    my $class = shift;
    return $class->setAttribute( 'current_vector', shift );
}

sub getCurrentVector
{
    return $_[0]->getAttribute( 'current_vector' );
}

sub isAdd
{
    return ( 2 ** ADD == ( hex($_[0]->getCurrentVector()) & 2 ** ADD )  );
}

sub isClear
{
    return ( 2 ** CLEAR == ( hex($_[0]->getCurrentVector()) & 2 ** CLEAR )  );
}


sub isAnti
{
    return ( 2 ** ANTI == ( hex($_[0]->getCurrentVector()) & 2 ** ANTI )  );
}





sub being
{
    my $class = shift;
}

# 状態から数値的影響を受ける条件(毒とか)
sub effectTrigger
{
    my $class = shift;
}

sub effect
{
    my $class = shift;
}

# 状態がクリアされる条件
sub clearTrigger
{
    my $class = shift;
}

sub clear
{
    my $class = shift;
}

1;
