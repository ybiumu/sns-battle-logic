package Anothark::SkillLoader;
#
# ��
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
    my $skill_id = shift;

    my $skill = {};

    my $sql = "SELECT * FROM t_skill_master WHERE skill_id = ?";
    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($skill_id));
    if ( $sth->rows > 0 )
    {
#        warn "Find record for $skill_id";
        $skill  = new Anothark::Skill( "", $sth->fetchrow_hashref());
        $skill->setFieldNames( $sth->{"NAME"}  );
    }
    else
    {
#        warn "No record for $skill_id";
        $skill = new Anothark::Skill();
    }
    $sth->finish();

    return $skill; 
}

sub getSkillList
{
    my $class = shift;
    my $offset = shift || 0;

    my $sql = "SELECT skill_id,skill_name FROM t_skill_master LIMIT ?,20";
    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($offset));

    my $skill_list = [];

    if ( $sth->rows > 0 )
    {
        $skill_list = $sth->fetchall_hashref(("skill_id"));
    }
    $sth->finish();
    return $skill_list;
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
