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

my $ad_str = "";


our $out = $at->setOut( {
    NAME  => "ƒQƒXƒg",
    MSG   => "‚æ‚ë‚µ‚­‚¨‚Ë‚ª‚¢‚µ‚Ü‚·",
    BRD   => "",
    PLACE => "”Þ‚Ì’ë",
    GOLD  => 120327,
    FACE  => 0,
    HAIR  => 0,
    V_HP  => 100,
    V_MHP => 100,
    V_CON => "0&nbsp;&nbsp;",
    V_ATK => "89&nbsp;",
    V_MAG => "0&nbsp;&nbsp;",
    V_DEF => "60&nbsp;",
    V_AGL => "55&nbsp;",
    V_KHI => "100",
    V_SNC => "100",
    V_LUK => "100",
    V_HMT => "100",
    V_CHR => "100",
});




#my $base_dir = "/home/users/2/ciao.jp-anothark/web";
#my $dp = "$base_dir/data";
#my $t  = "$dp/anothark";
#
#$at->setBase("$t/template.html");
#$at->setBody("$t/body_debug_room.html");
#
#$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
#$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );


#$at->setBase("template.html");
$at->setBody("body_debug_room.html");

#$pu->setSystemLog( "aa_calc.log" );
#$pu->setAccessLog( "aa_access.log" );

$at->setPageName("ÃÞÊÞ¯¸Þ");
my $version = "0.1a20130415";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();



## Main






$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;

