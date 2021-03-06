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


my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();

$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" "call:recent_text.cgi" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');

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




our $out = $at->getOut();

##############
### depend ###
##############
$at->setBody("body_resultview.html");
$at->setPageName("リザルト");
my $version = "0.1a20120328";



############
### Main ###
############

my $rid = 0;
my $offset = $c->param("offset") || 0;

if( $offset !~ /^[1-9]\d*$/ )
{
    $offset = 0;
}

## get recent result_id
#my $get_recent_result_id_sql = "SELECT MAX(result_log_id) AS result_log_id, COUNT(result_log_id) AS number FROM t_user AS b JOIN t_result_log AS r USING( user_id )  WHERE b.carrier_id = ? AND b.uid = ? AND r.sequence_id <> 0;";
#my $get_recent_result_id_sql = "SELECT MAX(result_log_id) AS result_log_id, MAX(sequence_id) AS number FROM t_user AS b JOIN t_result_log AS r USING( user_id )  WHERE b.carrier_id = ? AND b.uid = ? AND r.sequence_id <> 0 GROUP BY result_log_id desc HAVING result_log_id = MAX(result_log_id) LIMIT 1";
my $get_recent_result_id_sql = "SELECT MAX(result_log_id) AS result_log_id, MAX(sequence_id) AS number FROM t_user AS b JOIN t_result_log AS r USING( user_id )  WHERE b.carrier_id = ? AND b.uid = ? AND r.sequence_id <> 0 GROUP BY result_log_id desc HAVING result_log_id = MAX(result_log_id) LIMIT 1";
my $pre_rid_sth = $db->prepare($get_recent_result_id_sql);
my $pre_rid_stat = $pre_rid_sth->execute(($carrier_id, $mob_uid));

if ( $pre_rid_sth->rows() > 0 )
{
    my $pre_row = $pre_rid_sth->fetchrow_hashref();
    $rid = $pre_row->{result_log_id};
}
$pre_rid_sth->finish();

my $get_result_id_sql = "SELECT COUNT(result_log_id) AS number FROM t_user AS b JOIN t_result_log AS r USING( user_id )  WHERE b.carrier_id = ? AND b.uid = ? AND r.result_log_id = ? AND r.sequence_id <> 0;";
my $pre_sth = $db->prepare($get_result_id_sql);
my $pre_stat = $pre_sth->execute(($carrier_id, $mob_uid, $rid));

my $recent_result_log_id = 0;
my $total_numnber = 0;

if ( $pre_sth->rows() > 0 )
{
    my $pre_row = $pre_sth->fetchrow_hashref();
    $total_number = $pre_row->{number};
}
$pre_sth->finish();

$pu->output_log("find result_log_id [$rid]");

## Main

my $get_result_sql = "
    SELECT
        NULLIF(m.result_title, \"\") AS result_title,
        REPLACE(REPLACE(r.result_text,'<_NAME_>',b.user_name),'<_SELF_CALL_>',g.self_call) AS result
    FROM
        t_user AS b
        JOIN
        t_user_status s USING( user_id )
        JOIN
        t_result_log r USING( user_id )
        LEFT JOIN
        t_result_text m USING(result_id,sequence_id)
        JOIN
        t_gender_map g USING( gender )
    WHERE
        b.carrier_id = ?
        AND
        b.uid = ?
        AND
        r.result_log_id = ?
        AND
        r.sequence_id <> 0
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
    $out->{RESULT_TITLE} .= sprintf("(%s/%s)", $offset, $total_number);
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

