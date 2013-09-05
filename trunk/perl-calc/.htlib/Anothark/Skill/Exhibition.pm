package Anothark::Skill::Exhibition;
$|=1;
use strict;

use Anothark::Skill;
use base qw( Anothark::Skill );
our $skills = {
    zoom_punch => sub { zoom_punch(@_) },
    lost_memorys => sub { lost_memorys(@_) },
};

sub new
{
    my $class = shift;
    my $skill_name = shift;
    warn "Call Exhibision skill";
    my $self = $class->SUPER::new();
    bless $self, $class;


    $self->setup( $skill_name );
    return $self;
}

sub setup
{
    my $class = shift;
    my $skill_name = shift;
    $class->setup_options( &{$skills->{$skill_name}}() );
}

# 1:Œ•,2:’Æ,3:Žèb,4:‘„,5:•Ú,6:‹|,7:e,11:‰Š,12:—â,13:Œõ,14:ˆÅ,15:ŠyŠí,20:‚


sub zoom_punch
{
    return {
        skill_name => '½Þ°ÑÊßÝÁ',
        power_source => 0,
        skill_rate => 20 ,
        length_type => 2,
        random_type => 2,
        type_id => 3,
    };
}

sub lost_memorys
{
    return {
        skill_name => '‰“‚¢‹L‰¯',
        power_source => 0,
        skill_rate => 30 ,
        length_type => 3,
        range_type => 3,
        random_type => 2,
        type_id => 15,
        sub_type_id => 14,
        base_type  => 2,
        base_element => -1,
        sub_base_element => 14,
    };
}

1;
