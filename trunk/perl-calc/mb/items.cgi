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
    NAME  => "ゲスト",
    MSG   => "よろしくおねがいします",
    BRD   => "",
    PLACE => "彼の庭",
    GOLD  => 120327,
    FACE  => 0,
    HAIR  => 0,
    V_HP  => 100,
    V_MHP => 100,
    V_CON => "0&nbsp;&nbsp;",
    V_ATK => "89&nbsp;",
    V_MAG => "0&nbsp;&nbsp;",
    V_DEF => "60&nbsp;",
    V_AGL => "55&nbsp;",
    V_KHI => "100",
    V_SNC => "100",
    V_LUK => "100",
    V_HMT => "100",
    V_CHR => "100",
});




my $max_item = 30;
#my $base_dir = "/home/users/2/ciao.jp-anothark/web";
#my $dp = "$base_dir/data";
#my $t  = "$dp/anothark";
#
#$at->setBase("$t/template.html");
#$at->setBody("$t/body_items.html");
#
#$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
#$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );


#$at->setBase("template.html");
$at->setBody("body_items.html");

#$pu->setSystemLog( "aa_calc.log" );
#$pu->setAccessLog( "aa_access.log" );

$at->setPageName("ｱｲﾃﾑ");
my $version = "0.1a20120328";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();


# ActionTypeCheck
our %ITEM_ACTIONS = (
    use    => sub { return use_item(@_); },
    descr  => sub { return descr_item(@_); },
    pass   => sub { return pass_item(@_); },
    mart   => sub { return mart_item(@_); },
    sell   => sub { return sell_item(@_); },
    reject => sub { return reject_item(@_); },
);

$out->{"PRE_RESULT"} = "";
$out->{"PRE_RESULT"} .= join("\n", map{ &{$ITEM_ACTIONS{$_}}($c) } grep { exists $ITEM_ACTIONS{$_} } ($c->param) );


## Main

my $sth  = $db->prepare("SELECT b.user_id AS user_id, b.user_name AS user_name, b.msg AS msg, b.face_type AS face_type, b.hair_type AS hair_type, s.a_max_hp AS max_hp, s.a_hp AS hp,n.node_name
FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.carrier_id = ? AND b.uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();

$pu->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, row: %s",$carrier_id, $mob_uid, $sth->rows() ));

if ( $sth->rows() == 0 )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");
    exit;
}

my $user_id = $row->{user_id};
#$out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
#$out->{V_HP} =  $row->{hp};
#$out->{V_MHP} = $row->{max_hp};
#$out->{MSG}   = $row->{msg};
#$out->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
#$out->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};
#$out->{PLACE} = $row->{node_name};


my $having_item_sql = "SELECT i.item_label, u.item_id FROM t_user_item AS u JOIN t_item_master AS i USING( item_master_id ) WHERE u.user_id = ? ORDER BY item_master_id,item_id";
my $item_sth = $db->prepare($having_item_sql);
my $stat_item = $item_sth->execute(($user_id));

my @oddeven = ( "odd", "even" );

$out->{RESULT_TITLE} = "道具";
my $lines = 0;

if ( $item_sth->rows > 0 )
{
    $out->{RESULT} = "<form name=\"item\" method=\"get\" action=\"items.cgi\">\n";
    $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";
    while( $row  = $item_sth->fetchrow_hashref() )
    {
        $lines++;
#        $out->{RESULT} .= sprintf("<input type=\"checkbox\" name=\"i_%s\" />&nbsp;%s<br />\n",$row->{item_id}, $row->{item_label})
        $out->{RESULT} .= sprintf("<div class=\"item_%s\"><input type=\"checkbox\" name=\"iid\" value=\"%s\" />&nbsp;%s</div>\n",$oddeven[$lines%2], $row->{item_id}, $row->{item_label})
    }
#    $out->{RESULT} .= "<input type=\"submit\" name=\"use\" value=\"5.使う\" /><input type=\"submit\" name=\"descr\" value=\"見る\" /><input type=\"submit\" name=\"pass\" value=\"渡す\" /><br /><input type=\"submit\" name=\"mart\" value=\"ﾊﾞｻﾞｰに出す\" /><input type=\"submit\" name=\"sell\" value=\"ｼｮｯﾌﾟに売る\" /><input type=\"submit\" name=\"reject\" value=\"捨てる\" /></form>\n";
    $out->{RESULT} .= <<_HERE_
<select name="act">
<option value="descr">詳しく見る</option>
<option value="use">使う</option>
<option value="merge">まとめる</option>
<option value="sep">分ける</option>
<option value="pass">渡す</option>
<option value="reject">捨てる</option>
<option value="mart">売り出し</option>
<option value="sell">ｼｮｯﾌﾟに売る</option>
$result_append
</select><input type="submit" value="5.実行" accesskey="5" />
</form>

_HERE_
}
else
{
    $out->{RESULT} .= "何も持っていません"
}

$db->disconnect();

$out->{RESULT_TITLE} .= sprintf("%s/%s", $lines, $max_item);

$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();




exit;

sub use_item
{
    return "use_item";
}

sub descr_item
{
    return "descr_item";
}

sub pass_item
{
    return "pass_item";
}

sub mart_item
{
    return "mart_item";
}

sub sell_item
{
    return "sell_item";
}

sub reject_item
{
    return "reject_item";
}


