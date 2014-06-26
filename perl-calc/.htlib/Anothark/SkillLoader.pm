package Anothark::SkillLoader;
#
# ˆ¤
#
$|=1;
use strict;


use Anothark::BaseLoader;
use Anothark::Skill;
use base qw( Anothark::BaseLoader );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;

    my $sql = "SELECT * FROM t_skill_master WHERE skill_id = ?";
    my $sth  = $db_handle->prepare($sql);
    $self->setSthSkill($sth);


    my $sql_child = "SELECT skill_id,sequence_id FROM t_skill_master WHERE parent_skill_id = ?";
    my $sth_child  = $db_handle->prepare($sql_child);
    $self->setSthChild($sth_child);

    return $self;
}


my $db_handler = undef;

sub loadSkill
{
    my $class = shift;
    my $skill_id = 0;
    my $arg   = shift;
    my $ref = ref($arg);
    if ( $ref =~ /^Anothark::Skill(|::.+)$/ )
    {
#        $arg->setSkillLoader($class);
#        $class->loadChild($arg);
        return $arg;
    }
    else
    {
        $skill_id = $arg;
    }


    my $skill = $class->loadSkillById($skill_id);
    return $skill; 
}


my $sth_skill = undef;
my $sth_child = undef;
sub setSthSkill
{
    my $class = shift;
    return $class->setAttribute( 'sth_skill', shift );
}

sub getSthSkill
{
    return $_[0]->getAttribute( 'sth_skill' );
}

sub setSthChild
{
    my $class = shift;
    return $class->setAttribute( 'sth_child', shift );
}

sub getSthChild
{
    return $_[0]->getAttribute( 'sth_child' );
}


sub loadSkillById
{
    my $class     = shift;
    my $skill_id = shift;
    my $skill = undef;

#    my $sql = "SELECT * FROM t_skill_master WHERE skill_id = ?";
#    my $sth  = $class->getDbHandler()->prepare($sql);
    my $sth = $class->getSthSkill();
    my $stat = $sth->execute(($skill_id));
    if ( $sth->rows > 0 )
    {
#        $class->warning( "Find record for $skill_id");
        $skill  = new Anothark::Skill( "", $sth->fetchrow_hashref());
        $skill->setFieldNames( $sth->{"NAME"}  );
#        $skill->setSkillLoader($class);
        $class->loadChild($skill);
    }
    else
    {
#        $class->warning( "No record for $skill_id");
        $skill = new Anothark::Skill();
    }
#    $sth->finish();

    return $skill; 
}

sub loadChild
{
    my $class = shift;
    my $parent_skill = shift;
    my $parent_skill_id = $parent_skill->getSkillId();
    my $stat = $class->getSthChild()->execute($parent_skill_id);

    if ( $class->getSthChild()->rows > 0)
    {
        my $children = $class->getSthChild()->fetchall_hashref("sequence_id");
        foreach my $child_skill_id ( map {$children->{$_}->{skill_id}} sort {$children->{$a} <=> $children->{$b} } keys %{$children} )
        {
            $parent_skill->appendChild( $class->loadSkill( $child_skill_id ) );
        }
    }
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


sub finish
{
    my $class = shift;
    $class->getSthSkill()->finish();
    $class->getSthChild()->finish();
}



1;
