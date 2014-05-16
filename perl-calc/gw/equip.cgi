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
$at->setBody("body_equip.html");
$at->setPageName("装備変更");
my $version = "0.1a20120328";


our @oddeven = ( "odd", "even" );


# ActionTypeCheck

our %LIST_MANAGE = (
    merge  => 1,
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
our $done = $c->param("done") || "";

$out->{"PRE_RESULT"} = "";

if ( $done )
{
    my @equip_items = ();
    foreach my $pos ( (6,4,5,3,2,1,7) )
    {
        $out->{"PRE_RESULT"} .= sprintf("pos_%s: %s<br />\n", $pos, $c->param("pos_$pos")); 
        push( @equip_items, $c->param("pos_$pos")) if ( $c->param("pos_$pos") );
    }

    # check having.
    my $check_sql  = sprintf( "SELECT COUNT(*) AS much FROM t_user_item WHERE user_id = ? AND delete_flag = 0 AND item_id IN ( %s ) ", join(",", ("?") x scalar(@equip_items) ));
    my $check_sth  = $db->prepare($check_sql);
    my $stat_check = $check_sth->execute(($user_id, @equip_items));
    my $check_row  = $check_sth->fetchrow_hashref();
    $check_sth->finish();
    if ( $check_row->{much} == scalar(@equip_items) )
    {
        #  UPDATE.
        my $update_sql = "
UPDATE
    t_user_equip
SET
    pos_1 = ?,
    pos_2 = ?,
    pos_3 = ?,
    pos_4 = ?,
    pos_5 = ?,
    pos_6 = ?,
    pos_7 = ?
WHERE
    user_id = ?
        ";
        my $up_sth = $db->prepare($update_sql);
        my @params = map { $c->param("pos_$_") or 0 } (1 .. 7); 
        push(@params, $user_id);
        $up_sth->execute( (@params) );
        $up_sth->finish();
    }
    else
    {
        $out->{"PRE_RESULT"} .= sprintf("<span style='color: #ff0000;'>装備できないｱｲﾃﾑがあります!</span>")
    }
}




if ( $depth > 0 )
{

    $out->{"RESULT"} =  $out->{"PRE_RESULT"};
}
else
{

    $out->{RESULT} = "<form name=\"equip\" method=\"get\" action=\"equip.cgi\">\n";
    $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";

    my $having_item_sql = "
    SELECT
        i.item_label,
        u.item_id,
        u.broken_status,
        i.equip_position AS position
    FROM
        t_user_item AS u
        JOIN
        t_item_master AS i
        USING( item_master_id )
    WHERE u.user_id = ? AND u.delete_flag = 0 AND i.equip_position <> 0 ORDER BY item_master_id,item_id
    ";
    my $item_sth = $db->prepare($having_item_sql);
    my $stat_item = $item_sth->execute(($user_id));
    my $items = $item_sth->fetchall_arrayref(+{});
    $item_sth->finish();

    my $user_equip_sql = "SELECT * FROM t_user_equip WHERE user_id = ?";
    my $equip_sth = $db->prepare($user_equip_sql);
    my $equip_stat = $equip_sth->execute(($user_id));
    my $equip_row = $equip_sth->fetchrow_hashref();
    $equip_sth->finish();


    $out->{RESULT_TITLE} = "装備変更";
    my $lines = 0;

    my $result_append = "";

    foreach my $pos ( (6,4,5,3,2,1,7) )
    {
        $out->{"list_pos_" . $pos} .= sprintf(
            "<input type='radio' name='pos_%s' value='0' %s>%s<br />\n",
            $pos, $equip_row->{"pos_$pos"} eq "0" ? "checked" : "" , '装備しない'
        );
        foreach my $e_item ( grep { $_->{position} eq $pos } @{$items} )
        {
            $out->{"list_pos_" . $pos} .= sprintf("<input type='radio' name='pos_%s' value='%s' %s>%s(%s)<br />\n", $pos, $e_item->{item_id}, $e_item->{item_id} eq $equip_row->{"pos_$pos"} ? "checked" : "" , $e_item->{item_label}, $e_item->{broken_status} );
        }
    }


    $out->{"POST_RESULT"} .= sprintf('<input type="submit" name="done" value="変更する" /></form>' );
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
    return ;
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
    return ;
}

sub mart_item
{
    return ;
}

sub sell_item
{
    my $at = shift;
    my $item_id = shift;

#    $at->getStatusIo()->sellItem( $at->getOut()->{USER_ID}, $item_id);
    my $result = $at->getStatusIo()->sellItem( $item_id );
    return $result ;
}

sub reject_item
{
    my $at = shift;
    my $item_id = shift;

#    $at->getStatusIo()->rejectItem( $at->getOut()->{USER_ID}, $item_id);
    $result = $at->getStatusIo()->rejectItem( $item_id);
    return $result;
}


sub merge_item
{
    my $at = shift;
    my @itemids = @_ ;

#    $at->getStatusIo()->rejectItem( $at->getOut()->{USER_ID}, $item_id);
    $at->getStatusIo()->mergeItem( @itemids );
    return ;
}


sub sep_item
{
    if ( $done )
    {
        return "sep_item_done"
    }
    my $at = shift;
    my @itemids = @_;
    my $return_str = '<div class="contents3">取り出す個数を入力して下さい</div>';
    my $lines = 0;
    map {
        $return_str .= sprintf(
                qq|<div class="item_%s">%s x%s <input type="text" name="isep_%s" value="0" size="2" maxlength="2" /></div>\n|,
                $oddeven[$lines++%2],
                $_->getItemLabel(),
                $_->getMergedNumber(),
                $_->getItemId(),
        );
    } grep { $_->getMergeNumber() > 1 } $il->loadUserItem($at->getOut()->{USER_ID}, @itemids);
    return $return_str;
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

sub pre_merge_item
{
    return "pre_merge_item";
}


sub pre_sep_item
{
    my $at = shift;
    my $c = shift;
    if ( not $done )
    {
        $depth = 1;
        $at->setBody("body_item_sep.html");
        $at->setPageName("ｱｲﾃﾑ&gt;分ける");
        $il = new Anothark::ItemLoader( $at->getDbHandler() );
#    $pre_sth = $at->getDbHandler()->prepare($sql);
    }
    else
    {
    }
    return "pre_sep_item";
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


sub post_merge_item
{
    return "post_merge_item";
}

sub post_sep_item
{
    my $at = shift;
    my $c = shift;
    if ( $done )
    {
        my $targets = { map { my $key = $_;$key =~ /isep_(\d+)$/g; $1 => $c->param($key)} grep { /^isep_/} $c->all_parameters() };
        $at->getStatusIo()->sepItem( $targets );
        return 'ｱｲﾃﾑを取り出しました'; 
    }
    return "post_sep_item";
}

