#!/usr/bin/perl
#: Battle Setting :#
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
use Anothark::BattleSetting;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
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



my $bs = new Anothark::BattleSetting( $db );

our $out = $at->getOut();
my $user_id = $out->{USER_ID};

$bs->setUserId($user_id);

##############
### depend ###
##############
#my $sel_map = {
#    1 => 'UŒ‚',
#    2 => '½·Ù',
#    3 => 'W’†',
#    4 => 'ˆÚ“®',
#    5 => '±²ÃÑ',
##   6 => '—»‹@'.
#};
#
#my $template_map = {
#    2 => "body_bs_skill_list.html",
#    4 => "body_bs_position_list.html",
#    5 => "body_bs_item_list.html",
#    6 => "body_bs_pet_list.html",
#    7 => "body_bs_skill_list.html",
#};
#
#my $update_parse_map = {
#    2 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 AND skill_id = ? ",
#    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 AND position_id = ? ORDER BY position_id DESC",
#    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6 AND item_id = ? ",
#    7 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) AND setting_slot = 0 ",
#};
#
#my $update_query_map = {
#    1 => "UPDATE t_user_battle_setting SET turn1_extra_info = ?, turn1_setting_id = ? WHERE user_id = ?",
#    2 => "UPDATE t_user_battle_setting SET turn2_extra_info = ?, turn2_setting_id = ? WHERE user_id = ?",
#    3 => "UPDATE t_user_battle_setting SET turn3_extra_info = ?, turn3_setting_id = ? WHERE user_id = ?",
#    4 => "UPDATE t_user_battle_setting SET turn4_extra_info = ?, turn4_setting_id = ? WHERE user_id = ?",
#    5 => "UPDATE t_user_battle_setting SET turn5_extra_info = ?, turn5_setting_id = ? WHERE user_id = ?",
#   -2 => "UPDATE t_user_battle_setting SET slot1_skill_id = ? WHERE LENGTH(?) > 0 AND user_id = ?",
#   -1 => "UPDATE t_user_battle_setting SET slot2_skill_id = ? WHERE LENGTH(?) > 0 AND user_id = ?",
#};
#
#my $getlist_sql_map = {
#    2 => "SELECT skill_id AS list_id,CONCAT(CONVERT(skill_name USING cp932),'[',skill_cost,']') AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 ",
#    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 ORDER BY position_id DESC",
#    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6",
#    7 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) ",
#};
#
#
#
#my $getid_sql_map = {
#    2 => "SELECT skill_id AS list_id, skill_name AS list_name, setting_slot FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 AND skill_id = ? ",
#    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 AND position_id = ? ORDER BY position_id DESC",
#    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6 AND item_id = ?",
#    7 => "SELECT skill_id AS list_id,skill_name AS list_name, 0 AS setting_slot FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name, setting_slot FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) AND skill_id = ? ",
#};
#
#my $rebind_sql_map = {
#    2 => "UPDATE t_user_having_skill SET setting_slot = ? WHERE user_id = ? AND skill_id = ?",
#    7 => "UPDATE t_user_having_skill SET setting_slot = ? WHERE user_id = ? AND skill_id = ?",
#};
#
#my $clear_bind_map = {
#    1 => "UPDATE t_user_battle_setting SET turn1_extra_info = 0, turn1_setting_id = 1 WHERE user_id = ?",
#    2 => "UPDATE t_user_battle_setting SET turn2_extra_info = 0, turn2_setting_id = 1 WHERE user_id = ?",
#    3 => "UPDATE t_user_battle_setting SET turn3_extra_info = 0, turn3_setting_id = 1 WHERE user_id = ?",
#    4 => "UPDATE t_user_battle_setting SET turn4_extra_info = 0, turn4_setting_id = 1 WHERE user_id = ?",
#    5 => "UPDATE t_user_battle_setting SET turn5_extra_info = 0, turn5_setting_id = 1 WHERE user_id = ?",
#   -2 => "UPDATE t_user_battle_setting SET slot1_skill_id = 1 WHERE user_id = ?",
#   -1 => "UPDATE t_user_battle_setting SET slot2_skill_id = 1 WHERE user_id = ?",
#};


