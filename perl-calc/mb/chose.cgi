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

our $out = $at->setOut({
    name   => "",
    face   => 0,
    hair   => 0,
    gendar => 0,
});

#my $base_dir = "/home/users/2/ciao.jp-anothark/web";
#my $dp = "$base_dir/data";
#my $t  = "$dp/anothark";
#$at->setBase("$t/template.html");
#$at->setBody("$t/body_chose.html");
#
#$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
#$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );

$at->setBase("template.html");
$at->setBody("body_chose.html");

$pu->setSystemLog( "aa_calc.log" );
$pu->setAccessLog( "aa_access.log" );

$at->setPageName("s“®‘I‘ð");

my $version = "0.1a20120328";

my $mu = new MobileUtil();

$pu->setContentType( $mu->getContentType() );
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();

my $debug_str = "";



$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();

#$debug_str .= "UI: $mob_uid <br />\n";
my $c = new CGI();


# param parse.
$out->{NAME}   = $c->param("name") || $out->{name};

$out->{CHOSED} = $c->param("chosed") || 0;
if ( $out->{CHOSED} == 1 )
{
#    "REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued) SELECT user_id, ? AS selection_id,'00', 0 FROM t_user AS u WHERE u.carrier_id = ? AND u.uid = ? ";
#    my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued) SELECT user_id, ? AS selection_id, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.carrier_id = ? AND u.uid = ? ");
    # Request forgery
    my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued)  SELECT u.user_id, sel.selection_id, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) JOIN t_selection sel USING( node_id ) WHERE sel.selection_id = ? AND u.carrier_id = ? AND u.uid = ? AND sel.visible = 1 ");
    $up_sth->execute(($c->param("sel"),$carrier_id, $mob_uid));
}






# Check record exists.
my $sth  = $db->prepare("SELECT u.user_id, u.user_name, s.next_queing_hour, s.node_id, n.node_name, n.node_descr, n.node_img, q.selection_id FROM t_user AS u JOIN t_user_status AS s USING(user_id) JOIN t_node_master AS n USING(node_id) LEFT JOIN t_selection_que q USING( user_id ) WHERE carrier_id = ? AND uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
$pu->output_log(sprintf( "c: %s u:%s ", $carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();
my $rownum = $sth->rows();
$sth->finish();
if ( $rownum == 1 )
{
    $out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
    $out->{QUE_HOUR} = $row->{next_queing_hour};
    $out->{NODE_ID}  = $row->{node_id};
    $out->{NODE_IMG} = $row->{node_img};
    $out->{NODE_DESCR} = $row->{node_descr};
    $out->{NODE_NAME}  = $row->{node_name};
    $out->{SELECTION_ID} = $row->{selection_id};

    my $r_sel = {};
    if ( $out->{SELECTION_ID} ne "" )
    {
        $r_sel->{$out->{SELECTION_ID}} = $checked_str;
    }
    else
    {
        $r_sel->{0} = $checked_str;
    }

    my $sth2  = $db->prepare("SELECT selection_id, label  FROM t_selection AS s LEFT JOIN ( SELECT flag_id FROM t_user JOIN t_user_flagment USING(user_id) WHERE carrier_id = ? AND uid = ? AND enable = 1 ) AS flg USING(flag_id) WHERE s.node_id = ? AND s.visible = 1 AND ( s.flag_id = 0 OR ( s.flag_id <> 0 AND flg.flag_id IS NOT NULL ))");
    my $stat2 = $sth2->execute(($carrier_id, $mob_uid,$out->{NODE_ID}));
    my $rownum2 = $sth2->rows();
    $out->{SELECTION_STR} = "";
    if ( $rownum2 == 0 )
    {
        $out->{SELECTION_STR} = "*&nbsp;‘I‘ðŽˆ‚Í‚ ‚è‚Ü‚¹‚ñ&nbsp;*";
    }
    else
    {
        my @sels = (sprintf('<input type="radio" name="sel" value="0" %s/>‚Ü‚¾Œˆ‚ß‚Ä‚È‚¢',$r_sel->{0}));
        while (my $sel_row = $sth2->fetchrow_hashref() )
        {
            push(@sels, sprintf( "<input type=\"radio\" name=\"sel\" value=\"%s\"%s />%s", $sel_row->{selection_id}, $r_sel->{$sel_row->{selection_id}}, $sel_row->{label}) );
        }
        $out->{SELECTION_STR} = join( "<br />\n", @sels);
    }
    # Redirect event mapper
    $sth2->finish();
}


$db->disconnect();

#$debug_str .= "RN: $rownum <br />\n";


$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;


