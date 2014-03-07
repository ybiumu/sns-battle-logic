#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;

use Anothark::ShopManager;

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

#$pu->setContentType( $mu->getContentType() );
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
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
my $user_id = $out->{USER_ID};

# depend
$at->setBody("body_chose.html");
$at->setPageName("s“®‘I‘ð");

my $version = "0.1a20120328";

my $sm = new Anothark::ShopManager( $db );

if ( $sm->getExistsShop($user_id) )
{
    $out->{APPEND_CTL} .= "/<a href='shop.cgi?guid=ON'>¼®¯Ìß</a>";
}

my $debug_str = "";

$pu->output_log(sprintf( "UserId: ", $user_id ));

# param parse.
$out->{NAME}   = $c->param("name") || $out->{name};

$out->{CHOSED} = $c->param("chosed") || 0;
if ( $out->{CHOSED} == 1 )
{
#    "REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued) SELECT user_id, ? AS selection_id,'00', 0 FROM t_user AS u WHERE u.carrier_id = ? AND u.uid = ? ";
#    my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued) SELECT user_id, ? AS selection_id, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.carrier_id = ? AND u.uid = ? ");
    # Request forgery
    if ( $c->param("sel") )
    {
        my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued)  SELECT u.user_id, sel.selection_id, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) JOIN t_selection sel USING( node_id ) WHERE sel.selection_id = ? AND u.user_id = ? AND sel.visible = 1 ");
        $up_sth->execute(($c->param("sel"),$user_id));
        $up_sth->finish();
    }
    else
    {
        my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued)  SELECT u.user_id, 0, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.user_id = ? ");
        $up_sth->execute($user_id);
        $up_sth->finish();
    }
}





my $select_list_sql = "
SELECT
    selection_id,
    label,
    s.next_node_id
FROM
    t_selection AS s
    LEFT JOIN
    (
        SELECT flag_id FROM t_user_flagment WHERE user_id = ? AND enable = 1
    ) AS flg USING(flag_id)
WHERE
    s.node_id = ?
    AND
    s.visible = 1
    AND
    (
        s.flag_id = 0
        OR
        (
            s.flag_id <> 0
            AND
            flg.flag_id IS NOT NULL
        )
    )
";




# Check record exists.
my $sth  = $db->prepare("SELECT u.user_id, u.user_name, s.next_queing_hour, s.node_id, n.node_name, n.node_descr, n.node_img, q.selection_id FROM t_user AS u JOIN t_user_status AS s USING(user_id) JOIN t_node_master AS n USING(node_id) LEFT JOIN t_selection_que q USING( user_id ) WHERE user_id = ?");
my $stat = $sth->execute(($user_id));
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
    $out->{BGID} = sprintf "%05s", $out->{NODE_ID};

    my $r_sel = {};
    if ( $out->{SELECTION_ID} ne "" )
    {
        $r_sel->{$out->{SELECTION_ID}} = $checked_str;
    }
    else
    {
        $r_sel->{0} = $checked_str;
    }

    my $sth2  = $db->prepare( $select_list_sql );
    my $stat2 = $sth2->execute(($user_id,$out->{NODE_ID}));
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
            push(@sels, sprintf( "<input type=\"radio\" name=\"sel\" value=\"%s\"%s />%s(<a href=\"debug_node_view.cgi?nnid=%s\">%s</a>)", $sel_row->{selection_id}, $r_sel->{$sel_row->{selection_id}}, $sel_row->{label}, $sel_row->{next_node_id}, $sel_row->{next_node_id}) );
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


