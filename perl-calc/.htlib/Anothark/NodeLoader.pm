package Anothark::NodeLoader;
#
# ˆ¤
#
$|=1;
use strict;


use LoggingObjMethod;
use Anothark::Node;
use DBI qw( SQL_INTEGER );
use base qw( LoggingObjMethod );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setDbHandler($db_handle);

    my $sql = "SELECT * FROM t_node_master WHERE node_id = ?";
    my $sth  = $db_handle->prepare($sql);
    $self->setSthNode($sth);


    my $sql_child = "SELECT node_id,node_name FROM t_node_master WHERE parent_node_id = ? AND node_id <> parent_node_id";
    my $sth_child  = $db_handle->prepare($sql_child);
    $self->setSthChild($sth_child);

    return $self;
}


my $db_handler = undef;

sub loadNode
{
    my $class = shift;
    my $node_id = 0;
    my $arg   = shift;
    my $ref = ref($arg);
    if ( $ref =~ /^Anothark::Node(|::.+)$/ )
    {
#        $arg->setNodeLoader($class);
#        $class->loadChild($arg);
        return $arg;
    }
    else
    {
        $node_id = $arg;
    }


    my $node = $class->loadNodeById($node_id);
    return $node; 
}


my $sth_node = undef;
my $sth_child = undef;
sub setSthNode
{
    my $class = shift;
    return $class->setAttribute( 'sth_node', shift );
}

sub getSthNode
{
    return $_[0]->getAttribute( 'sth_node' );
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


sub loadNodeById
{
    my $class     = shift;
    my $node_id = shift;
    my $node = undef;

#    my $sql = "SELECT * FROM t_node_master WHERE node_id = ?";
#    my $sth  = $class->getDbHandler()->prepare($sql);
    my $sth = $class->getSthNode();
    my $stat = $sth->execute(($node_id));
    if ( $sth->rows > 0 )
    {
#        $class->warning( "Find record for $node_id");
        $node  = new Anothark::Node( "", $sth->fetchrow_hashref());
        $node->setFieldNames( $sth->{"NAME"}  );
#        $node->setNodeLoader($class);
        $class->loadChild($node);
    }
    else
    {
#        $class->warning( "No record for $node_id");
        $node = new Anothark::Node();
    }
#    $sth->finish();

    return $node; 
}

sub loadChild
{
    my $class = shift;
    my $parent_node = shift;
    my $parent_node_id = $parent_node->getNodeId();
    my $stat = $class->getSthChild()->execute($parent_node_id);

    if ( $class->getSthChild()->rows > 0)
    {
        my $children = $class->getSthChild()->fetchall_hashref("node_id");
        foreach my $child_node_id ( sort {$children->{$a} <=> $children->{$b} } keys %{$children} )
        {
            $class->debug("Load node[$child_node_id]");
            $parent_node->appendChild( $class->loadNode( $child_node_id ) );
        }
    }
}

sub getNodeList
{
    my $class = shift;
    my $offset = shift || 0;

    my $sql = "SELECT SQL_CALC_FOUND_ROWS node_id,node_name FROM t_node_master LIMIT 20 OFFSET ?";
    my $sth  = $class->getDbHandler()->prepare($sql);
    $sth->bind_param(1, (0 + 20 * $offset), { TYPE => SQL_INTEGER} );
    my $stat = $sth->execute();
    my $sth_rows  = $class->getDbHandler()->prepare("SELECT FOUND_ROWS() FROM DUAL");
    $sth_rows->execute();
    my $row_size = $sth_rows->fetchrow_array();
    $sth_rows->finish();

    $class->setMaxRow( $row_size );

    my $node_list = [];

    if ( $sth->rows > 0 )
    {
        $node_list = $sth->fetchall_hashref(("node_id"));
    }
    $sth->finish();
    return $node_list;
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
    $class->getSthNode()->finish();
    $class->getSthChild()->finish();
}


sub setMaxRow
{
    my $class = shift;
    return $class->setAttribute( 'max_row', shift );
}

sub getMaxRow
{
    return $_[0]->getAttribute( 'max_row' );
}


1;
