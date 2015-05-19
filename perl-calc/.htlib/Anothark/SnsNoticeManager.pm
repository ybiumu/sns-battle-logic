package Anothark::SnsNoticeManager;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::BaseLoader;
use base qw( Anothark::BaseLoader );

use Anothark::PartyLoader;
use Anothark::FollowingManager;

=pod
* Usse tables

    t_follows
    SELECT SUM( CASE WHEN user_id = ? THEN 1 WHEN follow_user_id = ? THEN 2 ELSE 0 END ) AS mask FROM t_follows WHERE ? IN (user_id,follow_user_id) AND ? IN (user_id,follow_user_id) ;

--    t_party_entry


    t_party_invitation
    SELECT * FROM t_party_invitation WHERE user_id = ?;

=cut

sub new
{
    my $class = shift;
    my $at = shift;
    my $db_handle = $at->getDbHandler();
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;
    $self->setAt($at);
    $self->postInit();

    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
}


sub postInit
{
    my $class = shift;

    $class->setPartyLoader( new Anothark::PartyLoader( $class->getAt(), 1) );
    $class->setFollowingManager( new Anothark::FollowingManager( $class->getDbHandler()) );
}


sub hasNotice
{
    my $class = shift;
    my $user_id = shift;

    my $result = $class->pl()->getPartyInvitationNumber($user_id) + $class->fm()->getFollowRequestNumber($user_id);
    return $result;
}

my $at = undef;
my $party_loader = undef;
my $following_manager = undef;
sub setAt
{
    my $class = shift;
    return $class->setAttribute( 'at', shift );
}

sub getAt
{
    return $_[0]->getAttribute( 'at' );
}

sub setPartyLoader
{
    my $class = shift;
    return $class->setAttribute( 'party_loader', shift );
}

sub pl
{
    return $_[0]->getPartyLoader();
}

sub getPartyLoader
{
    return $_[0]->getAttribute( 'party_loader' );
}

sub fm
{
    return $_[0]->getFollowingManager();
}

sub setFollowingManager
{
    my $class = shift;
    return $class->setAttribute( 'following_manager', shift );
}

sub getFollowingManager
{
    return $_[0]->getAttribute( 'following_manager' );
}


1;
