package Anothark::Skill;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );
sub new
{
    my $class = shift;
    my $name = shift || "ÊßÝÁ";
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setName($name);

    return $self;
}


my $name = undef;
sub setName
{
    my $class = shift;
    return $class->setAttribute( 'name', shift );
}

sub getName
{
    return $_[0]->getAttribute( 'name' );
}



1;
