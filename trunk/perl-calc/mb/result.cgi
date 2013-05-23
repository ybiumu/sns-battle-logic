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

my $ad_str = "";

my $db = DbUtil::getDbHandler();

our $out = $at->setOut( {
#    NAME  => "ゲスト",
#    MSG   => "よろしくおねがいします",
#    BRD   => "",
#    PLACE => "彼の庭",
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
});




#my $base_dir = "/home/users/2/ciao.jp-anothark/web";
#my $dp = "$base_dir/data";
#my $t  = "$dp/anothark";
#
#$at->setBase("$t/template.html");
#$at->setBody("$t/body_result.html");
#
#$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
#$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );
#$at->setBase("template.html");
$at->setBody("body_result.html");

#$pu->setSystemLog( "aa_calc.log" );
#$pu->setAccessLog( "aa_access.log" );

$at->setPageName("リザルト");
my $version = "0.1a20120328";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();



## Main

my $get_result_list_sql = "
    SELECT
        l.result_log_id,
        l.result_id,
        l.last_update
    FROM
        t_result_log AS l
        JOIN
        t_user AS b
        USING(user_id)
    WHERE
        b.carrier_id = ? AND b.uid = ? AND l.sequence_id = 0
    GROUP BY result_log_id
    ORDER BY last_update DESC";
my $sth  = $db->prepare($get_result_list_sql);
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row ;



if ( $sth->rows() > 0 )
{
    my $lines = 0;
    while( $row  = $sth->fetchrow_hashref() )
    {
        $lines++;
        $out->{RESULT} .= sprintf(qq[<a href="resulttext.cgi?guid=ON&result_log_id=%s">&nbsp;%s</a><hr />\n],$row->{result_log_id}, $row->{last_update})
    }
    $pu->output_log("passed find result row. count[$lines]");
}
#else
#{
#    $sth->finish();
#    $db->disconnect();
#    print $c->redirect("setup.cgi?guid=ON");    
#    exit;
#}
$sth->finish();

#$out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
#$out->{V_HP} =  $row->{hp};
#$out->{V_MHP} = $row->{max_hp};
#$out->{MSG}   = $row->{msg};
#$out->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
#$out->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};
#$out->{PLACE} = $row->{node_name};
$db->disconnect();





$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;

