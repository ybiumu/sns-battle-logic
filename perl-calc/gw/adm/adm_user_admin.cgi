#!/usr/bin/perl
#
# ˆ¤
#
############
### LOAD ###
############
use lib qw( .htlib ../../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::BoardManager;
use Anothark::TextFilter;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

my $ad_str = "";


my $self_file = "adm_view_bbs.cgi";

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

my $board = new Anothark::BoardManager($db);
my $board_id = $c->param("bid") || 0;

my @oddeven = ( "odd", "even" );

our $out = $at->getOut();
my $user_id = $out->{USER_ID};
my $target_user_id = $c->param("oid") || "";
my $thread_id      = $c->param("tid") || "";
my $board_write    = $c->param("bw")  || "";
my $page_id = $c->param("p") || 0;


##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName("users");
my $version = "0.1a20130415";

$out->{TARGET_USER_ID} = $target_user_id;


############
### Main ###
############

if ( $target_user_id )
{
    $out->{"RESULT"} = 'Under construction.';
}
else
{

    my $users = getUsersAsc( $db );
    my $lines = 0;
    foreach my $u ( @{$users} )
    {
        $out->{NEW_MEMBERS} .= sprintf(
            qq|<div class="item_%s">%s%s<br />[<a href='adm_user_admin.cgi?oid=%s&guid=ON'>%s</a>](%s)&nbsp;%s<br />From:&nbsp;%s</div>\n|,
            $oddeven[$lines%2],
            Avatar::Hair::TYPE->{$u->{hair_type}},
            Avatar::Face::TYPE->{$u->{face_type}},
            $u->{user_id}, $u->{user_id},
            $u->{create_date},
            $u->{user_name},
            $mu->getCarrierStr( $u->{carrier_id})
        );
        $lines++;
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

sub getUsersAsc
{
    my $db = shift;
    my $border_id = shift;
    my $row = [];
    my $sth_reg  = $db->prepare("SELECT user_id, user_name, hair_type, face_type, carrier_id,create_date FROM t_user WHERE user_id > ? ORDER BY user_id ASC LIMIT 10;");
    my $stat = $sth_reg->execute( $border_id );
    $row  = $sth_reg->fetchall_arrayref( +{} );
    return $row;
}

sub getUsersDesc
{
    my $db = shift;
    my $border_id = shift;
    my $row = [];
    my $sth_reg  = $db->prepare("SELECT user_id, user_name, hair_type, face_type, carrier_id,create_date FROM t_user WHERE user_id < ? ORDER BY user_id DESC LIMIT 10;");
    my $stat = $sth_reg->execute( $border_id );
    $row  = $sth_reg->fetchall_arrayref( +{} );
    return $row;
}


