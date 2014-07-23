#!/usr/bin/perl
############
### LOAD ###
############
#
# 愛
#
use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::Party;
use Anothark::PartyLoader;

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



my @oddeven = ( "odd", "even" );

our $out = $at->getOut();

my $type = $c->param("t") || 0;

##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName("ﾊﾟｰﾃｨｰ");
my $version = "0.1a20130415";



############
### Main ###
############

#
# l: leave -> 抜ける
# r: reject -> 除名
# d: destroy -> 解散
# c: change -> 名称変更
#

my $pl = new Anothark::PartyLoader( $at );

my $me = $at->getBattlePlayerByUserId($out->{USER_ID});
my $party = $pl->loadPartyByUser( $me );



$at->setPageName($party->getPartyName());


if ( $type eq "l" )
{
    $at->setBody("body_party_leave.html");
    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨｰ「%s」を抜けます', $party->getPartyName());
}
elsif ( $type eq "lc")
{
    $pl->leave( $me );
    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨｰを抜けました');
}
elsif ( $type eq "r" )
{
    $at->setBody("body_party_reject.html");
    $out->{RESULT} .= sprintf( '「%s」を除名します', $party->getPartyName());
}
elsif ( $type eq "rc")
{
#    $pl->reject( $me,  );
    $out->{RESULT} .= sprintf( 'を除名しました');
}
elsif ( $type eq "d" )
{
    $at->setBody("body_party_destroy.html");
    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨｰを解散します', $party->getPartyName());
}
elsif ( $type eq "dc")
{
#    $pl->destroy( $me );
    $out->{RESULT} .= sprintf( '解散しました');
}
else
{
    my $lines = 0;
    foreach my $u ( $party->getPartyCharacter() )
    {
#    $out->{RESULT} .= sprintf( "%s", join( "<br />\n", map{ sprintf "%s: %s", $_, $u->{$_} } keys %{$u}));
        $out->{RESULT} .= sprintf(
            qq|<div class="item_%s">%s%s&nbsp;[%s]&nbsp;<a href='mypage.cgi?user_id=%s&guid=ON'>%s</a><br /><a href="">EQUIPS</a><br />体力&nbsp;%s/%s<br />持久&nbsp;%s/%s</div>\n|,
            $oddeven[$lines%2],
            Avatar::Hair::TYPE->{$u->getHairType()},
            Avatar::Face::TYPE->{$u->getFaceType()},
            $u->getPointStr(),
            $u->getId(), $u->getName(),
            $u->getHp()->cv(), $u->getHp()->max(),
            $u->getStamina()->cv(), $u->getStamina()->max(),
        );
        $lines++;
    }
    $out->{RESULT} .= "<br />";

    # Everyone menu
    $out->{RESULT} .= sprintf('<a href="board.cgi?guid=ON&t=2&oid=%s">ﾊﾟｰﾃｨｰ掲示板</a><br />',$party->getOwnerId());
    $out->{RESULT} .= sprintf('<a href="board.cgi?guid=ON&t=2&oid=%s">隊列変更</a><br />',$party->getOwnerId());

    # Owner Menu
    if ( $me->getId()  == $party->getOwnerId() )
    {
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=c&oid=%s">ﾊﾟｰﾃｨｰ名変更</a>',$party->getOwnerId());
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=r&oid=%s">除名</a>',$party->getOwnerId());
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=d&oid=%s">ﾊﾟｰﾃｨｰを解散</a>',$party->getOwnerId());
    }
    # Member Menu
    else
    {
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=l&oid=%s">ﾊﾟｰﾃｨｰを抜ける</a>',$party->getOwnerId());
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


