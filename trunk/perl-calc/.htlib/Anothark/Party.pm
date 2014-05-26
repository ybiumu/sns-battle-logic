package Anothark::Party;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use base qw( LoggingObjMethod );

my $status = undef;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    return $self;
}


sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->warning( "Call init");
    $class->setMembers({
        member1 => $class->{"member1"} ,
        member2 => $class->{"member2"} ,
        member3 => $class->{"member3"} ,
        member4 => $class->{"member4"} ,
        npc1    => $class->{"npc1"}    ,
        npc2    => $class->{"npc2"}    ,
        npc3    => $class->{"npc3"}    ,
    });
}

sub getPartyCharacter
{
    my $class = shift;
    return map{ $class->{$_} } grep { $class->{$_} } sort keys %{$class->getMembers()};
}


sub execToMembers
{
    my $class  = shift;
    my $func   = shift;
    my $value  = shift;
    map {
        my $char = $_;
        $class->error(sprintf("[CHAR] %s", ref $char ));
        $class->error(sprintf("[FUNC] %s", $func));
        eval "\$char->$func( \$value );";
    } $class->getPartyCharacter();
}
# TODO make a LoadParty class
# TODO make a JoinPartyTicket class
# TODO make a ReclutParty class
# TODO construct elements
# 
# owner_id = party_id
# party_name
# @member 
#
#
#


my $party_name = undef;
my $party_id = undef;
my $members = undef;

sub setOwnerId
{
    my $class = shift;
    return $class->setPartyId( shift );
}

sub getOwnerId
{
    return $_[0]->getOwnerId();
}

sub setPartyId
{
    my $class = shift;
    return $class->setAttribute( 'party_id', shift );
}

sub getPartyId
{
    return $_[0]->getAttribute( 'party_id' );
}

sub setPartyName
{
    my $class = shift;
    return $class->setAttribute( 'party_name', shift );
}

sub getPartyName
{
    return $_[0]->getAttribute( 'party_name' );
}

sub setMembers
{
    my $class = shift;
    return $class->setAttribute( 'members', shift );
}

sub getMembers
{
    return $_[0]->getAttribute( 'members' );
}



my $member1 = undef;
sub setMember1
{
    my $class = shift;
    return $class->setAttribute( 'member1', shift );
}

sub getMember1
{
    return $_[0]->getAttribute( 'member1' );
}


my $member2 = undef;
sub setMember2
{
    my $class = shift;
    return $class->setAttribute( 'member2', shift );
}

sub getMember2
{
    return $_[0]->getAttribute( 'member2' );
}


my $member3 = undef;
sub setMember3
{
    my $class = shift;
    return $class->setAttribute( 'member3', shift );
}

sub getMember3
{
    return $_[0]->getAttribute( 'member3' );
}

my $member4 = undef;
sub setMember4
{
    my $class = shift;
    return $class->setAttribute( 'member4', shift );
}

sub getMember4
{
    return $_[0]->getAttribute( 'member4' );
}

my $npc1 = undef;
sub setNpc1
{
    my $class = shift;
    return $class->setAttribute( 'npc1', shift );
}

sub getNpc1
{
    return $_[0]->getAttribute( 'npc1' );
}

my $npc2 = undef;
sub setNpc2
{
    my $class = shift;
    return $class->setAttribute( 'npc2', shift );
}

sub getNpc2
{
    return $_[0]->getAttribute( 'npc2' );
}

my $npc3 = undef;
sub setNpc3
{
    my $class = shift;
    return $class->setAttribute( 'npc3', shift );
}

sub getNpc3
{
    return $_[0]->getAttribute( 'npc3' );
}


1;
