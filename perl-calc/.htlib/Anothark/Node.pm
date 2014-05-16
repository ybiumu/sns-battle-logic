package Anothark::Node;
#
# ˆ¤
#
$|=1;
use strict;

use LoggingObjMethod;
use base qw( LoggingObjMethod );
sub new
{
    my $class   = shift;
    my $name    = shift || "unknown";
    my $options = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setNodeName($name);
    $self->setChildren([]);
    $self->setNodeId(0);
    $self->setScenarioId(0);
    $self->setNodeDescr("");
    $self->setNodeImg("");
    $self->setParentNodeId(0);
    $self->setUseLink(0);
    $self->setCanStay(0);
    $self->setLastUpdate('1970-01-01');



    $self->setup_options($options);

    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->debug("Call node init");
}

sub setup_options
{
    my $class = shift;
    my $options = shift;
    if( ref( $options ) eq "HASH" )
    {
        foreach my $key ( keys %{$options})
        {
            $class->{$key} = $options->{$key};
#            $class->warning( sprintf("[LIB] %s: %s",$key, $options->{$key}));
        }
    }
}






my $node_id = undef;
my $scenario_id = undef;
my $node_name = undef;
my $node_descr = undef;
my $node_img = undef;
my $parent_node_id = undef;
my $use_link = undef;
my $can_stay = undef;
my $last_update = undef;

my $children = undef;

my $field_names = undef;




sub setFieldNames
{
    my $class = shift;
    return $class->setAttribute( 'field_names', shift );
}

sub getFieldNames
{
    return $_[0]->getAttribute( 'field_names' );
}

sub setNodeId
{
    my $class = shift;
    return $class->setAttribute( 'node_id', shift );
}

sub getNodeId
{
    return $_[0]->getAttribute( 'node_id' );
}

sub setScenarioId
{
    my $class = shift;
    return $class->setAttribute( 'scenario_id', shift );
}

sub getScenarioId
{
    return $_[0]->getAttribute( 'scenario_id' );
}

sub setNodeName
{
    my $class = shift;
    return $class->setAttribute( 'node_name', shift );
}

sub getNodeName
{
    return $_[0]->getAttribute( 'node_name' );
}

sub setNodeDescr
{
    my $class = shift;
    return $class->setAttribute( 'node_descr', shift );
}

sub getNodeDescr
{
    return $_[0]->getAttribute( 'node_descr' );
}

sub setNodeImg
{
    my $class = shift;
    return $class->setAttribute( 'node_img', shift );
}

sub getNodeImg
{
    return $_[0]->getAttribute( 'node_img' );
}

sub setParentNodeId
{
    my $class = shift;
    return $class->setAttribute( 'parent_node_id', shift );
}

sub getParentNodeId
{
    return $_[0]->getAttribute( 'parent_node_id' );
}

sub setUseLink
{
    my $class = shift;
    return $class->setAttribute( 'use_link', shift );
}

sub getUseLink
{
    return $_[0]->getAttribute( 'use_link' );
}

sub setCanStay
{
    my $class = shift;
    return $class->setAttribute( 'can_stay', shift );
}

sub getCanStay
{
    return $_[0]->getAttribute( 'can_stay' );
}

sub setLastUpdate
{
    my $class = shift;
    return $class->setAttribute( 'last_update', shift );
}

sub getLastUpdate
{
    return $_[0]->getAttribute( 'last_update' );
}

sub setChildren
{
    my $class = shift;
    return $class->setAttribute( 'children', shift );
}

sub getChildren
{
    return $_[0]->getAttribute( 'children' );
}

sub appendChild
{
    push(@{$_[0]->getChildren()},$_[1]);
}

1;
