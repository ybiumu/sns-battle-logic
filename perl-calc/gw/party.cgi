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
my $target = $c->param("oid") || 0;

##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName("ﾊﾟｰﾃｨｰ");
my $version = "0.1a20130415";



############
### Main ###
############

my $pl = new Anothark::PartyLoader( $at );
if ( $type eq "iv" )
{
    my $ans = ( $c->param("yes") && 1 ) || ( $c->param("no") && 0 );
    if ($ans)
    {
        $pl->acceptInvite($out->{USER_ID}, $target);
    }
    else
    {
        $pl->rejectInvite($out->{USER_ID}, $target);
        $db->disconnect();
        print $c->redirect("mypage.cgi?guid=ON");    
        exit;
    }
}

#
# l: leave -> 抜ける
# r: reject -> 除名
# d: destroy -> 解散
# c: change -> 名称変更
# i: invite -> 勧誘する
### o: reclute OK -> 受ける
### n: reclute NG -> 断る
#


my $me = $at->getBattlePlayerByUserId($out->{USER_ID});
my $party = $pl->loadBattlePartyByUser( $me, 'p' );



if ($party->getPartyName() )
{
    $at->setPageName( sprintf( '%s', $party->getPartyName()));
}

$out->{CONFIRM_TYPE} = "";
$out->{TARGET_USER} = $target;

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
elsif ( $type eq "c" )
{
#    $at->setBody("body_party_reject.html");
    $at->setBody("body_party_edit.html");
    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨ名を変更します');
    $out->{CURRENT_STR} = $party->getPartyName();
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "cc")
{
    my $new_name = $c->param("str");
    if ( $new_name )
    {
        $pl->change( $me, $new_name );
        $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨ名を変更しました');
    }
    else
    {
        $out->{RESULT} .= sprintf('ｴﾗｰ');
    }
}
elsif ( $type eq "r" )
{
#    $at->setBody("body_party_reject.html");
    $at->setBody("body_party_confirm.html");
    $out->{RESULT} .= sprintf( '「%s」を除名します', $party->getPartyName());
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "rc")
{
#    $pl->reject( $me,  );
    $out->{RESULT} .= sprintf( 'を除名しました');
}
elsif ( $type eq "d" )
{
#    $at->setBody("body_party_destroy.html");
    $at->setBody("body_party_confirm.html");
    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨｰを解散します', $party->getPartyName());
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "dc")
{
#    $pl->destroy( $me );
    $out->{RESULT} .= sprintf( '解散しました');
}
elsif ( $type eq "i" )
{
#    $at->setBody("body_party_invite.html");
    $at->setBody("body_party_confirm.html");
    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨｰに勧誘します', $party->getPartyName());
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "ic")
{
    $pl->invite( $out->{USER_ID}, $target );
    $out->{RESULT} .= sprintf( '勧誘を出しました');
}
#elsif ( $type eq "o" )
#{
##    $at->setBody("body_party_invite.html");
#    $at->setBody("body_party_confirm.html");
#    $out->{RESULT} .= sprintf( '「%s」のﾊﾟｰﾃｨｰに所属します', $party->getPartyName());
#    $out->{CONFIRM_TYPE} = $type;
#}
#elsif ( $type eq "oc")
#{
##    $pl->inviteOk( $me );
#    $out->{RESULT} .= sprintf( '所属しました');
#}
#elsif ( $type eq "n" )
#{
##    $at->setBody("body_party_invite.html");
#    $at->setBody("body_party_confirm.html");
#    $out->{RESULT} .= sprintf( '「%s」のﾊﾟｰﾃｨｰ勧誘を断ります', $party->getPartyName());
#    $out->{CONFIRM_TYPE} = $type;
#}
#elsif ( $type eq "nc")
#{
##    $pl->inviteNg( $me );
#    $out->{RESULT} .= sprintf( 'ﾊﾟｰﾃｨｰ勧誘を断りました');
#    $out->{CONFIRM_TYPE} = $type;
#}
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
    $out->{RESULT} .= sprintf('<a class="inline_menu" href="board.cgi?guid=ON&t=2&oid=%s"><span class="icon css-ic_forum_24px css-ic_forum_24px-dims"></span><span class="label small">ﾊﾟｰﾃｨｰ掲示板</span></a><span class="fp_sep"><br /></span>',$party->getOwnerId());
    $out->{RESULT} .= sprintf('<a class="inline_menu" href="party.cgi?guid=ON&t=p&oid=%s"><span class="icon css-ic_sort_24px css-ic_sort_24px-dims"></span><span class="label">隊列変更</span></a><span class="fp_sep"><br /></span>',$party->getOwnerId());

    # Owner Menu
    if ( $me->getId()  == $party->getOwnerId() )
    {
        $out->{RESULT} .= sprintf('<a class="inline_menu" href="party.cgi?guid=ON&t=c&oid=%s"><span class="icon"></span><span class="label small">ﾊﾟｰﾃｨｰ名変更</span></a><span class="fp_sep"><br /></span>',$party->getOwnerId());
        $out->{RESULT} .= sprintf('<a class="inline_menu" href="party.cgi?guid=ON&t=r&oid=%s"><span class="icon css-ic_remove_circle_outline_24px css-ic_remove_circle_outline_24px-dims"></span><span class="label">除名</span></a><span class="fp_sep"><br /></span>',$party->getOwnerId());
        $out->{RESULT} .= sprintf('<a class="inline_menu" href="party.cgi?guid=ON&t=d&oid=%s"><span class="icon"></span><span class="label small">ﾊﾟｰﾃｨｰを解散</span></a>',$party->getOwnerId());
    }
    # Member Menu
    else
    {
        $out->{RESULT} .= sprintf('<a class="inline_menu" href="party.cgi?guid=ON&t=l&oid=%s"><span class="icon"></span><span class="label">ﾊﾟｰﾃｨｰを抜ける</span></a>',$party->getOwnerId());
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


