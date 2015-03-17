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
use Anothark::FollowingManager;
use Anothark::PartyLoader;


my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db  = DbUtil::getDbHandler();
my $mu  = new MobileUtil();
$at->setDbHandler($db);
$at->setMobileUtil($mu);


my $fm  = new Anothark::FollowingManager($db);
my $pls = new Anothark::PartyLoader($at,1);


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

##############
### depend ###
##############
$at->setBody("body_tasklist.html");
$at->setPageName("��邱����");
my $version = "0.1a20130415";



############
### Main ###
############

# init
$out->{"RESULT_FRIENDS"} = sprintf('**&nbsp; �\���͂���܂��� &nbsp;**');
$out->{"RESULT_PARTY"}   = sprintf('**&nbsp; ���U�͂���܂��� &nbsp;**');
$out->{"RESULT_TASK"}    = sprintf('**&nbsp; �˗��͂���܂��� &nbsp;**');

# load sns notice.
my $fr = $fm->getFollowRequest( $out->{USER_ID});
if ( scalar @{$fr} )
{
    $out->{"RESULT_FRIENDS"} = "";
    map
    {
        $out->{"RESULT_FRIENDS"} .= sprintf(
            '<a href="mypage.cgi?guid=ON&user_id=%s">%s</a><br /><form action="follow_ans.cgi"><input type="hidden" name="guid" value="ON" /><input type="hidden" name="tid" value="%s"><input type="submit" name="yes" value="���F" />&nbsp;<input type="submit" name="no" value="����" /></form><hr />',
            $_->{follow_user_id},
            $_->{user_name},
            $_->{follow_user_id}
        )
    } @{ $fr };
}

my $pi = $pls->getPartyInvitation( $out->{USER_ID},1 );
if ( scalar @{$pi} )
{
    $out->{"RESULT_PARTY"} = "";
    map
    {
        $out->{"RESULT_PARTY"} .= sprintf(
            '<a href="mypage.cgi?guid=ON&user_id=%s">%s</a><br />%s<br /><form action="party.cgi"><input type="hidden" name="guid" value="ON" /><input type="hidden" name="oid" value="%s" /><input type="hidden" name="t" value="iv" /><input type="submit" name="yes" value="���F" />&nbsp;<input type="submit" name="no" value="����" /></form><hr />',
            $_->{invite_user_id},
            $_->{user_name},
            $_->{message},
            $_->{invite_user_id},
        )
    } @{ $pi };
}






##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


