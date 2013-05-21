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

#
# Players in Same Place.
# 

#my $base_dir = "/home/users/2/ciao.jp-anothark/web";
#my $dp = "$base_dir/data";
#my $t  = "$dp/anothark";

$at->setBase("template.html");
$at->setBody("body_any.html");

$pu->setSystemLog( "aa_calc.log" );
$pu->setAccessLog( "aa_access.log" );

$at->setPageName("‹ß‚­‚Ìl");
my $version = "0.1a20120328";


my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();



## Main

my $result = $at->setupBaseData();

if ( ! $result )
{
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


my $php_sql = "SELECT u.user_name AS user_name ,u.user_id AS user_id FROM t_user_status AS s JOIN t_user AS u USING(user_id) WHERE s.node_id = ? AND u.user_id <> ?";

my $sth  = $db->prepare($php_sql);
my $stat = $sth->execute(($aa->{out}->{NODE_ID}, $aa->{out}->{USER_ID}));
my $row;
my $lines = 0;



if ( $sth->rows > 0 )
{
    $out->{RESULT} = "<form name=\"item\" method=\"get\" action=\"items.cgi\">\n";
    while( $row  = $sth->fetchrow_hashref() )
    {
        $lines++;
        $out->{RESULT} .= sprintf("<a href=\"mypage.cgi?guid=ON&user_id=%s\">%s<br />\n", $row->{user_id}, $row->{user_name});
    }
    $out->{RESULT} .= "<hr />";
}
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;

