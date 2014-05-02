#!/usr/bin/perl
############
### LOAD ###
############
use lib qw( .htlib ../../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::NodeLoader;
use Anothark::Node;

use Anothark::BoardManager;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

my $ad_str = "";


my $selects = {
    'use_link' => [0,1],
    'can_stay' => [0,1],
};

my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();


##################
### init check ###
##################
my $result = $at->setupBaseData();
if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}




our $out = $at->getOut();
#unless ( $out->{GM} )
#{
#    print $c->header( -status=>"404 Not found" );
#    exit 1;
#}


my $board = new Anothark::BoardManager($db);

##############
### depend ###
##############
$at->setBody("body_edit_node.html");
$at->setPageName("ä«óù - …∞ƒﬁä«óù");
my $version = "0.1a20130415";



############
### Main ###
############

my $node_id = $c->param("node_id") || 0;

#my $sql = "SELECT * FROM t_node_master WHERE node_id = ?";
#my $sth  = $db->prepare($sql);
#my $stat = $sth->execute(($node_id));

my $sl = new Anothark::NodeLoader( $db );

my $node = $sl->loadNode($node_id);

$out->{RESULT_TITLE} = "ä«óù - …∞ƒﬁä«óù";
my $lines = 0;

if ( $node->getNodeId() > 0 )
{


    $out->{RESULT} = "<form name=\"node\" method=\"get\" action=\"edit_node.cgi\">\n";
#    my $row  = $sth->fetchrow_hashref();
#    my $names = $sth->{'NAME'};
    map { $out->{$_} = $node->{$_};} @{$node->getFieldNames()};

    # Joined Scenario check
    my $sql_scenario = "SELECT scenario_id, scenario_name FROM t_scenario_master ORDER BY scenario_id";
    my $scenario_id  = $db->selectall_hashref($sql_scenario, "scenario_id");
    $out->{select_str_scenario_id} = join ("",
        map {
            sprintf(qq[<option value="%s"%s>(%s)%s</option>], $_ , ( ( $c->param("act") ne "descr" ? $c->param("scenario_id") : $out->{"scenario_id"}) eq $_ ? $pu->getSelectedStr() : "" ) ,$_ , $scenario_id->{$_}->{scenario_name})
        } sort  keys %{$scenario_id}
    );

    # Joined node check
    my $sql_parent_node = "SELECT node_id, node_name FROM t_node_master ORDER BY node_id";
    my $parent_node_id  = $db->selectall_hashref($sql_parent_node, "node_id");
    $out->{select_str_parent_node_id} = join ("",
        map {
            sprintf(qq[<option value="%s"%s>(%s)%s</option>], $_ , ( ( $c->param("act") ne "descr" ? $c->param("parent_node_id") : $out->{"parent_node_id"}) eq $_ ? $pu->getSelectedStr() : "" ) ,$_ , $parent_node_id->{$_}->{node_name})
        } sort { $a <=> $b } keys %{$parent_node_id}
    );

    # Boad exists check.
    my $boards = $board->getNodeBoard( $node_id );
    $out->{stat_board} = join( "",
        map {
            sprintf('Å@%s: %s(<a href="adm_view_bbs.cgi?guid=ON&bid=%s">%s</a>)<br />',Anothark::BoardManager->BOARD_TYPE_NAME->{$_}, defined $boards->{$_} ? ( "Åõ", $boards->{$_}, $boards->{$_}) : ("Å~", "0", "-" ) )
        } sort keys %{$boards}
    );

    if ( $c->param("act") eq "saveconfirm" )
    {
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
            $out->{ "_".$select_element } = { map { ( $_ => ( $c->param($select_element) eq $_ ? $pu->getSelectedStr() : "" ) ) } @{$selects->{$select_element}}};
        }
        foreach my $key ( @{$node->getFieldNames()} )
        {
            if ( $c->param($key) ne undef )
            {
                if ( $node->{$key} ne $c->param($key) )
                {
                    $out->{"difference"} .= sprintf("Å@%s:%s->%s<br />\n", $key,$node->{$key},$c->param($key));
                    $out->{"save_form"}  .= sprintf(qq[<input type="hidden" name="%s" value="%s"/>], $key, $c->param($key));
                    $out->{$key} = $c->param($key);
                }
            }
        }
        if ( $out->{"difference"} ne "" )
        {
            $out->{"save_form"}  = '<input type="submit" value="save" />';
        }
    }
    elsif ( $c->param("act") eq "save" )
    {
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        # Do Update!
        foreach my $select_element (keys %{$selects})
        {
#            $out->{ "_".$select_element } = { map { ( $_ => ( $c->param($select_element) eq $_ ? $pu->getSelectedStr() : "" ) ) } @{$selects->{$select_element}}};
            $out->{ "_".$select_element } = { map { ( $_ => ( $out->{$select_element} eq $_ ? $pu->getSelectedStr() : ""  ) ) } @{$selects->{$select_element}}};
        }
    }
    else
    {
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
#            $out->{ "_".$select_element } = { map { $pu->warning( sprintf("[%s] map[%s] [%s]",$select_element , $_ , $out->{$select_element}));( $_ => ( $out->{$select_element} eq $_ ? ( $pu->warning( " ->")) && $pu->getSelectedStr() : ""  ) ) } @{$selects->{$select_element}}};
            $out->{ "_".$select_element } = { map { ( $_ => ( $out->{$select_element} eq $_ ? $pu->getSelectedStr() : ""  ) ) } @{$selects->{$select_element}}};
        }
    }
}

#$sth->finish();

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


