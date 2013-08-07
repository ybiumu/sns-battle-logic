#!/usr/bin/perl
############
### LOAD ###
############
use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();


##################
### init check ###
##################


my $nnid = $c->param("nnid") || 0;

my $get_nodeinfo_sql = "SELECT node_id, scenario_id, node_name, node_descr, node_img, use_link, last_update FROM t_node_master WHERE node_id = ?";








my $rs_sth = $db->prepare( $get_nodeinfo_sql );
$pu->output_log($rs_sth->execute(($nnid)));

my $rs_row  = $rs_sth->fetchrow_hashref();
if ( ! $rs_sth->rows() > 0 )
{
    exit;
}


my $node_id     = $rs_row->{node_id};
my $scenario_id = $rs_row->{scenario_id};
my $node_name   = $rs_row->{node_name};
my $node_descr  = $rs_row->{node_descr};
my $node_img    = $rs_row->{node_img};
my $use_link    = $rs_row->{use_link};
my $last_update = $rs_row->{last_update};
 






our $out = $at->getOut();

##############
### depend ###
##############
$at->setBody("body_debug_node_view.html");
$at->setPageName("ÃÞÊÞ¯¸Þ:’n“_");
my $version = "0.1a20130415";



############
### Main ###
############

$out->{NODE_DESCR}   = $node_descr;
$out->{NODE_ID}      = $node_id;
$out->{NODE_IMG}     = $node_img;
$out->{NODE_NAME}    = $node_name;
$out->{SCENARIO_ID}  = $scenario_id;
$out->{LAST_UPDATE}  = $last_update;
$out->{USE_LINK}     = $use_link ? "›" : "~" ;


##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


