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




our $out = $at->getOut();
my $user_id = $out->{USER_ID};

##############
### depend ###
##############
my $sel_map = {
    1 => 'UŒ‚',
    2 => '½·Ù',
    3 => 'W’†',
    4 => 'ˆÚ“®',
    5 => '±²ÃÑ',
#   6 => '—»‹@'.
};

my $template_map = {
    2 => "body_bs_skill_list.html",
    4 => "body_bs_position_list.html",
    5 => "body_bs_item_list.html",
    6 => "body_bs_pet_list.html",
    7 => "body_bs_skill_list.html",
};

my $update_parse_map = {
    2 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 AND skill_id = ? ",
    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 AND position_id = ? ORDER BY position_id DESC",
    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6 AND item_id = ? ",
    7 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) AND setting_slot = 0 ",
};

my $update_query_map = {
    1 => "UPDATE t_user_battle_setting SET turn1_extra_info = ?, turn1_setting_id = ? WHERE user_id = ?",
    2 => "UPDATE t_user_battle_setting SET turn2_extra_info = ?, turn2_setting_id = ? WHERE user_id = ?",
    3 => "UPDATE t_user_battle_setting SET turn3_extra_info = ?, turn3_setting_id = ? WHERE user_id = ?",
    4 => "UPDATE t_user_battle_setting SET turn4_extra_info = ?, turn4_setting_id = ? WHERE user_id = ?",
    5 => "UPDATE t_user_battle_setting SET turn5_extra_info = ?, turn5_setting_id = ? WHERE user_id = ?",
   -2 => "UPDATE t_user_battle_setting SET slot1_skill_id = ? WHERE LENGTH(?) > 0 AND user_id = ?",
   -1 => "UPDATE t_user_battle_setting SET slot2_skill_id = ? WHERE LENGTH(?) > 0 AND user_id = ?",
};

my $getlist_sql_map = {
    2 => "SELECT skill_id AS list_id,CONCAT(CONVERT(skill_name USING cp932),'[',skill_cost,']') AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 ",
    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 ORDER BY position_id DESC",
    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6",
    7 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) ",
};



my $getid_sql_map = {
    2 => "SELECT skill_id AS list_id, skill_name AS list_name, setting_slot FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 AND skill_id = ? ",
    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 AND position_id = ? ORDER BY position_id DESC",
    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6 AND item_id = ?",
    7 => "SELECT skill_id AS list_id,skill_name AS list_name, 0 AS setting_slot FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name, setting_slot FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) AND skill_id = ? ",
};

my $rebind_sql_map = {
    2 => "UPDATE t_user_having_skill SET setting_slot = ? WHERE user_id = ? AND skill_id = ?",
    7 => "UPDATE t_user_having_skill SET setting_slot = ? WHERE user_id = ? AND skill_id = ?",
};

my $clear_bind_map = {
    1 => "UPDATE t_user_battle_setting SET turn1_extra_info = 0, turn1_setting_id = 1 WHERE user_id = ?",
    2 => "UPDATE t_user_battle_setting SET turn2_extra_info = 0, turn2_setting_id = 1 WHERE user_id = ?",
    3 => "UPDATE t_user_battle_setting SET turn3_extra_info = 0, turn3_setting_id = 1 WHERE user_id = ?",
    4 => "UPDATE t_user_battle_setting SET turn4_extra_info = 0, turn4_setting_id = 1 WHERE user_id = ?",
    5 => "UPDATE t_user_battle_setting SET turn5_extra_info = 0, turn5_setting_id = 1 WHERE user_id = ?",
   -2 => "UPDATE t_user_battle_setting SET slot1_skill_id = 1 WHERE user_id = ?",
   -1 => "UPDATE t_user_battle_setting SET slot2_skill_id = 1 WHERE user_id = ?",
};


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

if ( $act ne "" && not scalar( grep { $setting_type eq $_ } keys %{$template_map}))
{
    my $position = ($slot =~ /^ac(.+)$/)[0];
    $out->{RESULT} .= "Simple save.[$slot][$setting_type][$position]";
    my $up_sth  = $db->prepare( $update_query_map->{$position} );
    my $up_stat = $up_sth->execute(( 0,$setting_type, $user_id ));
    $up_sth->finish();
    $pu->notice("UPDATE status is [$up_stat]");

    $act = "";
}
# desc save
elsif ( $done ne "" && scalar( grep { $setting_type eq $_ } keys %{$template_map}) )
{
    my $position = ($slot =~ /^ac(.+)$/)[0];
    my $chk_sth  = $db->prepare( $getid_sql_map->{$setting_type} );
    my $chk_stat = $chk_sth->execute(( $user_id,$list_id ));
    my $chk_rownum = $chk_sth->rows();
    my $chk_row  = $chk_sth->fetchrow_hashref();
    $chk_sth->finish();

    if ( $chk_rownum != 1 )
    {
        $out->{RESULT} .= 'Ý’è‚Å‚«‚Ü‚¹‚ñ';
    }
    else
    {

        my $up_sth  = $db->prepare( $update_query_map->{$position} );
        my $up_stat = $up_sth->execute(($list_id, $setting_type, $user_id ));
        $pu->warning("[POS] $position");
        $pu->warning("[SQL] $update_query_map->{$position}");
        $pu->warning("[PRM] " . join("/",($list_id, $setting_type, $user_id )));
        $up_sth->finish();
        $out->{RESULT} .= "Desc save.";
        if ( scalar( grep { $setting_type eq $_ } keys %{$rebind_sql_map} ) )
        {
            # Skill Rebind 
            my $rebind_sth  = $db->prepare( $rebind_sql_map->{$setting_type} );
            my $rebind_stat = $rebind_sth->execute(($slot, $user_id,$list_id ));
            $rebind_sth->finish();

            # Pre slot clear.
            my $pre_slot = $chk_row->{setting_slot};
            my $clear_sth   = $db->prepare( $clear_bind_map->{$pre_slot} );
            my $clear_stat = $clear_sth->execute(( $user_id ));


        }
        $pu->notice("UPDATE status is [$up_stat]");
    }
}

