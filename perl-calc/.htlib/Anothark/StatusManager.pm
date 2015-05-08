package Anothark::StatusManager;
#
# 愛
#
$|=1;
use strict;

use Anothark::Status;

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
};

use constant LIFT      => 1;
use constant DOWN      => 2;
use constant DRY       => 3;
use constant WET       => 4;
use constant SHOCK     => 5;
use constant BLANK     => 6;
use constant DRAW      => 7;
use constant KNOCKBACK => 8;
use constant BURNING   => 9;
use constant FREEZE    => 10;
use constant STAN      => 11;
use constant CONFUSE   => 12;
use constant SLEEP     => 13;
use constant POISON    => 14;
use constant VENOM     => 15;
use constant STONE     => 16;
use constant FEAR      => 17;
use constant DICONCENT => 18;
use constant FLY       => 19;
use constant GRAVITY   => 20;
use constant GLAP      => 21;
use constant GARD      => 22;
use constant PHASEOUT  => 23;
use constant REFLECT   => 24;
use constant WALL      => 25;
use constant AWAKE     => 26;

use constant DIE       => 27;
use constant ESCAPE    => 28;
use constant FLIP      => 29;

use constant NOT_STATUS  => 0;
use constant JUST_STATUS => 1;
use constant ANTI_STATUS => 2;
# use constant ANY_STATUS? => 4;

my $stat_length = 29;
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
    $class->setStack([]);
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
    my $class   = shift;
    my $index   = shift;
    my $require = shift;
    return having_flag(substr($class->getStatStr(), $index,1),$require);
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


=pod
@param status_string
@return status_object_array
=cut
sub appendStatusByStr
{
    my $class = shift;
    my $stat  = shift;

    # load statuses for need.
    my @status = map {
        my $stat_obj = $_;
        my $mod_name = ucfirst($stat_obj->{system_name});
        my $mod = undef;
        my $evstr = "use Anothark::Status::$mod_name;\$mod = new Anothark::Status::$mod_name();";
        $class->debug($evstr);
        eval($evstr);
        if ($@)
        {
            $class->error("Can't load Anothark::Status::$mod_name!");
            $mod = new Anothark::Status();
        }
        else
        {
            $mod->setCurrentVector( substr($stat,$mod->getArrayOrder(),1) );
        }
        $mod;
    }
    grep
    {
        substr($stat,$_->{array_order},1) ne "0"
    } values %{ $class->get_stat_master() };

    foreach my $stat ( @status )
    {
        # regist check
# some code.
        # regist check後解決待ちだけど確定済みのステータスをスタック
        push(@{$class->getStack()},$stat);
    }

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
    return scalar @{$_[0]->getStack()};
}

sub getResultStr
{
    return join("", map{ sprintf "%s!", $_->getLongLabel() } @{$_[0]->getStack() });
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
