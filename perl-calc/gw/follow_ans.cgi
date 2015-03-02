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
use Anothark::FollowingManager;

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



our $tid = $c->param("tid");
our $yes = $c->param("yes") || 0;
our $no  = $c->param("no") || 0;

our $out = $at->getOut();

##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName('友達申請');
my $version = "0.1a20130415";
my $fm = new Anothark::FollowingManager( $db );



############
### Main ###
############

if ( $tid )
{
    my $char = $at->getCharacterByUserId($tid);
    my $fs   = $fm->isFollowed($tid,$out->{USER_ID});
    if ( $fs == 2 )
    {
        $out->{RESULT} .= 'ズッ友です';
    }
    else
    {
        if ( $yes )
        {
            if ( $fm->acceptFollowRequest( $out->{USER_ID}, $tid ) )
            {
                $out->{RESULT} .= '友達になりました';
            }
            else
            {
                $out->{RESULT} .= '友達申請を許可できませんでした';
            }

        }
        elsif ( $no )
        {
            if ( $fm->rejectFollowRequest( $out->{USER_ID}, $tid ) )
            {
                $out->{RESULT} .= '友達申請を断りました';
            }
            else
            {
                $out->{RESULT} .= '友達申請を断れませんでした';
            }

        }
        else
        {
            my $o_str = sprintf(
                '<a href="mypage.cgi?guid=ON&user_id=%s">%s</a> に友達申請しますか？',
                $char->getId(), $char->getName()
            );
            $out->{RESULT} .= <<_HERE_
$o_str
<form action="follow_ans.cgi">
<input type="hidden" name="guid" value="ON" />
<input type="hidden" name="tid" value="$tid">
<input type="submit" name="yes" value="承認" />&nbsp;<input type="submit" name="no" value="拒否" />
</form>
_HERE_
        }
    }
}
else
{
}



##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


