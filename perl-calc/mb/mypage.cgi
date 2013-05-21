#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


#our $out = $at->setOut( {
#    NAME  => "�Q�X�g",
#    MSG   => "��낵�����˂������܂�",
#    BRD   => "",
#    PLACE => "�ނ̒�",
#    GOLD  => 120327,
#    FACE  => 0,
#    HAIR  => 0,
#    V_HP  => 100,
#    V_MHP => 100,
#    V_CON => "0&nbsp;&nbsp;",
#    V_ATK => "89&nbsp;",
#    V_MAG => "0&nbsp;&nbsp;",
#    V_DEF => "60&nbsp;",
#    V_AGL => "55&nbsp;",
#    V_KHI => "100",
#    V_SNC => "100",
#    V_LUK => "100",
#    V_HMT => "100",
#    V_CHR => "100",
#});




#my $base_dir = "/home/users/2/ciao.jp-anothark/web";
#my $dp = "$base_dir/data";
#my $t  = "$dp/anothark";
#
#$at->setBase("$t/template.html");
#$at->setBody("$t/body_mypage.html");
#
#$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
#$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );



$at->setBase("template.html");
$at->setBody("body_mypage.html");

$pu->setSystemLog( "aa_calc.log" );
$pu->setAccessLog( "aa_access.log" );


$at->setPageName("�}�C�y�[�W");
my $version = "0.1a20120328";


my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();



## Main

my $result = $at->setupBaseData();

if ( ! $result )
{
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


if ( $c->param("user_id") && $c->param("user_id") ne $aa->{out}->{user_id} )
{
    $result = $at->getBaseDataByUserId($c->param("user_id"));
    if ( ! $result )
    {
        $at->Error();
        $at->{out}->{RESULT} = "���̃��[�U�[�͑��݂��܂���";
    }
}



$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;
