package Anothark::SkillLoader;
#
# ˆ¤
#
$|=1;
use strict;


use ObjMethod;
use Anothark::Skill;
use base qw( ObjMethod );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setDbHandler($db_handle);
    return $self;
}


my $db_handler = undef;

sub loadSkill
{
    my $class = shift;
    my $skill_id = shift:

    my $skill = {};

    my $sql = "SELECT * FROM t_skill_master WHERE skill_id = ?";
    my $sth  = $db->prepare($sql);
    my $stat = $sth->execute(($skill_id));
    if ( $sth->rows > 0 )
    {
        $skill  = new Anothark::Skill($sth->fetchrow_hashref());
    }
    else
    {
        $skill = new Anothark::Skill();
    }
    $sth->finish();

    return $skill; 
}


sub setDbHandler
{
    my $class = shift;
    return $class->setAttribute( 'db_handler', shift );
}

sub getDbHandler
{
    return $_[0]->getAttribute( 'db_handler' );
}





1;
