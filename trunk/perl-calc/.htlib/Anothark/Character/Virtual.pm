package Anothark::Character::Virtual;

#
# ˆ¤
#

$|=1;
use strict;

use Anothark::Character;
use base qw( Anothark::Character );


use Anothark::ValueObject;
use Anothark::Skill;

our @copy_target = (
    "hp",
    "stamina",
    "atack",
    "magic",
    "def",
    "rp",
    "agl",
    "luck",
    "kehai",
    "chikaku",
    "kikyou",
    "chrm",
);



sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->debug( "Call virtual");
    bless $self, $class;

    return $self;
}


sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->debug( "Call child init");
    $class->setTemplate("virtual");

    $class->setSameCmd(
        new Anothark::Skill( '‘Ì“–‚½‚è'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
    );

}

sub setSameCmd
{
    my $class = shift;
    my $skill = shift;
    $class->setCmd([
        [],
        $skill,$skill,$skill,$skill,$skill
    ]);

}

sub setBaseChar
{
    my $class = shift;
    my $char  = shift;

    foreach my $key ( @copy_target )
    {
        $class->error("[Virtual] key: $key");
        $class->{$key}->setCurrentValue( $char->{$key}->getCurrentValue() );
        $class->{$key}->setMaxValue( $char->{$key}->getMaxValue() );
    }
    $class->setSide( $char->getSide() );
}



1;

