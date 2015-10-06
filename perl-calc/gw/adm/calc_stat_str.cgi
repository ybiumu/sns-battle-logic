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

use Anothark::StatusManager;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

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
my $result = $at->setupBaseData();
if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}



my $sm = new Anothark::StatusManager();

our $out = $at->getOut();
#unless ( $out->{GM} )
#{
#    print $c->header( -status=>"404 Not found" );
#    exit 1;
#}

##############
### depend ###
##############
$at->setBase("adm_template.html");
$at->setBody("body_any.html");
$at->setPageName("ステータス文字計算機");
my $version = "0.1a20130415";



############
### Main ###
############

# calc result
my $map = {
    0 => "しない",
    1 => "する",
    2 => "耐性",
};
# form
$out->{RESULT} .= "<form action='calc_stat_str.cgi' method='post'>\n";

my $stat_master = $sm->get_stat_master();
map {
    my $str = "";
    foreach my $s ( 0 .. 2 )
    {
        $str .= sprintf( '<input type="radio" name="s_%s" calue="%s"%s>%s ', $_, $s, ,$map->{$s} );
    }
    $out->{RESULT} .= sprintf('%s：%s<br />'."\n", $stat_master->{$_}->{short_label},$str );

} sort {$a <=> $b } keys %{ $stat_master };

$out->{RESULT} .= "</form>\n";


##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


