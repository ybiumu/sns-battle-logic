package Anothark::StatusManager;
#
# ˆ¤
#
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

#
#
#‚k|Dn|Dr|‚v|‚r|‚a|ˆø|’e|”R|“€|–ƒ|Œ¶|‡|“Å|–Ò|Î|‹°|˜T|”ò|d|•ß|Œì|—£|”½|•Ç|Šo|¨|“¦|“]|
#‚P|‚Q|‚R|‚S|‚T|‚U|‚V|‚W|‚X|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|
#
#
my $stat_master = {
    1  => { array_order => 0 ,system_name => 'lift',       short_name => '‚k', long_name => 'ØÌÄ',     no_move => sub{0},                          no_target => 0, stat_msg => '' },
    2  => { array_order => 1 ,system_name => 'down',       short_name => 'Dn', long_name => 'ÀÞ³Ý',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    3  => { array_order => 2 ,system_name => 'dry',        short_name => 'Dr', long_name => 'ÄÞ×²',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    4  => { array_order => 3 ,system_name => 'wet',        short_name => '‚v', long_name => '³ª¯Ä',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    5  => { array_order => 4 ,system_name => 'shock',      short_name => '‚r', long_name => '¼®¯¸',    no_move => sub{1},                          no_target => 0, stat_msg => '¼®¯¸‚Å“®‚¯‚È‚¢' },
    6  => { array_order => 5 ,system_name => 'blank',      short_name => '‚a', long_name => 'ÌÞ×Ý¸',   no_move => sub{0},                          no_target => 1, stat_msg => 'ÌÞ×Ý¸‚Å‘_‚¦‚È‚¢' },
    7  => { array_order => 6 ,system_name => 'draw',       short_name => 'ˆø', long_name => 'ÄÞÛ³',    no_move => sub{0},                          no_target => 0, stat_msg => 'ˆø‚«Šñ‚¹‚½' },
    8  => { array_order => 7 ,system_name => 'knockback',  short_name => '’e', long_name => 'É¯¸ÊÞ¯¸', no_move => sub{0},                          no_target => 0, stat_msg => '’e‚«”ò‚Î‚µ‚½' },
    9  => { array_order => 8 ,system_name => 'burning',    short_name => '”R', long_name => '”RÄ',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    10 => { array_order => 9 ,system_name => 'freeze',     short_name => '“€', long_name => '“€Œ‹',    no_move => sub{1},                          no_target => 0, stat_msg => '“€Œ‹‚µ‚Ä‚¢‚é' },
    11 => { array_order => 10,system_name => 'stan',       short_name => '–ƒ', long_name => '–ƒáƒ',    no_move => sub{1},                          no_target => 0, stat_msg => '–ƒáƒ‚µ‚Ä‚¢‚é' },
    12 => { array_order => 11,system_name => 'confuse',    short_name => 'Œ¶', long_name => 'Œ¶Šo',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    13 => { array_order => 12,system_name => 'sleep',      short_name => '‡', long_name => '‡–°',    no_move => sub{1},                          no_target => 0, stat_msg => '–°‚Á‚Ä‚¢‚é' },
    14 => { array_order => 13,system_name => 'poison',     short_name => '“Å', long_name => '“Å',      no_move => sub{0},                          no_target => 0, stat_msg => '' },
    15 => { array_order => 14,system_name => 'venom',      short_name => '–Ò', long_name => '–Ò“Å',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    16 => { array_order => 15,system_name => 'stone',      short_name => 'Î', long_name => 'Î‰»',    no_move => sub{1},                          no_target => 0, stat_msg => 'Î‰»‚µ‚Ä‚¢‚é' },
    17 => { array_order => 16,system_name => 'fear',       short_name => '‹°', long_name => '‹°•|',    no_move => sub{$_[0]->isSmallerThanHalf()}, no_target => 0, stat_msg => '‹°•|‚Å“®‚¯‚È‚¢' },
    18 => { array_order => 17,system_name => 'disconcent', short_name => '˜T', long_name => '˜T”‚',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    19 => { array_order => 18,system_name => 'fly',        short_name => '”ò', long_name => '”òs',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    20 => { array_order => 19,system_name => 'gravity',    short_name => 'd', long_name => 'd—Í',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    21 => { array_order => 20,system_name => 'glap',       short_name => '•ß', long_name => '•ß”›',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    22 => { array_order => 21,system_name => 'gard',       short_name => 'Œì', long_name => '•ÛŒì',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    23 => { array_order => 22,system_name => 'phaseout',   short_name => '—£', long_name => '—£’E',    no_move => sub{0},                          no_target => 0, stat_msg => 'Œ»‚ê‚½' },
    24 => { array_order => 23,system_name => 'reflect',    short_name => '”½', long_name => '”½ŽË',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    25 => { array_order => 24,system_name => 'wall',       short_name => '•Ç', long_name => 'á•Ç',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    26 => { array_order => 25,system_name => 'awake',      short_name => 'Šo', long_name => 'ŠoÁ',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
    27 => { array_order => 26,system_name => 'die',        short_name => '¨', long_name => '¨‡',    no_move => sub{1},                          no_target => 0, stat_msg => '“|‚ê‚½' },
    28 => { array_order => 27,system_name => 'escape',     short_name => '“¦', long_name => '“¦‘–',    no_move => sub{1},                          no_target => 0, stat_msg => '“¦‚°o‚µ‚½' },
    29 => { array_order => 28,system_name => 'flip',       short_name => '“]', long_name => '”½“]',    no_move => sub{0},                          no_target => 0, stat_msg => '' },
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
