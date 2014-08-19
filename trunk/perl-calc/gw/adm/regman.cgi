#!/usr/bin/perl
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
use Anothark::Item;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

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
    print $c->redirect("../setup.cgi?guid=ON");    
    exit;
}


my @oddeven = ( "odd", "even" );

my $inc = $c->param("inc");
my $dec = $c->param("dec");

our $out = $at->getOut();
#unless ( $out->{GM} )
#{
#    print $c->header( -status=>"404 Not found" );
#    exit 1;
#}

$out->{RESULT} = "";
if ( $inc )
{
    incrRegcnt($db);
    $out->{RESULT} .= "Increment!<br />";
}

if ( $dec )
{
    decrRegcnt($db);
    $out->{RESULT} .= "Decrement!<br />";
}

my $cnt = getRemain($db);

$out->{CURRENT} = sprintf ('Žc“o˜^” %d l', $cnt);

##############
### depend ###
##############
$at->setBody("body_admin_regman.html");
$at->setPageName("ŠÇ— - “ü‰ïŠÇ—");
my $version = "0.1a20130415";



############
### Main ###
############

$out->{NEW_MEMBERS} = "";
my $users = getRecentRegist( $db );
my $lines = 0;
foreach my $u ( @{$users} )
{
    $out->{NEW_MEMBERS} .= sprintf(
        qq|<div class="item_%s">%s%s<br />[<a href='../mypage.cgi?user_id=%s&guid=ON'>%s</a>](%s)&nbsp;%s<br />From:&nbsp;%s</div>\n|,
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


#$sth->finish();

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;

sub getRecentRegist
{
    my $db = shift;
    my $row = [];
    my $sth_reg  = $db->prepare("SELECT user_id, user_name, hair_type, face_type, carrier_id,create_date FROM t_user ORDER BY user_id DESC LIMIT 5;");
    my $stat = $sth_reg->execute();
    $row  = $sth_reg->fetchall_arrayref( +{} );
    return $row;
}

sub getRemain
{
    my $db = shift;
    my $sth_reg  = $db->prepare("SELECT cnt FROM regist_count");
    my $stat_reg = $sth_reg->execute();
    my $row_reg  = $sth_reg->fetchrow_hashref();
    my $cnt = 0;
    my $rownum_reg = $sth_reg->rows();
    $pu->debug("regnum [$rownum_reg]");
    $sth_reg->finish();
    if ( $rownum_reg == 1 )
    {
        $cnt = $row_reg->{cnt} || 0;
    }

    return $cnt;
}

sub incrRegcnt
{
    my $db = shift;
    my $sth_reg  = $db->prepare("UPDATE regist_count SET cnt = cnt + 1;");
    my $stat_reg = $sth_reg->execute();
    $sth_reg->finish();
}

sub decrRegcnt
{
    my $db = shift;
    my $sth_reg  = $db->prepare("UPDATE regist_count SET cnt = cnt - 1;");
    my $stat_reg = $sth_reg->execute();
    $sth_reg->finish();
}

