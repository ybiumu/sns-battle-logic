#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::BoardManager;
use Anothark::FollowingManager;
use UniversalAnalytics;
use Anothark::PartyLoader;


my $pu = new PageUtil();
my $at = new AaTemplate();
$at->warning("start mypage");
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();
$mu->debug(" page muid " .$mu->get_muid() );

$at->setDbHandler($db);
$at->setMobileUtil($mu);
my $fm = new Anothark::FollowingManager($db);
my $pl = new Anothark::PartyLoader( $at );

my $ad_str = "";


my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();

# init check
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


our $out = $at->getOut();
my $board = new Anothark::BoardManager($db);
my $my_user_id = $at->{out}->{USER_ID};


# depend
$at->setBody("body_mypage.html");
$at->setPageName("�}�C�y�[�W");

my $version = "0.1a20120328";




## Main

if ( $c->param("user_id") && $c->param("user_id") ne $at->{out}->{USER_ID} )
{

    # ���l�̃}�C�y
    my $result = $at->getBaseDataByUserId($c->param("user_id"));
    if ( ! $result )
    {

        $at->Critical();
#        $at->Error();
        $out->{RESULT} = "���̃��[�U�[�͑��݂��܂���";
    }
    else
    {
        $at->setBody("body_yourpage.html");
        if ( not $fm->isFollowed($my_user_id, $out->{USER_ID}) )
        {
            $out->{FOLLOW_CMD} .= sprintf('<a href="follow.cgi?guid=ON&oid=%s">�F�B�\������</a><br />', $out->{USER_ID});
        }
        else
        {
            if ( ( not $pl->isPartyMember($my_user_id, $out->{USER_ID}) ) && $at->sameNode( $at->{PLAYER},$out->{CHAR} ) && $pl->notInvited($my_user_id, $out->{USER_ID}) && $pl->isNotRunFirst() )
            {
                $out->{FOLLOW_CMD} .= sprintf('<a href="party.cgi?t=i&guid=ON&oid=%s">�߰è��Ɋ��U����</a><br />', $out->{USER_ID});
            }
        }
    }
}

my $entry =  $board->readMyBoardOne( $my_user_id, $out->{USER_ID})->[0];

if ( $entry )
{
    my $msg = $entry->{message};
    $msg =~ s/\n/<br \/>/g;
    $msg =~ s/ /&nbsp;/g;
#$msg =~ s/&gt;&gt;(\d+)/<a href="board.cgi?guid=ON&t=$board_type_id&oid=$target_user_id&tid=$1">&gt;&gt;$1<\/a>/g;
    $out->{BRD} .= sprintf
        "<br />%s<br />(%s)<br />%s",
        $entry->{user_name},
        $entry->{last_update},
        $msg;
}


$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');


#$out->{AVATAR} = UniversalAnalytics::urlenc($out->{HAIR} . $out->{FACE});
$out->{AVATAR} = $out->{HAIR} . $out->{FACE};


$at->setup();
$at->output();
$db->disconnect();
exit;
