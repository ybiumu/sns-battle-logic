package Anothark::EnemyPartyLoader;
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

use Anothark::SkillLoader;
use Anothark::BattleSetting;

use DBI qw( SQL_INTEGER );
use base qw( Anothark::PartyLoader );

=pod
 Sns part.
=cut

my $sql_get_party_invitation = "";
my $sql_do_invite = "";
my $sql_update_party_name = "";
my $sql_do_join = "";
my $sql_clear_invite = "";
my $sql_reject_invite = "";
my $sql_get_invited = "";

sub isNotRunFirst
{
    my $class = shift;
    return 1;
}

sub notInvited
{
    return 1;
}

sub getPartyInvitation
{
    return 0;
}

sub getPartyInvitationRecord
{
    return 0;
}


sub getPartyInvitationNumber
{
    return 0;
}


sub invite
{
    return 0;
}

sub acceptInvite
{
    return 0;
}


sub rejectInvite
{
    return 0;
}


sub clearInvite
{
    return 0;
}

=pod
 Sns part end.
=cut

sub getMemberSql
{
    my $class = shift;
    return "";
}

my $npc_sql = "SELECT npc_id,party_sequence,enemy_label,position_code FROM t_enemy_party WHERE enemy_party_id = ? ORDER BY party_sequence";

sub getNpcSql
{
    my $class = shift;
    return $npc_sql;
}

sub new
{
    my $class = shift;
    my $at    = shift;
    my $simple = shift || 0;
    my $self = $class->SUPER::new( $at, $simple );
    bless $self, $class;


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
# XXX for result use.
sub loadBattlePartyByUser
{
    my $class   = shift;
    my $user    = shift;
    my $side    = shift;
    my $party   = shift || new Anothark::Party(); # template指定
    $party = $class->loadPartyByUserId( $user->getOwnerId(), $party , 1);

#    $party->setValueToMembers( 'side',  $side);
    $party->execToMembers( 'setSide', $side );

    return $party;
}


# not use result
sub loadPartyByUser
{
    my $class   = shift;
    my $user    = shift;
    my $party   = shift || new Anothark::Party(); # template指定
    $party = $class->loadPartyByUserId( $user->getOwnerId(), $party , 0);

#    $party->setValueToMembers( 'side',  $side);
#    $party->execToMembers( 'setSide', $side );

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

sub checkPartyStatus
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;

    my $sql = "
        SELECT
            COUNT(m.user_id) AS result
        FROM
            t_user AS u
            LEFT JOIN
            t_user AS m
            ON( u.owner_id = m.user_id OR ( u.owner_id = 0 AND u.user_id = m.user_id) )
        WHERE
            u.user_id IN ( ?,? )
        GROUP BY m.user_id
        HAVING COUNT(m.user_id) > 1 ";


    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($src_user_id, $dst_user_id));
    my $row  = $sth->fetchrow_hashref();
    if ( $sth->rows() == 0 )
    {
        $class->notice("No party relation between $src_user_id and $dst_user_id.");
        $sth->finish();
        return 0;
    }
    else
    {
        $sth->finish();
        return $row->{result};
    }
}

sub isPartyMember
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;
    return $class->checkPartyStatus( $src_user_id, $dst_user_id);
}


sub loadPartyByUserId
{
    my $class   = shift;
    my $user_id = shift;
    my $party   = shift || new Anothark::Party();
    my $is_battle = shift || 0;

    my $at = $class->getAt();

    my $sth = $class->getSthParty();
    my $stat = $sth->execute(($user_id));
    if ( $sth->rows > 0 )
    {
        my $members = $sth->fetchall_arrayref( +{} );
        $party->setPartyName( $members->[0]->{"party_name"} );
        $party->setOwnerId( $members->[0]->{"owner_id"} );
        my $num = 1;
        if ( $is_battle )
        {
            foreach my $member ( @{$members} )
            {
                my $tmp_char = $at->getBattlePlayerByUserId( $member->{user_id} );
                $tmp_char->setSkills( $class->getBattleSetting(), $class->getSkillLoader());
                $party->{"member" . $num++} = $tmp_char;
            }
        }
        else
        {
            foreach my $member ( @{$members} )
            {
                my $tmp_char = $at->getPlayerByUserId( $member->{user_id} );
                $party->{"member" . $num++} = $tmp_char;
            }
        }

    }

    my $sth_npc   = $class->getSthNpc();
    $stat = $sth_npc->execute(($user_id));
    if ( $sth_npc->rows > 0 )
    {
        my $npcs = $sth_npc->fetchall_arrayref( +{} );
        my $num = 1;
        if ( $is_battle )
        {
            foreach my $npc ( @{$npcs} )
            {
                my $tmp_char = new Anothark::Character::Npc( $npc );
                $tmp_char->setSkills( $class->getBattleSetting(), $class->getSkillLoader());
            }
        }
        else
        
            foreach my $npc ( @{$npcs} )
            {
                my $tmp_char = new Anothark::Character::Npc( $npc->{npc_id} );
            }
        }

    }
    return $party; 
}

sub change
{
    my $class = shift;
    my $user  = shift;
    my $name  = shift;
    $class->changeById($user->getId(), $name);
}


sub changeById
{
    my $class    = shift;
    my $user_id  = shift;
    my $name     = shift;


    my $db_handle = $class->getDbHandler();

    my $sth  = $db_handle->prepare($sql_update_party_name);
    $sth->execute(($name,$user_id));
    $sth->finish();
}

sub leave
{
    my $class = shift;
    my $user  = shift;
    $class->leaveById($user->getId());
}

sub leaveById
{
    my $class    = shift;
    my $user_id  = shift;


    my $db_handle = $class->getDbHandler();

    my $sql_leave = "UPDATE t_user AS u SET owner_id = 0 WHERE user_id = ? ";
    my $sth  = $db_handle->prepare($sql_leave);
    $sth->execute(($user_id));
    $sth->finish();
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
