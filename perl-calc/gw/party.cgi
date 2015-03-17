#!/usr/bin/perl
############
### LOAD ###
############
#
# ��
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
$at->setPageName("�߰è�");
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
# l: leave -> ������
# r: reject -> ����
# d: destroy -> ���U
# c: change -> ���̕ύX
# i: invite -> ���U����
### o: reclute OK -> �󂯂�
### n: reclute NG -> �f��
#


my $me = $at->getBattlePlayerByUserId($out->{USER_ID});
my $party = $pl->loadPartyByUser( $me );



if ($party->getPartyName() )
{
    $at->setPageName( sprintf( '�߰è�<br />%s', $party->getPartyName()));
}

$out->{CONFIRM_TYPE} = "";
$out->{TARGET_USER} = $target;

if ( $type eq "l" )
{
    $at->setBody("body_party_leave.html");
    $out->{RESULT} .= sprintf( '�߰è��u%s�v�𔲂��܂�', $party->getPartyName());
}
elsif ( $type eq "lc")
{
    $pl->leave( $me );
    $out->{RESULT} .= sprintf( '�߰è��𔲂��܂���');
}
elsif ( $type eq "r" )
{
#    $at->setBody("body_party_reject.html");
    $at->setBody("body_party_confirm.html");
    $out->{RESULT} .= sprintf( '�u%s�v���������܂�', $party->getPartyName());
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "rc")
{
#    $pl->reject( $me,  );
    $out->{RESULT} .= sprintf( '���������܂���');
}
elsif ( $type eq "d" )
{
#    $at->setBody("body_party_destroy.html");
    $at->setBody("body_party_confirm.html");
    $out->{RESULT} .= sprintf( '�߰è������U���܂�', $party->getPartyName());
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "dc")
{
#    $pl->destroy( $me );
    $out->{RESULT} .= sprintf( '���U���܂���');
}
elsif ( $type eq "i" )
{
#    $at->setBody("body_party_invite.html");
    $at->setBody("body_party_confirm.html");
    $out->{RESULT} .= sprintf( '�߰è��Ɋ��U���܂�', $party->getPartyName());
    $out->{CONFIRM_TYPE} = $type;
}
elsif ( $type eq "ic")
{
    $pl->invite( $out->{USER_ID}, $target );
    $out->{RESULT} .= sprintf( '���U���o���܂���');
}
#elsif ( $type eq "o" )
#{
##    $at->setBody("body_party_invite.html");
#    $at->setBody("body_party_confirm.html");
#    $out->{RESULT} .= sprintf( '�u%s�v���߰è��ɏ������܂�', $party->getPartyName());
#    $out->{CONFIRM_TYPE} = $type;
#}
#elsif ( $type eq "oc")
#{
##    $pl->inviteOk( $me );
#    $out->{RESULT} .= sprintf( '�������܂���');
#}
#elsif ( $type eq "n" )
#{
##    $at->setBody("body_party_invite.html");
#    $at->setBody("body_party_confirm.html");
#    $out->{RESULT} .= sprintf( '�u%s�v���߰è����U��f��܂�', $party->getPartyName());
#    $out->{CONFIRM_TYPE} = $type;
#}
#elsif ( $type eq "nc")
#{
##    $pl->inviteNg( $me );
#    $out->{RESULT} .= sprintf( '�߰è����U��f��܂���');
#    $out->{CONFIRM_TYPE} = $type;
#}
else
{
    my $lines = 0;
    foreach my $u ( $party->getPartyCharacter() )
    {
#    $out->{RESULT} .= sprintf( "%s", join( "<br />\n", map{ sprintf "%s: %s", $_, $u->{$_} } keys %{$u}));
        $out->{RESULT} .= sprintf(
            qq|<div class="item_%s">%s%s&nbsp;[%s]&nbsp;<a href='mypage.cgi?user_id=%s&guid=ON'>%s</a><br /><a href="">EQUIPS</a><br />�̗�&nbsp;%s/%s<br />���v&nbsp;%s/%s</div>\n|,
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
    $out->{RESULT} .= sprintf('<a href="board.cgi?guid=ON&t=2&oid=%s">�߰è��f����</a><br />',$party->getOwnerId());
    $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=p&oid=%s">����ύX</a><br />',$party->getOwnerId());

    # Owner Menu
    if ( $me->getId()  == $party->getOwnerId() )
    {
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=c&oid=%s">�߰è����ύX</a>',$party->getOwnerId());
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=r&oid=%s">����</a>',$party->getOwnerId());
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=d&oid=%s">�߰è������U</a>',$party->getOwnerId());
    }
    # Member Menu
    else
    {
        $out->{RESULT} .= sprintf('<a href="party.cgi?guid=ON&t=l&oid=%s">�߰è��𔲂���</a>',$party->getOwnerId());
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


