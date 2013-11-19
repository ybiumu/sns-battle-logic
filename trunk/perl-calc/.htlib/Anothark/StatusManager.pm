package Anothark::StatusManager;
#
# 愛
#
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

#
#
#Ｌ|Dn|Dr|Ｗ|Ｓ|Ｂ|引|弾|燃|凍|麻|幻|睡|毒|猛|石|恐|狼|飛|重|捕|護|離|反|壁|覚|昏|逃|転|
#１|２|３|４|５|６|７|８|９|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|
#
#
my $stat_master = {
    1  => { array_order => 0 ,system_name => 'lift',       short_name => 'Ｌ', long_name => 'ﾘﾌﾄ',     no_move => sub{0},                          no_target => 0, stat_msg => '' },
    2  => { array_order => 1 ,system_name => 'down',       short_name => 'Dn', long_name => 'ﾀﾞｳﾝ',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    3  => { array_order => 2 ,system_name => 'dry',        short_name => 'Dr', long_name => 'ﾄﾞﾗｲ',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    4  => { array_order => 3 ,system_name => 'wet',        short_name => 'Ｗ', long_name => 'ｳｪｯﾄ',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    5  => { array_order => 4 ,system_name => 'shock',      short_name => 'Ｓ', long_name => 'ｼｮｯｸ',    no_move => sub{1},                          no_target => 0, stat_msg => 'ｼｮｯｸで動けない' },
    6  => { array_order => 5 ,system_name => 'blank',      short_name => 'Ｂ', long_name => 'ﾌﾞﾗﾝｸ',   no_move => sub{0},                          no_target => 1, stat_msg => 'ﾌﾞﾗﾝｸで狙えない' },
    7  => { array_order => 6 ,system_name => 'draw',       short_name => '引', long_name => 'ﾄﾞﾛｳ',    no_move => sub{0},                          no_target => 0, stat_msg => '引き寄せた' },
    8  => { array_order => 7 ,system_name => 'knockback',  short_name => '弾', long_name => 'ﾉｯｸﾊﾞｯｸ', no_move => sub{0},                          no_target => 0, stat_msg => '弾き飛ばした' },
    9  => { array_order => 8 ,system_name => 'burning',    short_name => '燃', long_name => '燃焼',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    10 => { array_order => 9 ,system_name => 'freeze',     short_name => '凍', long_name => '凍結',    no_move => sub{1},                          no_target => 0, stat_msg => '凍結している' },
    11 => { array_order => 10,system_name => 'stan',       short_name => '麻', long_name => '麻痺',    no_move => sub{1},                          no_target => 0, stat_msg => '麻痺している' },
    12 => { array_order => 11,system_name => 'confuse',    short_name => '幻', long_name => '幻覚',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    13 => { array_order => 12,system_name => 'sleep',      short_name => '睡', long_name => '睡眠',    no_move => sub{1},                          no_target => 0, stat_msg => '眠っている' },
    14 => { array_order => 13,system_name => 'poison',     short_name => '毒', long_name => '毒',      no_move => sub{0},                          no_target => 0, stat_msg => '' },
    15 => { array_order => 14,system_name => 'venom',      short_name => '猛', long_name => '猛毒',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    16 => { array_order => 15,system_name => 'stone',      short_name => '石', long_name => '石化',    no_move => sub{1},                          no_target => 0, stat_msg => '石化している' },
    17 => { array_order => 16,system_name => 'fear',       short_name => '恐', long_name => '恐怖',    no_move => sub{$_[0]->isSmallerThanHalf()}, no_target => 0, stat_msg => '恐怖で動けない' },
    18 => { array_order => 17,system_name => 'disconcent', short_name => '狼', long_name => '狼狽',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    19 => { array_order => 18,system_name => 'fly',        short_name => '飛', long_name => '飛行',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    20 => { array_order => 19,system_name => 'gravity',    short_name => '重', long_name => '重力',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    21 => { array_order => 20,system_name => 'glap',       short_name => '捕', long_name => '捕縛',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    22 => { array_order => 21,system_name => 'gard',       short_name => '護', long_name => '保護',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    23 => { array_order => 22,system_name => 'phaseout',   short_name => '離', long_name => '離脱',    no_move => sub{0},                          no_target => 0, stat_msg => '現れた' },
    24 => { array_order => 23,system_name => 'reflect',    short_name => '反', long_name => '反射',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    25 => { array_order => 24,system_name => 'wall',       short_name => '壁', long_name => '障壁',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    26 => { array_order => 25,system_name => 'awake',      short_name => '覚', long_name => '覚醒',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    27 => { array_order => 26,system_name => 'die',        short_name => '昏', long_name => '昏睡',    no_move => sub{1},                          no_target => 0, stat_msg => '倒れた' },
    28 => { array_order => 27,system_name => 'escape',     short_name => '逃', long_name => '逃走',    no_move => sub{1},                          no_target => 0, stat_msg => '逃げ出した' },
    29 => { array_order => 28,system_name => 'flip',       short_name => '転', long_name => '反転',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
};

use constant BLANK => 6;
use constant POISON => 14;


use constant NOT_STATUS  => 0;
use constant JUST_STATUS => 1;
use constant ANTI_STATUS => 2;
# use constant ANY_STATUS? => 4;

my $stat_length = 28;
my $stat_str = "0" x $stat_length;
my $stat_array = [ ("0") x $stat_length ];

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->init();

    return $self;
}

sub init
{
    my $class = shift;
    $class->setStatArray($stat_array);
    $class->array2str();

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



1;
