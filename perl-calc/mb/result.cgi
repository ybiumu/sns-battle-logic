#!/usr/bin/perl
############
### LOAD ###
############
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
$at->setBody("body_result.html");
$at->setPageName("ƒŠƒUƒ‹ƒg");
my $version = "0.1a20120328";






############
### Main ###
############

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

