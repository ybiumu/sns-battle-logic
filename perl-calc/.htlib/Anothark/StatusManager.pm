package Anothark::StatusManager;
#
# ˆ¤
#
$|=1;
use strict;

use Anothark::Status;

use LoggingObjMethod;
use base qw( LoggingObjMethod );

#
#
#‚k|Dn|Dr|‚v|‚r|‚a|ˆø|’e|”R|“€|–ƒ|Œ¶|‡|“Å|–Ò|Î|‹°|˜T|”ò|d|•ß|Œì|—£|”½|•Ç|Šo|¨|“¦|“]|
#‚P|‚Q|‚R|‚S|‚T|‚U|‚V|‚W|‚X|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|
#
#
my $stat_master = {
    1  => { array_order => 0 ,system_name => 'lift',       short_label => '‚k', long_label => 'ØÌÄ',     effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    2  => { array_order => 1 ,system_name => 'down',       short_label => 'Dn', long_label => 'ÀÞ³Ý',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    3  => { array_order => 2 ,system_name => 'dry',        short_label => 'Dr', long_label => 'ÄÞ×²',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    4  => { array_order => 3 ,system_name => 'wet',        short_label => '‚v', long_label => '³ª¯Ä',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    5  => { array_order => 4 ,system_name => 'shock',      short_label => '‚r', long_label => '¼®¯¸',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '¼®¯¸‚Å“®‚¯‚È‚¢' },
    6  => { array_order => 5 ,system_name => 'blank',      short_label => '‚a', long_label => 'ÌÞ×Ý¸',   effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 1, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => 'ÌÞ×Ý¸‚Å‘_‚¦‚È‚¢' },
    7  => { array_order => 6 ,system_name => 'draw',       short_label => 'ˆø', long_label => 'ÄÞÛ³',    effect_span => 1, cancel_by => 0, triggered_by => 2, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => 'ˆø‚«Šñ‚¹‚½' },
    8  => { array_order => 7 ,system_name => 'knockback',  short_label => '’e', long_label => 'É¯¸ÊÞ¯¸', effect_span => 1, cancel_by => 0, triggered_by => 2, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '’e‚«”ò‚Î‚µ‚½' },
    9  => { array_order => 8 ,system_name => 'burning',    short_label => '”R', long_label => '”RÄ',    effect_span => 2, cancel_by => 0, triggered_by => 1, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    10 => { array_order => 9 ,system_name => 'freeze',     short_label => '“€', long_label => '“€Œ‹',    effect_span => 2, cancel_by => 2, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '“€Œ‹‚µ‚Ä‚¢‚é' },
    11 => { array_order => 10,system_name => 'stan',       short_label => '–ƒ', long_label => '–ƒáƒ',    effect_span => 2, cancel_by => 0, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '–ƒáƒ‚µ‚Ä‚¢‚é' },
    12 => { array_order => 11,system_name => 'confuse',    short_label => 'Œ¶', long_label => 'Œ¶Šo',    effect_span => 2, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 2, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    13 => { array_order => 12,system_name => 'sleep',      short_label => '‡', long_label => '‡–°',    effect_span => 3, cancel_by => 2, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '–°‚Á‚Ä‚¢‚é' },
    14 => { array_order => 13,system_name => 'poison',     short_label => '“Å', long_label => '“Å',      effect_span => 4, cancel_by => 0, triggered_by => 1, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{$_[0]->{count}++;}', stat_msg => '' },
    15 => { array_order => 14,system_name => 'venom',      short_label => '–Ò', long_label => '–Ò“Å',    effect_span => 4, cancel_by => 0, triggered_by => 1, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{$_[1]->Affected( (-10) * $_[0]->{count}, 3 );$_[0]->{count}++;}', enchant_effect => 'sub{$_[0]->{count}++;}', stat_msg => '' },
    16 => { array_order => 15,system_name => 'stone',      short_label => 'Î', long_label => 'Î‰»',    effect_span => 4, cancel_by => 0, triggered_by => 0, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => 'Î‰»‚µ‚Ä‚¢‚é' },
    17 => { array_order => 16,system_name => 'fear',       short_label => '‹°', long_label => '‹°•|',    effect_span => 4, cancel_by => 0, triggered_by => 0, no_move => 'sub{$_[0]->isSmallerThanHalf()}', no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '‹°•|‚Å“®‚¯‚È‚¢' },
    18 => { array_order => 17,system_name => 'disconcent', short_label => '˜T', long_label => '˜T”‚',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    19 => { array_order => 18,system_name => 'fly',        short_label => '”ò', long_label => '”òs',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    20 => { array_order => 19,system_name => 'gravity',    short_label => 'd', long_label => 'd—Í',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    21 => { array_order => 20,system_name => 'glap',       short_label => '•ß', long_label => '•ß”›',    effect_span => 3, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    22 => { array_order => 21,system_name => 'gard',       short_label => 'Œì', long_label => '•ÛŒì',    effect_span => 3, cancel_by => 0, triggered_by => 3, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    23 => { array_order => 22,system_name => 'phaseout',   short_label => '—£', long_label => '—£’E',    effect_span => 2, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => 'Œ»‚ê‚½' },
    24 => { array_order => 23,system_name => 'reflect',    short_label => '”½', long_label => '”½ŽË',    effect_span => 3, cancel_by => 1, triggered_by => 3, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '”½ŽË‚µ‚½' },
    25 => { array_order => 24,system_name => 'wall',       short_label => '•Ç', long_label => 'á•Ç',    effect_span => 3, cancel_by => 1, triggered_by => 3, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '‘Å‚¿Á‚µ‚½' },
    26 => { array_order => 25,system_name => 'awake',      short_label => 'Šo', long_label => 'ŠoÁ',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
    27 => { array_order => 26,system_name => 'die',        short_label => '¨', long_label => '¨‡',    effect_span => 3, cancel_by => 0, triggered_by => 2, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '“|‚ê‚½' },
    28 => { array_order => 27,system_name => 'escape',     short_label => '“¦', long_label => '“¦‘–',    effect_span => 3, cancel_by => 0, triggered_by => 2, no_move => 'sub{1}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '“¦‚°o‚µ‚½' },
    29 => { array_order => 28,system_name => 'flip',       short_label => '“]', long_label => '”½“]',    effect_span => 1, cancel_by => 0, triggered_by => 0, no_move => 'sub{0}',                          no_target => 0, effect => 'sub{0}', enchant_effect => 'sub{0}', stat_msg => '' },
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
        # regist checkŒã‰ðŒˆ‘Ò‚¿‚¾‚¯‚ÇŠm’èÏ‚Ý‚ÌƒXƒe[ƒ^ƒX‚ðƒXƒ^ƒbƒN
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
