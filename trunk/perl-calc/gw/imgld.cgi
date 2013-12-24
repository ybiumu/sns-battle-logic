#!/usr/bin/perl
#
# ˆ¤
#
############
### LOAD ###
############
use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
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
our $image_id = $c->param("i") || 0;

##############
### depend ###
##############
$at->setImg($image_id);
#$at->setBody("body_any.html");
#$at->setPageName("ÃÝÌßÚ");
my $version = "0.1a20130415";



############
### Main ###
############
my $img = $at->getImg();
my ($imgtype) = ( $img =~ /\.([^\.]*)$/ );
$imgtype =~ s/^jpg$/jpeg/g;
open OP, $at->getImg() or die "Open failure [" . $at->GetImg() . "]";
binmode(OP);
binmode(STDOUT);
print "Content-type: image/$imgtype\n\n";
print while (<OP>);
close OP;




##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
#$at->setup();
#$at->output();





exit;


