package Anothark::PartyLoader;
#
# 愛
#
$|=1;
use strict;


use Anothark::BaseLoader;
use Anothark::Character::Player;
use Anothark::Character::Npc;
use Anothark::Character::Enemy;
use Anothark::Party;
use DBI qw( SQL_INTEGER );
use base qw( Anothark::BaseLoader );
sub new
{
    my $class = shift;
    my $at    = shift;
    my $db_handle = $at->getDbHandler();
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;
    $self->setAt($at);

    my $sql_member = "SELECT u.party_name, m.user_id,m.owner_id FROM t_user AS u LEFT JOIN t_user AS m ON( u.user_id = m.owner_id OR u.user_id = m.user_id ) WHERE u.user_id = ? ORDER BY m.user_id";
    my $sth  = $db_handle->prepare($sql_member);
    $self->setSthParty($sth);

    # NPC is party owners.
    my $sql_npc    = "SELECT npc1,npc2,npc3 FROM t_party_npc WHERE owner_id = ?";
    my $sth_npc  = $db_handle->prepare($sql_npc);
    $self->setSthNpc($sth_npc);

    return $self;
}



# メンバー取得だけ
# スキルも
#sub loadParty
#{
#    my $class = shift;
#    my $owner_id = shift;
#    my $party = new Anothark::Party();
#    my $arg   = shift;
#    my $ref = ref($arg);
#    if ( $ref =~ /^Anothark:Party(|::.+)$/ )
#    {
#
#        return $arg;
#    }
#    else
#    {
#        return undef;
#    }
#}

# メンバー取得
# スキル取得
# あとは・・？
sub loadBattlePartyByUser
{
    my $class   = shift;
    my $user    = shift;
    my $side    = shift;
    my $party   = shift || new Anothark::Party();
    $party = $class->loadPartyByUserId( $user->getOwnerId(), $party );

#    $party->setValueToMembers( 'side',  $side);
    $party->execToMembers( 'setSide', $side );

    return $party;
}


sub loadEnemyParty
{
    my $class = shift;
    my $enemy_party_id = shift;
}


my $sth_party = undef;
my $sth_npc = undef;
sub setSthParty
{
    my $class = shift;
    return $class->setAttribute( 'sth_party', shift );
}

sub getSthParty
{
    return $_[0]->getAttribute( 'sth_party' );
}

sub setSthNpc
{
    my $class = shift;
    return $class->setAttribute( 'sth_npc', shift );
}

sub getSthNpc
{
    return $_[0]->getAttribute( 'sth_npc' );
}


sub loadPartyByUserId
{
    my $class   = shift;
    my $user_id = shift;
    my $party   = shift || new Anothark::Party();

    my $at = $class->getAt();

    my $sth = $class->getSthParty();
    my $stat = $sth->execute(($user_id));
    if ( $sth->rows > 0 )
    {
        my $members = $sth->fetchall_arrayref( +{} );
        my $num = 1;
        foreach my $member ( @{$members} )
        {
            my $tmp_char = $at->getBattlePlayerByUserId( $member->{user_id} );
            $tmp_char->setSkills( $class->getBattleSetting(), $class->getSkillLoader());
            $party->{"member" . $num++} = $tmp_char;
        }

    }

    my $sth_npc   = $class->getSthNpc();
    $stat = $sth_npc->execute(($user_id));
    if ( $sth_npc->rows > 0 )
    {
        my $npcs = $sth_npc->fetchall_arrayref( +{} );
        my $num = 1;
        foreach my $npc ( @{$npcs} )
        {
            my $tmp_char = new Anothark::Character::Npc( "", $npc );
            $tmp_char->setSkills( $class->getBattleSetting(), $class->getSkillLoader());
            $party->{"npc" . $num++} = $tmp_char;
        }

    }
    return $party; 
}





sub finish
{
    my $class = shift;
    $class->getSthParty()->finish();
    $class->getSthNpc()->finish();
}



my $skill_loader = undef;
my $battle_setting = undef;

sub setSkillLoader
{
    my $class = shift;
    return $class->setAttribute( 'skill_loader', shift );
}

sub getSkillLoader
{
    return $_[0]->getAttribute( 'skill_loader' );
}


sub setBattleSetting
{
    my $class = shift;
    return $class->setAttribute( 'battle_setting', shift );
}

sub getBattleSetting
{
    return $_[0]->getAttribute( 'battle_setting' );
}


my $at = undef;
sub setAt
{
    my $class = shift;
    return $class->setAttribute( 'at', shift );
}

sub getAt
{
    return $_[0]->getAttribute( 'at' );
}



1;
