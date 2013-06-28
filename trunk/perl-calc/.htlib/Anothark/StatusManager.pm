package Anothark::StatusManager;
#
# ��
#
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

#
#
#�k|Dn|Dr|�v|�r|�a|��|�e|�R|��|��|��|��|��|��|��|��|�T|��|�d|��|��|��|��|��|�o|��|
#�P|�Q|�R|�S|�T|�U|�V|�W|�X|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|
#
#
my $stat_master = {
    1 => { array_order => 0 ,system_name => "lift",       short_name => "�k", long_name => "���",  },
    2 => { array_order => 1 ,system_name => "down",       short_name => "Dn", long_name => "�޳�", },
    3 => { array_order => 2 ,system_name => "dry",        short_name => "Dr", long_name => "��ײ", },
    4 => { array_order => 3 ,system_name => "wet",        short_name => "�v", long_name => "����", },
    5 => { array_order => 4 ,system_name => "shock",      short_name => "�r", long_name => "����", },
    6 => { array_order => 5 ,system_name => "blank",      short_name => "�a", long_name => "���ݸ", },
    7 => { array_order => 6 ,system_name => "draw",       short_name => "��", long_name => "��۳", },
    8 => { array_order => 7 ,system_name => "knockback",  short_name => "�e", long_name => "ɯ��ޯ�", },
    9 => { array_order => 8 ,system_name => "burning",    short_name => "�R", long_name => "�R��", },
    10=> { array_order => 9 ,system_name => "freeze",     short_name => "��", long_name => "����", },
    11=> { array_order => 10,system_name => "stan",       short_name => "��", long_name => "���", },
    12=> { array_order => 11,system_name => "confuse",    short_name => "��", long_name => "���o", },
    13=> { array_order => 12,system_name => "sleep",      short_name => "��", long_name => "����", },
    14=> { array_order => 13,system_name => "poison",     short_name => "��", long_name => "��",   },
    15=> { array_order => 14,system_name => "venom",      short_name => "��", long_name => "�ғ�", },
    16=> { array_order => 15,system_name => "stone",      short_name => "��", long_name => "�Ή�", },
    17=> { array_order => 16,system_name => "fear",       short_name => "��", long_name => "���|", },
    18=> { array_order => 17,system_name => "disconcent", short_name => "�T", long_name => "�T��", },
    19=> { array_order => 18,system_name => "fly",        short_name => "��", long_name => "��s", },
    20=> { array_order => 19,system_name => "gravity",    short_name => "�d", long_name => "�d��", },
    21=> { array_order => 20,system_name => "glap",       short_name => "��", long_name => "�ߔ�", },
    22=> { array_order => 21,system_name => "gard",       short_name => "��", long_name => "�ی�", },
    23=> { array_order => 22,system_name => "phaseout",   short_name => "��", long_name => "���E", },
    24=> { array_order => 23,system_name => "reflect",    short_name => "��", long_name => "����", },
    25=> { array_order => 24,system_name => "wall",       short_name => "��", long_name => "���", },
    26=> { array_order => 25,system_name => "awake",      short_name => "�o", long_name => "�o��", },
    27=> { array_order => 26,system_name => "die",        short_name => "��", long_name => "����", },
    28=> { array_order => 27,system_name => "escape",     short_name => "��", long_name => "����", },
};

my $stat_length = 27;
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



sub isStatTrue
{
    my $class   = shift;
    my $index   = shift;
    my $require = shift;
    return having_flag(substr($class->getStartStr(), $index,1),$require);
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


1;
