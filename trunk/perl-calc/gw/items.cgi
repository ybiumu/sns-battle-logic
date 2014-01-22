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
use Anothark::ItemLoader;
use Anothark::Item;
use Anothark::Character::StatusIO;

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
our $depth = 0;
our $il = undef;
our $pre_sth;
our $post_sth;

my $max_item = 30;
$at->setBody("body_items.html");
$at->setPageName("ｱｲﾃﾑ");
my $version = "0.1a20120328";




# ActionTypeCheck
our %PRE_ITEM_ACTIONS = (
    use    => sub { return pre_use_item(@_); },
    descr  => sub { return pre_descr_item(@_); },
    pass   => sub { return pre_pass_item(@_); },
    mart   => sub { return pre_mart_item(@_); },
    sell   => sub { return pre_sell_item(@_); },
    reject => sub { return pre_reject_item(@_); },
);
our %ITEM_ACTIONS = (
    use    => sub { return use_item(@_); },
    descr  => sub { return descr_item(@_); },
    pass   => sub { return pass_item(@_); },
    mart   => sub { return mart_item(@_); },
    sell   => sub { return sell_item(@_); },
    reject => sub { return reject_item(@_); },
);
our %POST_ITEM_ACTIONS = (
    use    => sub { return post_use_item(@_); },
    descr  => sub { return post_descr_item(@_); },
    pass   => sub { return post_pass_item(@_); },
    mart   => sub { return post_mart_item(@_); },
    sell   => sub { return post_sell_item(@_); },
    reject => sub { return post_reject_item(@_); },
);

############
### Main ###
############

my $row = "";
#my $sth  = $db->prepare("SELECT b.user_id AS user_id, b.user_name AS user_name, b.msg AS msg, b.face_type AS face_type, b.hair_type AS hair_type, s.a_max_hp AS max_hp, s.a_hp AS hp,n.node_name
#FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.carrier_id = ? AND b.uid = ?");
#my $stat = $sth->execute(($carrier_id, $mob_uid));
#my $row  = $sth->fetchrow_hashref();
#
#$pu->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, row: %s",$carrier_id, $mob_uid, $sth->rows() ));
#
#if ( $sth->rows() == 0 )
#{
#    $db->disconnect();
#    print $c->redirect("setup.cgi?guid=ON");
#    exit;
#}
#
#my $user_id = $row->{user_id};
##$out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
##$out->{V_HP} =  $row->{hp};
##$out->{V_MHP} = $row->{max_hp};
##$out->{MSG}   = $row->{msg};
##$out->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
##$out->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};
##$out->{PLACE} = $row->{node_name};


my $user_id = $out->{USER_ID};


my $act = $c->param("act") || "";
$out->{"PRE_RESULT"} = "";
if ( $act && exists $ITEM_ACTIONS{$act} ) 
{
#    &{$PRE_ITEM_ACTIONS{$act}}($at,$c);
    $out->{"PRE_RESULT"} .= &{$PRE_ITEM_ACTIONS{$act}}($at,$c) . "<br />\n";
#    $out->{"PRE_RESULT"} .= join("<br />\n", map{ &{$ITEM_ACTIONS{$act}}($at,$_) } ($c->param("iid")) );
    map{ &{$ITEM_ACTIONS{$act}}($at,$_) } ($c->param("iid"));
    $out->{"PRE_RESULT"} .=  "<br />\n" . &{$POST_ITEM_ACTIONS{$act}}($at,$c);
}




if ( $depth > 0 )
{
    $out->{"RESULT"} =  $out->{"PRE_RESULT"};
}
else
{
    my $having_item_sql = "SELECT i.item_label, u.item_id FROM t_user_item AS u JOIN t_item_master AS i USING( item_master_id ) WHERE u.user_id = ? AND u.delete_flag = 0 ORDER BY item_master_id,item_id";
    my $item_sth = $db->prepare($having_item_sql);
    my $stat_item = $item_sth->execute(($user_id));

    my @oddeven = ( "odd", "even" );

    $out->{RESULT_TITLE} = "道具";
    my $lines = 0;

    my $result_append = "";

    if ( $item_sth->rows > 0 )
    {
        $out->{RESULT} = "<form name=\"item\" method=\"get\" action=\"items.cgi\">\n";
        $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";
        while( $row  = $item_sth->fetchrow_hashref() )
        {
            $lines++;
            if ($lines > $max_item)
            {
                $out->{RESULT} .= sprintf("<div style=\"text-align: center;\">%s</div>\n", '--&nbsp;これ以上表示できません&nbsp;--');
                $lines = $item_sth->rows;
                last;
            }
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



    $out->{RESULT_TITLE} .= sprintf("%s/%s", $lines, $max_item);
}



$db->disconnect();


$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();




exit;

sub use_item
{
    my $at = shift;
    my $c = shift;
    return "use_item";
}

sub descr_item
{
    my $at = shift;
    my $item_id = shift;
    my $item = $il->loadUserItem($at->getOut()->{USER_ID}, $item_id);
    return sprintf("<div class='smallheader'>%s</div>%s\n<div class='smalldescr'>%s</div>\n", $item->getItemLabel(), "NoData<br />",$item->getItemDescr());
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
    my $at = shift;
    my $item_id = shift;

    $at->getStatusIo()->sellItem( $at->getOut()->{USER_ID}, $item_id);
    return "sell_item";
}

sub reject_item
{
    my $at = shift;
    my $item_id = shift;

    $at->getStatusIo()->rejectItem( $at->getOut()->{USER_ID}, $item_id);
    return "reject_item";
}




sub pre_use_item
{
    return "pre_use_item";
}

sub pre_descr_item
{
    my $at = shift;
    my $c = shift;
    $depth = 1;
    $at->setBody("body_any.html");
    $at->setPageName("ｱｲﾃﾑ&gt;詳細");
    $il = new Anothark::ItemLoader( $at->getDbHandler() );
#    $pre_sth = $at->getDbHandler()->prepare($sql);
    return "pre_descr_item";
}

sub pre_pass_item
{
    return "pre_pass_item";
}

sub pre_mart_item
{
    return "pre_mart_item";
}

sub pre_sell_item
{
    return "pre_sell_item";
}

sub pre_reject_item
{
    return "pre_reject_item";
}



sub post_use_item
{
    return "post_use_item";
}

sub post_descr_item
{
    return "post_descr_item";
}

sub post_pass_item
{
    return "post_pass_item";
}

sub post_mart_item
{
    return "post_mart_item";
}

sub post_sell_item
{
    return "post_sell_item";
}

sub post_reject_item
{
    return "post_reject_item";
}

