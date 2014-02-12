#!/usr/bin/perl
#
# 愛
#
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
use Anothark::TextFilter;

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
my $result = $at->setupBaseData();
if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}




our $out = $at->getOut();
my $user_id = $out->{USER_ID};

##############
### depend ###
##############
$at->setBody("body_edit_message.html");
$at->setPageName('メッセージ');
my $version = "0.1a20130415";



############
### Main ###
############

my $st = $c->param("st") || 0;
if ( $st == 1 )
{
    my $msg = $c->param("msg") || "";
    my $filter = new Anothark::TextFilter();

    $msg = $filter->optimize($msg);

    if ( $filter->match( $msg ) )
    {
        $out->{"RESULT"} = '<span style="color:#ff0000;">禁止文字が存在します!</span><br />';
        $out->{"MSG"} = $msg;
    }
    else
    {
        my $sth = $db->prepare("UPDATE t_user SET msg = ? WHERE user_id = ?;");
        my $stat = $sth->execute($msg, $user_id);
        $sth->finish();
        $db->disconnect();

        print $c->redirect("mypage.cgi?guid=ON");
        exit;

    }
}




##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