### SAVING done###

my $list_sql = "
SELECT
    turn.user_id,
    turn.position,
    bm.setting_name,
    bm.setting_id,
    turn.i AS info,
    CASE WHEN turn.s = 2 THEN s.skill_name WHEN turn.s = 4 THEN p.position_name WHEN turn.s = 5 THEN i.item_label ELSE turn.i END AS ex
FROM
(
    SELECT
        u.user_id,
        p.position,
        p.setting_id * CASE WHEN position = -2 THEN 2 WHEN position = -1 THEN 2 WHEN position = 1 THEN turn1_setting_id WHEN position = 2 THEN turn2_setting_id WHEN position = 3 THEN turn3_setting_id WHEN position = 4 THEN turn4_setting_id WHEN position = 5 THEN turn5_setting_id END AS s,
        p.extra_info * CASE WHEN position = -2 THEN slot1_skill_id WHEN position = -1 THEN slot2_skill_id WHEN position = 1 THEN turn1_extra_info WHEN position = 2 THEN turn2_extra_info WHEN position = 3 THEN turn3_extra_info WHEN position = 4 THEN turn4_extra_info WHEN position = 5 THEN turn5_extra_info END AS i
    FROM
        t_user AS u
        JOIN
        (
            pivot_battle AS p
            JOIN
            t_user_battle_setting AS b
        )
        USING(user_id)
    WHERE u.user_id = ?
) AS turn
LEFT JOIN
t_battle_setting_master AS bm
ON ( bm.setting_id = turn.s )
LEFT JOIN
(
    t_user_having_skill AS us
    JOIN
    t_skill_master AS s
    USING(skill_id)
)
ON( us.user_id = turn.user_id AND ( turn.s = 2 AND turn.i = us.skill_id))
LEFT JOIN
(
    t_user_item AS ui
    JOIN
    t_item_master AS i
    USING(item_master_id)
)
ON( us.user_id = turn.user_id AND ( turn.s = 5 AND turn.i = ui.item_id))
LEFT JOIN
t_position_master AS p
ON ( turn.s = 4 AND turn.i = p.position_id )

;
";


############
### Main ###
############

    if ( $act ne "" )
    {
        my $sth = $db->prepare( $getlist_sql_map->{$setting_type} );
        my $stat = $sth->execute(($user_id));
        my $rownum = $sth->rows();
        $out->{OUT_LIST} = "";
        if ( $rownum == 0 )
        {
            $at->setBody("body_any.html");
            $out->{RESULT} .= '*&nbsp;Ý’è‚Å‚«‚é•¨‚Í‚ ‚è‚Ü‚¹‚ñ&nbsp;*';
        }
        else
        {
            $out->{slot}         = $slot;
            $out->{setting_type} = $setting_type;
            $at->setBody($template_map->{$setting_type});
            while (my $sel_row = $sth->fetchrow_hashref() )
            {
                $out->{OUT_LIST} .= sprintf(
                    "<input type=\"radio\" name=\"list_id\" value=\"%s\"%s>%s<br />\n",
                    $sel_row->{list_id}, $cs eq $sel_row->{list_id} ? $checked_str : "" , $sel_row->{list_name} );
            }
        }
    }
    else
    {
        my $sth  = $db->prepare( $list_sql );
        my $stat = $sth->execute(($user_id));
        my $rownum = $sth->rows();
        $out->{SELECTION_STR} = "";
        if ( $rownum == 0 )
        {
            $out->{RESULT} .= "*&nbsp;–â‘è‚ª”­¶‚µ‚Ü‚µ‚½BŠÇ—ŽÒ‚É‚²•ñ‰º‚³‚¢&nbsp;*";
        }
        else
        {
            while (my $sel_row = $sth->fetchrow_hashref() )
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
                            $sel_map->{$_}
                        )
                    } sort keys %{$sel_map}
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
        $sth->finish();
    }




##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


