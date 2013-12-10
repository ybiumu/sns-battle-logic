#!/usr/bin/perl

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


#
# Players in Same Place.
# 

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

##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName("ãﬂÇ≠ÇÃêl");
my $version = "0.1a20120328";



############
### Main ###
############
my $php_sql = "SELECT u.user_name AS user_name ,u.user_id AS user_id FROM t_user_status AS s JOIN t_user AS u USING(user_id) WHERE s.node_id = ? AND u.user_id <> ?";

my $sth  = $db->prepare($php_sql);
my $stat = $sth->execute(($at->{out}->{NODE_ID}, $at->{out}->{USER_ID}));
my $row;
my $lines = 0;



if ( $sth->rows > 0 )
{
    $at->{out}->{RESULT} = "";
    while( $row  = $sth->fetchrow_hashref() )
    {
        $lines++;
        $at->{out}->{RESULT} .= sprintf("<a href=\"mypage.cgi?guid=ON&user_id=%s\">%s</a><br />\n", $row->{user_id}, $row->{user_name});
    }
    $at->{out}->{RESULT} .= "<hr />";
}
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();

$db->disconnect();




exit;

