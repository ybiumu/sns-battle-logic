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



our $oid = $c->param("oid");
our $yes = $c->param("yes") || 0;
our $no  = $c->param("no") || 0;

our $out = $at->getOut();

##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName('—F’B\¿');
my $version = "0.1a20130415";
my $fm = new Anothark::FollowingManager( $db );



############
### Main ###
############

if ( $oid )
{
    my $char = $at->getCharacterByUserId($oid);
    my $fs   = $fm->isFollowing($oid,$out->{USER_ID});
    if ( $fs == 2 )
    {
        $out->{RESULT} .= 'Šù‚É—F’B‚Å‚·';
    }
    elsif( $fs == 1 )
    {
        $out->{RESULT} .= '—F’B\¿’†‚Å‚·'
    }
    else
    {
        if ( $yes )
        {
            if ( $fm->doFollowRequest( $out->{USER_ID}, $oid ) )
            {
                $out->{RESULT} .= '—F’B\¿‚µ‚Ü‚µ‚½';
            }
            else
            {
                $out->{RESULT} .= '—F’B\¿‚Å‚«‚Ü‚¹‚ñ‚Å‚µ‚½';
            }

        }
        elsif ( $no )
        {
            $out->{RESULT} .= '—F’B\¿‚ð‚â‚ß‚Ü‚µ‚½';

        }
        else
        {
            my $o_str = sprintf('%s ‚É—F’B\¿‚µ‚Ü‚·‚©H', $char->getName());
            $out->{RESULT} .= <<_HERE_
$o_str
<form action="follow.cgi" >
<input type="hidden" name="guid" value="ON" />
<input type="hidden" name="oid" value="$oid" />
<input type="submit" name="yes" value="‚Í‚¢" />
<input type="submit" name="no" value="‚¢‚¢‚¦" />
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