$at->setBody("body_bs.html");
$at->setPageName("í“¬Ý’è");
my $version = "0.1a20130803";


my $act  = $c->param("change") || "";
my $slot = $c->param("slot") || "";
my $done = $c->param("done") || "";
my $cs   = $c->param("cs")   || "0";
my $list_id   = $c->param("list_id")   || "0";
my $setting_type = $c->param("setting_type") || "";


### SAVING ###
# simple save

if ( $act ne "" && not $bs->isDescTemplateSettingType( $setting_type ))
{
    my $position = $bs->parsePosition($slot);
    $out->{RESULT} .= "Simple save.[$slot][$setting_type][$position]";
    $bs->updateSimpleTemplate( $position, $setting_type);

    $act = "";
}
# desc save
elsif ( $done ne "" && $bs->isDescTemplateSettingType( $setting_type ) )
{
    my $position = $bs->parsePosition($slot);;

    my ($chk_rownum, $pre_slot ) = $bs->checkDescTemplate($position, $setting_type, $list_id);

    if ( $chk_rownum != 1 )
    {
        $out->{RESULT} .= 'Ý’è‚Å‚«‚Ü‚¹‚ñ';
    }
    else
    {
        $out->{RESULT} .= $bs->updateDescTemplate($position, $setting_type, $list_id, $slot,$pre_slot );
    }
}

### SAVING done###


############
### Main ###
############

    if ( $act ne "" )
    {
        my $result = $bs->getSettingList($setting_type);
        $out->{OUT_LIST} = "";
        if ( ! $result  )
        {
            $at->setBody("body_any.html");
            $out->{RESULT} .= '*&nbsp;Ý’è‚Å‚«‚é•¨‚Í‚ ‚è‚Ü‚¹‚ñ&nbsp;*';
        }
        else
        {
            $out->{slot}         = $slot;
            $out->{setting_type} = $setting_type;
            $at->setBody(Anothark::BattleSetting::TEMPLATE_MAP->{$setting_type});
            foreach  my $sel_row ( @{ $result } )
            {
                $out->{OUT_LIST} .= sprintf(
                    "<input type=\"radio\" name=\"list_id\" value=\"%s\"%s>%s<br />\n",
                    $sel_row->{list_id}, $cs eq $sel_row->{list_id} ? $checked_str : "" , $sel_row->{list_name} );
            }
        }
    }
    else
    {
        my $result = $bs->getBattleSettings();

        $out->{SELECTION_STR} = "";
        if ( ! $result )
        {
            $out->{RESULT} .= "*&nbsp;–â‘è‚ª”­¶‚µ‚Ü‚µ‚½BŠÇ—ŽÒ‚É‚²•ñ‰º‚³‚¢&nbsp;*";
        }
        else
        {
            foreach my $sel_row ( @{$result} )
            {
                my $pos_suffix = sprintf("ac%s", $sel_row->{position} );
                $out->{sprintf("cs_%s",$pos_suffix)} = $sel_row->{info} || 0;
                $out->{sprintf("c_%s",$pos_suffix)} = scalar( grep { $sel_row->{setting_id} eq $_ } (2,4,5,6) ) ? sprintf( "%s:%s", $sel_row->{setting_name}, $sel_row->{ex}) : sprintf "%s", $sel_row->{setting_name};
                $out->{sprintf("opt_%s",$pos_suffix)} = join(
                    "\n",
                    map {
                        sprintf(
                            '<option value="%s"%s>%s</option>',
                            $_,
                            $_ == $sel_row->{setting_id} ? $pu->getSelectedStr() : "",
                            Anothark::BattleSetting::SETTYPE_MAP->{$_}
                        )
                    } sort keys %{Anothark::BattleSetting::SETTYPE_MAP()}
                );
#            foreach my $key (sort keys %{$sel_row})
#            {
#                $out->{RESULT} .= sprintf(
#                    "%s: %s<br />\n",
#                    $key,
#                    $sel_row->{$key}
#                );
#            }
#            $out->{RESULT} .= sprintf( "<hr />\n" );
            }
        }
        # Redirect event mapper
#        $sth->finish();
    }




##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


