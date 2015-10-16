#!/usr/bin/perl
#
# ˆ¤
#
#-: Landing Page :-#
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


#my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil({ no_limits => 1 });

#$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



#my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
#$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
#my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();


##################
### init check ###
##################



our $out = $at->getOut();
our $image_id = $c->param("i") || 0;
our $bimage_id = $c->param("b") || 0;

##############
### depend ###
##############
$at->setBase("twitter_card_template.html");
$at->setBody("body_any.html");
$at->setPageName("battle simulator");
my $version = "0.1a20151015";



############
### Main ###
############



$at->setCardTitle("BattleImage");
$at->setBgId( $bimage_id );
$at->setEnemyId( $image_id );


#my $img = sprintf(q[<img src="http://pr.gmpj.biz/epimgld.cgi?b=%s&i=%s" >],$bimage_id, $image_id);
my $img = sprintf(q[<img src="http://pr.gmpj.biz/%s/%s/epimgld.jpg" >],$bimage_id, $image_id);

$out->{RESULT} = $img;

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



#$db->disconnect();
$at->setup();
$at->output();





exit;


