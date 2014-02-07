#!/usr/bin/perl
#
# ˆ¤
#

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use PageUtil;
use AaTemplate;
use Anothark::Battle;
use Anothark::Battle::Exhibition;
use Anothark::Character;
use Anothark::Skill;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";

my $c = new CGI();

# Init check
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


$at->setBody("body_resultview.html");
$at->setPageName("í“¬ƒeƒXƒg");
my $version = "0.1a20120328";


my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();

$pu->output_log("Start battle.");

our $out = $at->getOut();



$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();






##############
### Battle ###
##############
    my $battle = new Anothark::Battle( $at );
    my $me = $at->getPlayerByUserId($out->{USER_ID});
#    my $battle_html = Anothark::Battle::Exhibition::doExhibitionMatch( $battle, $me ,6,6);
    my $battle_html = Anothark::Battle::Exhibition::doExhibitionMatch( $battle, $me,4 );
#    my $battle_html = $battle->getBattleText();

    my $drops = $battle->checkDropItems();
    my $chk_exp = $battle->checkExperiment();
    my $party = $battle->getPartyMember();

    $out->{RESULT} .= $battle_html;
    $out->{RESULT} .= sprintf("<br /><center>***</center>")  if (scalar(@{$drops}));
    $out->{RESULT} .= $chk_exp;
    foreach my $items ( @{$drops} )
    {
        my $target = $party->[int(rand(scalar(@{$party})))];
#        $pu->warning(sprintf( "[DROP R] %s", $items->getItemLabel()));
        $out->{RESULT} .= sprintf('<br />™%s‚Í%s‚ðŽè‚É“ü‚ê‚½!', $target->getName(),$items->getItemLabel());
        $target->getStatusIo()->getItem( $items->getItemMasterId() );
    }
    $out->{RESULT_TITLE} = $battle->getPartyName();


    $db->disconnect();

    $pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
#    print $c->redirect("recent_text.cgi?guid=ON");    

    $pu->output_log("End battle.");

#}


$at->setup();

$at->output();


exit;

