package Anothark::StatusManager;
#
# 愛
#
$|=1;
use strict;

use Anothark::Status;
use Anothark::StackObject;

use LoggingObjMethod;
use base qw( LoggingObjMethod );

#
#
#Ｌ|Dn|Dr|Ｗ|Ｓ|Ｂ|引|弾|燃|凍|麻|幻|睡|毒|猛|石|恐|狼|飛|重|捕|護|離|反|壁|覚|昏|逃|転|
#１|２|３|４|５|６|７|８|９|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|
#
#
my $stat_master = {
    1  => { array_order => 0 ,system_name => 'lift',       short_label => 'Ｌ', long_label => 'ﾘﾌﾄ',     effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    2  => { array_order => 1 ,system_name => 'down',       short_label => 'Dn', long_label => 'ﾀﾞｳﾝ',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    3  => { array_order => 2 ,system_name => 'dry',        short_label => 'Dr', long_label => 'ﾄﾞﾗｲ',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    4  => { array_order => 3 ,system_name => 'wet',        short_label => 'Ｗ', long_label => 'ｳｪｯﾄ',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    5  => { array_order => 4 ,system_name => 'shock',      short_label => 'Ｓ', long_label => 'ｼｮｯｸ',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => 'ｼｮｯｸで動けない' },
    6  => { array_order => 5 ,system_name => 'blank',      short_label => 'Ｂ', long_label => 'ﾌﾞﾗﾝｸ',   effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 1, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => 'ﾌﾞﾗﾝｸで狙えない' },
    7  => { array_order => 6 ,system_name => 'draw',       short_label => '引', long_label => 'ﾄﾞﾛｳ',    effect_span => 1, cancel_by => 0, triggered_by => 2, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '引き寄せた' },
    8  => { array_order => 7 ,system_name => 'knockback',  short_label => '弾', long_label => 'ﾉｯｸﾊﾞｯｸ', effect_span => 1, cancel_by => 0, triggered_by => 2, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '弾き飛ばした' },
    9  => { array_order => 8 ,system_name => 'burning',    short_label => '燃', long_label => '燃焼',    effect_span => 2, cancel_by => 0, triggered_by => 1, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    10 => { array_order => 9 ,system_name => 'freeze',     short_label => '凍', long_label => '凍結',    effect_span => 2, cancel_by => 2, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '凍結している' },
    11 => { array_order => 10,system_name => 'stan',       short_label => '麻', long_label => '麻痺',    effect_span => 2, cancel_by => 0, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '麻痺している' },
    12 => { array_order => 11,system_name => 'confuse',    short_label => '幻', long_label => '幻覚',    effect_span => 2, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 2, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    13 => { array_order => 12,system_name => 'sleep',      short_label => '睡', long_label => '睡眠',    effect_span => 3, cancel_by => 2, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '眠っている' },
    14 => { array_order => 13,system_name => 'poison',     short_label => '毒', long_label => '毒',      effect_span => 4, cancel_by => 0, triggered_by => 1, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{$_[0]->{count}++;}', stat_msg => '' },
    15 => { array_order => 14,system_name => 'venom',      short_label => '猛', long_label => '猛毒',    effect_span => 4, cancel_by => 0, triggered_by => 1, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{$_[1]->Affected( (-10) * $_[0]->{count}, 3 );$_[0]->{count}++;}', enchant_effect => 'sub{$_[0]->{count}++;}', stat_msg => '' },
    16 => { array_order => 15,system_name => 'stone',      short_label => '石', long_label => '石化',    effect_span => 4, cancel_by => 0, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '石化している' },
    17 => { array_order => 16,system_name => 'fear',       short_label => '恐', long_label => '恐怖',    effect_span => 4, cancel_by => 0, triggered_by => 0, no_move => 'sub{$_[0]->isSmallerThanHalf()}', no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '恐怖で動けない' },
    18 => { array_order => 17,system_name => 'disconcent', short_label => '狼', long_label => '狼狽',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    19 => { array_order => 18,system_name => 'fly',        short_label => '飛', long_label => '飛行',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    20 => { array_order => 19,system_name => 'gravity',    short_label => '重', long_label => '重力',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    21 => { array_order => 20,system_name => 'glap',       short_label => '捕', long_label => '捕縛',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    22 => { array_order => 21,system_name => 'gard',       short_label => '護', long_label => '保護',    effect_span => 3, cancel_by => 0, triggered_by => 3, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    23 => { array_order => 22,system_name => 'phaseout',   short_label => '離', long_label => '離脱',    effect_span => 2, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '現れた' },
    24 => { array_order => 23,system_name => 'reflect',    short_label => '反', long_label => '反射',    effect_span => 3, cancel_by => 1, triggered_by => 3, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '反射した' },
    25 => { array_order => 24,system_name => 'wall',       short_label => '壁', long_label => '障壁',    effect_span => 3, cancel_by => 1, triggered_by => 3, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '打ち消した' },
    26 => { array_order => 25,system_name => 'awake',      short_label => '覚', long_label => '覚醒',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    27 => { array_order => 26,system_name => 'die',        short_label => '昏', long_label => '昏睡',    effect_span => 3, cancel_by => 0, triggered_by => 2, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '倒れた' },
    28 => { array_order => 27,system_name => 'escape',     short_label => '逃', long_label => '逃走',    effect_span => 3, cancel_by => 0, triggered_by => 2, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '逃げ出した' },
    29 => { array_order => 28,system_name => 'flip',       short_label => '転', long_label => '反転',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    30 => { array_order => 29,system_name => 'name_29',    short_label => '29', long_label => '状29',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    31 => { array_order => 30,system_name => 'name_30',    short_label => '30', long_label => '状30',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    32 => { array_order => 31,system_name => 'name_31',    short_label => '31', long_label => '状31',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    33 => { array_order => 32,system_name => 'name_32',    short_label => '32', long_label => '状32',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    34 => { array_order => 33,system_name => 'name_33',    short_label => '33', long_label => '状33',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    35 => { array_order => 34,system_name => 'name_34',    short_label => '34', long_label => '状34',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    36 => { array_order => 35,system_name => 'name_35',    short_label => '35', long_label => '状35',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    37 => { array_order => 36,system_name => 'name_36',    short_label => '36', long_label => '状36',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    38 => { array_order => 37,system_name => 'name_37',    short_label => '37', long_label => '状37',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    39 => { array_order => 38,system_name => 'name_38',    short_label => '38', long_label => '状38',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    40 => { array_order => 39,system_name => 'name_39',    short_label => '39', long_label => '状39',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
};

use constant LIFT      => 0;
use constant DOWN      => 1;
use constant DRY       => 2;
use constant WET       => 3;
use constant SHOCK     => 4;
use constant BLANK     => 5;
use constant DRAW      => 6;
use constant KNOCKBACK => 7;
use constant BURNING   => 8;
use constant FREEZE    => 9;
use constant STAN      => 10;
use constant CONFUSE   => 11;
use constant SLEEP     => 12;
use constant POISON    => 13;
use constant VENOM     => 14;
use constant STONE     => 15;
use constant FEAR      => 16;
use constant DICONCENT => 17;
use constant FLY       => 18;
use constant GRAVITY   => 19;
use constant GLAP      => 20;
use constant GARD      => 21;
use constant PHASEOUT  => 22;
use constant REFLECT   => 23;
use constant WALL      => 24;
use constant AWAKE     => 25;

use constant DIE       => 26;
use constant ESCAPE    => 27;
use constant FLIP      => 28;

#use constant NOT_STATUS  => 0;
#use constant JUST_STATUS => 1;
use constant JUST_STATUS => 0;
use constant ANTI_STATUS => 2;
# use constant ANY_STATUS? => 4;

#my $stat_length = 29;
my $stat_length = 40;
my $stat_str = "0" x $stat_length;
my $stat_array = [ ("0") x $stat_length ];

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
    $class->setStack( new Anothark::StackObject() );
    $class->setJustStack( new Anothark::StackObject() );
    $class->setStatArray($stat_array);
    $class->array2str();

}


sub get_stat_master
{
    my $class = shift;
    return $stat_master;
}

sub having_flag
{
    my $key = shift;
    my $search = shift;
    return ( 2**$search == (hex($key) & 2**$search ) ? 1 : 0); 
}


#
#
# @param: index - index number of status. ex) blank is 6, fly is 19
# @param: require - 0: no status, 1: just status, 2 Anti-status 
#
sub isStatTrue
{
    my $class         = shift;
    my $array_order   = shift;
    my $require       = shift;
    return having_flag(substr($class->getStatStr(), $array_order,1),$require);
}




sub array2str
{
    my $class = shift;
    $class->setStatStr( join("",@{$class->getStatArray()}));
}

sub setStatArray
{
    my $class = shift;
    return $class->setAttribute( 'stat_array', shift );
}

sub getStatArray
{
    return $_[0]->getAttribute( 'stat_array' );
}


sub setStatStr
{
    my $class = shift;
    return $class->setAttribute( 'stat_str', shift );
}

sub getStatStr
{
    return $_[0]->getAttribute( 'stat_str' );
}


sub setStatus
{
    $_[0]->getStatArray()->[$_[1]] = $_[2];
    $_[0]->array2str();
}


sub setStatusIndex
{
    my $class = shift;
    my $index = shift;
    my $mod_name = $class->get_stat_master()->{$index}->{system_name};
    my $mod = $class->loadStatusByModName( $mod_name );

    $class->setStatusByObject( $mod );
}

sub setStatusByLabel
{
    my $class = shift;
    my $label = shift;
    my $vector = shift || 0;
    my $buffer = shift || 0;
    my @founds = grep {
        $_->{system_name} eq $label 
        or $_->{short_label} eq $label 
        or $_->{long_label} eq $label 
    } values %{ $class->get_stat_master() };

    if ( scalar(@founds) == 1 )
    {
        my $mod_name = $founds[0]->{system_name};
        my $mod = $class->loadStatusByModName( $mod_name );

        $mod->setCurrentVector($vector);

        if ( $buffer )
        {
            $class->setStatusBufferByObject( $mod );
        }
        else
        {
            $class->setStatusByObject( $mod );
        }
    }
    else
    {
        $class->error("Find module failure, label [$label]");
    }
}


sub setStatusBufferByObject
{
    my $class = shift;
    my $stat  = shift;
    if ( $stat->isAdd() )
    {
        $class->appendStatBufferStr( $stat );
    }
    elsif( $stat->isClear() )
    {
        $class->appendStatBufferStr( $stat );
    }
    else
    {
        $class->debug("Unknown vector");
    }

}

sub appendStatBufferStr
{
    my $class = shift;
    my $stat  = shift;
    $class->getStatArray()->[($stat->getArrayOrder())] =  $stat->getCurrentVector();
    $class->array2str();
}

sub setStatusByObject
{
    my $class = shift;
    my $stat  = shift;
    if ( $stat->isAdd() )
    {
        if ( $stat->isAnti() )
        {
            $class->appendStatus( $stat->getArrayOrder(), ANTI_STATUS );
        }
        else
        {
            $class->appendStatus( $stat->getArrayOrder(), JUST_STATUS );
            $class->getJustStack()->stackOne($stat);
        }
    }
    elsif( $stat->isClear() )
    {
        if ( $stat->isAnti() )
        {
            $class->clearStatus( $stat->getArrayOrder(), ANTI_STATUS );
        }
        else
        {
            $class->clearStatus( $stat->getArrayOrder(), JUST_STATUS );
        }
    }
    else
    {
        $class->debug("Unknown vector");
    }

}

sub appendStatus
{
    my $current = $_[0]->getStatArray()->[$_[1]];
    $_[0]->getStatArray()->[$_[1]] =  hex($current) | 2**$_[2];
    $_[0]->array2str();
}

sub clearStatus
{
    my $current = $_[0]->getStatArray()->[$_[1]];
    $_[0]->getStatArray()->[$_[1]] =  hex($current) & ~2**$_[2];
    $_[0]->array2str();
}


sub checkChainStatusByStr
{
    my $class        = shift;
    my $chain_stat   = shift;
#    my $current_stat = $class->getStatStr();
    my $current_stat = $class->getJustStackByStr();
    $class->debug("[CURRENT CHAIN STATUS]" . $current_stat);
    $class->debug("[SKILL   CHAIN STATUS]" . $chain_stat);
    $current_stat &= $chain_stat;
    $class->debug("[RESOLVE CHAIN STATUS]" . $current_stat);
    my $result = ( $current_stat ) + 0;

#    for(my $p = 0;$p < $stat_length; $p++ )
#    {
#        if (substr($chain_stat,$p,1))
#        {
#            $result |= ( 2**JUST_STATUS == (hex(substr($current_stat,$p,1)) & 2**JUST_STATUS ) )
#        }
#    }

    return $result;
}


=pod
    loadStatusByModName
=cut
sub loadStatusByModName
{
    my $class    = shift;
    my $mod_name = ucfirst(shift);

    my $mod = undef;
    my $evstr = "use Anothark::Status::$mod_name;\$mod = new Anothark::Status::$mod_name();";
#    $class->debug("[loadStatusByModName]");
#    $class->debug($evstr);
    eval($evstr);
    if ($@)
    {
        $class->error("Can't load Anothark::Status::$mod_name!");
        $mod = new Anothark::Status();
    }

#    $class->debug("[REFS 0] " . ref($mod));
    return $mod;
}


sub setupStatusByName
{
    my $class    = shift;
    my $stat     = shift;
    my $stat_obj = shift;
    my $mod_name = ucfirst($stat_obj->{system_name});
    my $mod = $class->loadStatusByModName( $mod_name );
    $mod->setCurrentVector( substr($stat,$mod->getArrayOrder(),1) );
#    $class->debug("[MODULE0]" . $mod->getSystemName() . "/array_order:" . $mod->getArrayOrder());
    return $mod;
}

=pod
@param status_string
@return status_object_array
=cut
sub appendStatusByStr
{
    my $class = shift;
    my $stat  = shift;

    # load statuses for need.

    # load statuses for need.
    my @vals = grep
    {
        substr($stat,$_->{array_order},1) ne "0"
    } values %{ $class->get_stat_master() };


    my @status = map { ( $class->setupStatusByName($stat,$_) ) } @vals;

    $class->debug("[Actions for each Stat module.]");

    foreach my $stat_obj ( @status )
    {

        $class->debug("[MODLUE]" . $stat_obj->getSystemName() );
        # regist check
# some code.
        # XXX Pattarn of nothing to do. XXX
        if ( $stat_obj->isAdd() && not $stat_obj->isAnti() )
        {
            # regist.
            if ( $class->isAnti( $stat_obj ) )
            {
                $class->debug("[result]: Registed.");
                next;
            }
        }
        elsif ( $stat_obj->isAdd() && $stat_obj->isAnti() )
        {
            # add anti.
        }
        elsif ( $stat_obj->isClear() )
        {
            # can't clear because no that stat_obj.
            if ( not $class->isJust( $stat_obj ) && not $stat_obj->isAnti() )
            {
                $class->debug("[result]: Can't clear because no that stat_obj.");
                next;
            }
            # can't clear anti because not having that stat_obj.
            elsif ( not $class->isAnti( $stat_obj ) && $stat_obj->isAnti() )
            {
                $class->debug("[result]: Can't clear anti because not having that stat_obj.");
                next;
            }
        }
        else
        {
            $class->warning("Unknown vector![" .  $stat_obj->getCurrentVector() . "]");
            next;
        }

        # regist check後解決待ちだけど確定済みのステータスをスタック
        $class->getStack()->stackOne($stat_obj);
    }

}

# require Status object.
sub isJust
{
    my $class = shift;
    my $stat  = shift;
    return $class->isStatTrue($stat->getArrayOrder(),JUST_STATUS );
}

# require Status object.
sub isAnti
{
    my $class = shift;
    my $stat  = shift;
    return $class->isStatTrue($stat->getArrayOrder(),ANTI_STATUS );
}


my $just_stack = undef;
sub setJustStack
{
    my $class = shift;
    return $class->setAttribute( 'just_stack', shift );
}

sub getJustStack
{
    return $_[0]->getAttribute( 'just_stack' );
}

sub getJustStackByStr
{
    my $class = shift;
    my $tmp_array = [ ("0") x $stat_length ];
    map
    {
        $tmp_array->[$_->getArrayOrder()] = 1;
    }
    @{ $class->getJustStack()->getMemory() };
    return join("",@{$tmp_array});
}

sub notTarget
{
    my $class = shift;
    my $func  = sub {
        my $stat = shift;
        if ( $stat->getNoTarget() eq 1 )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    };
    return $class->getJustStack()->existsByFunction($func);
}

sub notMove
{
    my $class = shift;
    my $func  = sub {
        my $stat = shift;
        if ( &{$stat->getNoMove()}() eq 1 )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    };
    return $class->getJustStack()->existsByFunction($func);
}


sub clearJustStackTurn
{
    my $class = shift;
    my $func  = sub {
        my $stat = shift;
        if ( $stat->getEffectSpan() eq 2 )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    };
    my $clear = $class->getJustStack()->filterByFunction($func);
    map {
        $class->clearStatus($_->getArrayOrder(),JUST_STATUS);
    } $clear->moveAll();
}

sub clearJustStackAct
{
    my $class = shift;
    $class->debug("[clearJustStackAct]");
    my $func  = sub {
        my $stat = shift;
        if ( $stat->getEffectSpan() eq 1 )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    };
    my $clear = $class->getJustStack()->filterByFunction($func);
    map {
        $class->clearStatus($_->getArrayOrder(),JUST_STATUS);
    } $clear->moveAll();
}

my $stack = undef;
sub setStack
{
    my $class = shift;
    return $class->setAttribute( 'stack', shift );
}

sub getStack
{
    return $_[0]->getAttribute( 'stack' );
}

sub hasStack
{
    return $_[0]->getStack()->isRemain();
}


sub getResultStr
{
    my $class = shift;

    $class->debug("[Stack count]:" . scalar(@{$class->getStack()->getMemory() } ));

    return join(
        "",
        map{
            sprintf
                "%s%s!",
                $_->getLongLabel(),
                (
                    $_->isAnti() ? sprintf("%s", ($_->isClear() ? "耐性を解除" : "に耐性を得た") ) :
                        ( $_->isClear() ? "を解除した" : "")
                )
        } @{$class->getStack()->getMemory() }
    );
}



sub commitStack
{
    my $class = shift;
    if ( $class->hasStack() )
    {
        my $stack = $class->getStack();
        $class->debug("stack refs: [" . ref $stack . "]");
        my @stat = $stack->moveAll();
        map {
            $class->setStatusByObject($_);
        } @stat;
#        } @{ $stack->moveAll() };
    }
}

# synonym

sub isBlank
{
    return $_[0]->isStatTrue( BLANK, JUST_STATUS );
}

sub setBlank
{
    $_[0]->appendStatus(BLANK, JUST_STATUS);
}

sub clearBlank
{
    $_[0]->clearStatus(BLANK, JUST_STATUS);
}


sub isPoison
{
    return $_[0]->isStatTrue( POISON, JUST_STATUS );
}

sub setPoison
{
    $_[0]->appendStatus( POISON, JUST_STATUS );
}

sub clearPoison
{

    $_[0]->clearStat( POISON, JUST_STATUS );
}


sub isDie
{
    return $_[0]->isStatTrue( DIE, JUST_STATUS );
}

sub setDie
{
    $_[0]->appendStatus(DIE, JUST_STATUS);
}

sub clearDie
{
    $_[0]->clearStatus(DIE, JUST_STATUS);
}


1;
