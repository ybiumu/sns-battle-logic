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
#$at->setBody("$t/body_resultview.html");
#
#$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
#$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );


#$at->setBase("template.html");
$at->setBody("body_resultview.html");

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

my $rid = 0;
my $offset = $c->param("offset") || 0;

if( $offset !~ /^[1-9]\d*$/ )
{
    $offset = 0;
}

## get recent result_id
#my $get_recent_result_id_sql = "SELECT MAX(result_log_id) AS result_log_id, COUNT(result_log_id) AS number FROM t_user AS b JOIN t_result_log AS r USING( user_id )  WHERE b.carrier_id = ? AND b.uid = ? AND r.sequence_id <> 0;";
my $get_recent_result_id_sql = "SELECT MAX(result_log_id) AS result_log_id, MAX(sequence_id) AS number FROM t_user AS b JOIN t_result_log AS r USING( user_id )  WHERE b.carrier_id = ? AND b.uid = ? AND r.sequence_id <> 0 GROUP BY result_log_id desc HAVING result_log_id = MAX(result_log_id) LIMIT 1";
my $pre_sth = $db->prepare($get_recent_result_id_sql);
my $pre_stat = $pre_sth->execute(($carrier_id, $mob_uid));
my $recent_result_log_id = 0;
my $total_numnber = 0;

if ( $pre_sth->rows() > 0 )
{
    my $pre_row = $pre_sth->fetchrow_hashref();
    $rid = $pre_row->{result_log_id};
    $total_number = $pre_row->{number};
}
$pre_sth->finish();

$pu->output_log("find result_log_id [$rid]");

## Main

my $get_result_sql = "
    SELECT
        m.result_title AS result_title,
        REPLACE(REPLACE(r.result_text,'<_NAME_>',b.user_name),'<_SELF_CALL_>',g.self_call) AS result
    FROM
        t_user AS b
        JOIN
        t_user_status s USING( user_id )
        JOIN
        t_result_log r USING( user_id )
        JOIN
        t_result_text m USING(result_id,sequence_id)
        JOIN
        t_gender_map g USING( gender )
    WHERE
        b.carrier_id = ?
        AND
        b.uid = ?
        AND
        r.result_log_id = ?
    ORDER BY r.sequence_id LIMIT 1 OFFSET $offset
    ";

my $sth  = $db->prepare($get_result_sql);
my $stat = $sth->execute(($carrier_id, $mob_uid, $rid));
my $row ;



if ( $sth->rows() > 0 )
{
    my $lines = 0;
    while( $row  = $sth->fetchrow_hashref() )
    {
        $lines++;
        my $result_text = sprintf("%s<br />",$row->{result});
        $result_text =~ s/\n/<br \/>/g;
        $out->{RESULT} .= $result_text;
        $out->{RESULT_TITLE} = $row->{result_title};
    }
    $pu->output_log("passed find result row. count[$lines]");
    # Append next link;
    if ( $total_number > $offset + 1 )
    {
        $out->{RESULT} .= sprintf("<hr /><a href=\"recent_text.cgi?guid=ON&offset=%s\">1.続きへ</a><br />", ++$offset);
    }
    else
    {
        $out->{RESULT} .= sprintf("<br />\n--End of Scene--<br />\n");
    }
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

