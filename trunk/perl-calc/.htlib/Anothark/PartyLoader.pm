package Anothark::PartyLoader;
#
# 愛
#
$|=1;
use strict;


use LoggingObjMethod;
use Anothark::Character::Player;
use Anothark::Character::Npc;
use Anothark::Character::Enemy;
use Anothark::Party;
use DBI qw( SQL_INTEGER );
use base qw( LoggingObjMethod );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setDbHandler($db_handle);

    my $sql_member = "SELECT m.user_id,m.owner_id FROM t_uesr_party AS u JOIN t_user_party AS m USING(owner_id) WHERE u.user_id = ? ORDER BY m.user_id";
    my $sth  = $db_handle->prepare($sql_member);
    $self->setSthParty($sth);

    # NPC is party owners.
    my $sql_npc    = "SELECT npc1,npc2,npc3 FROM t_party_npc WHERE owner_id = ?";
    my $sth_npc  = $db_handle->prepare($sql_npc);
    $self->setSthNpc($sth_npc);

    return $self;
}


my $db_handler = undef;

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
sub loadBattlePartyByUserId
{
    my $class = shift;
    my $user_id = shift;
    my $side    = shift;
    my $party   = shift || new Anothark::Party();
    $party = $class->loadPartyByUserId( $user_id, $party );

    $party->setValueToMembers( 'side',  $side);

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

    my $sth = $class->getSthParty();
    my $stat = $sth->execute(($user_id));
    if ( $sth->rows > 0 )
    {
        my $members = $sth->fetchall_arrayref( +{} );
        my $num = 1;
        foreach my $member ( @{$members} )
        {
            $party->{"member" . $num++} = new Anothark::Character::Player( "", $member );
        }

    }

    my $sth_npcs   = $class->getSthNpc();
    $stat = $sth_npc->execute(($user_id));
    if ( $sth_npc->rows > 0 )
    {
        my $npcs = $sth_npc->fetchall_arrayref( +{} );
        my $num = 1;
        foreach my $npc ( @{$npcs} )
        {
            $party->{"npc" . $num++} = new Anothark::Character::Npc( "", $npc );
        }

    }
    return $party; 
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


sub finish
{
    my $class = shift;
    $class->getSthParty()->finish();
    $class->getSthNpc()->finish();
}




1;
