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

use Anothark::SkillLoader;
use Anothark::BattleSetting;

use DBI qw( SQL_INTEGER );
use base qw( Anothark::BaseLoader );



my $sql_get_party_invitation = "
SELECT
    call.user_id AS invite_user_id,
    main.message,
    call.user_name
FROM
    t_party_invitation AS main
    JOIN
    t_user AS `call`
    ON (
        main.call_user_id = call.user_id
    )
WHERE
    main.user_id = ?
";


my $sql_do_invite = "
INSERT IGNORE INTO t_party_invitation(call_user_id, owner_id, user_id, message )
SELECT
    user_id AS call_user_id,
    IF(owner_id = 0,user_id, owner_id ) AS owner_id,
    ? AS user_id,
    'invited.' AS message
FROM 
    t_user
WHERE
    user_id = ?
;
";

my $sql_do_join = "
UPDATE
    t_user AS main
    JOIN
    t_party_invitation AS invite
    USING( user_id )
    JOIN
    t_user AS `call`
    ON(
        invite.call_user_id = call.user_id
    )
SET
    main.owner_id = invite.owner_id
WHERE
    main.user_id = ?
    AND
    call.user_id = ?
";

my $sql_clear_invite = "DELETE FROM t_party_invitation WHERE user_id = ?";
my $sql_reject_invite = "DELETE FROM t_party_invitation WHERE user_id = ? AND call_user_id = ?";

my $sql_get_invited = "SELECT 1 FROM t_party_invitation WHERE user_id = ? AND call_user_id = ?";

sub isNotRunFirst
{
    my $class = shift;
    return 1;
}
sub notInvited
{
    my $class = shift;
    my $call_user_id  = shift;
    my $user_id       = shift;
    $class->warning("[NOT INVITED] $call_user_id/$user_id");

    my $sth  = $class->getDbHandler()->prepare($sql_get_invited);
    my $stat = $sth->execute(($user_id,$call_user_id));
    my $rows = $sth->rows();
    $sth->finish();

    if ( $rows > 0 )
    {
        return 0;
    }
    return 1;
}

sub getPartyInvitation
{
    my $class = shift;
    my $user_id = shift;
    my $flag  = shift;

    my $sth  = $class->getDbHandler()->prepare($sql_get_party_invitation);
    my $stat = $sth->execute(($user_id));
    if ($flag)
    {
        my $rows  = $sth->fetchall_arrayref( +{} );
        return $rows;
    }
    else
    {
        return $sth->rows();
    }
}

sub invite
{
    my $class = shift;
    my $user_id = shift;
    my $target_user_id = shift;

    my $sth  = $class->getDbHandler()->prepare($sql_do_invite);
    my $stat = $sth->execute(($target_user_id, $user_id));
    $sth->finish();
}

sub acceptInvite
{
    my $class = shift;
    my $user_id = shift;
    my $call_user_id = shift;

    my $sth  = $class->getDbHandler()->prepare($sql_do_join);
    my $stat = $sth->execute(($user_id, $call_user_id));
    $sth->finish();
    $class->clearInvite($user_id);
}


sub rejectInvite
{
    my $class = shift;
    my $user_id = shift;
    my $call_user_id = shift;

    my $sth  = $class->getDbHandler()->prepare($sql_reject_invite);
    my $stat = $sth->execute(($user_id, $call_user_id));
    $sth->finish();
}


sub clearInvite
{
    my $class = shift;
    my $user_id = shift;

    my $sth  = $class->getDbHandler()->prepare($sql_clear_invite);
    my $stat = $sth->execute(($user_id));
    $sth->finish();
}


sub new
{
    my $class = shift;
    my $at    = shift;
    my $simple = shift || 0;
    my $db_handle = $at->getDbHandler();
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;
    $self->setAt($at);

    if( not $simple )
    {
        my $sql_member = "SELECT u.party_name, m.user_id,m.owner_id FROM t_user AS u LEFT JOIN t_user AS m ON( u.user_id = m.owner_id OR u.user_id = m.user_id ) WHERE u.user_id = ? ORDER BY m.user_id";
        my $sth  = $db_handle->prepare($sql_member);
        $self->setSthParty($sth);

        # NPC is party owners.
#    my $sql_npc    = "SELECT npc1,npc2,npc3 FROM t_party_npc WHERE owner_id = ?";
        my $sql_npc    = "SELECT npc_id,join_datetime,limit_datetime FROM t_party_npc WHERE owner_id = ? ORDER BY join_datetime";
        my $sth_npc  = $db_handle->prepare($sql_npc);
        $self->setSthNpc($sth_npc);


        my $sl = new Anothark::SkillLoader($db_handle);
        $self->setSkillLoader($sl);
        my $bs = new Anothark::BattleSetting($db_handle);
        $self->setBattleSetting($bs);

    }

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
                my $tmp_char = new Anothark::Character::Npc( "", $npc->{npc_id} );
                $tmp_char->setSkills( $class->getBattleSetting(), $class->getSkillLoader());
                $party->{"npc" . $num++} = $tmp_char;
            }
        }
        else
        {
            foreach my $npc ( @{$npcs} )
            {
                my $tmp_char = new Anothark::Character::Npc( "", $npc->{npc_id} );
                $party->{"npc" . $num++} = $tmp_char;
            }
        }

    }
    return $party; 
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
