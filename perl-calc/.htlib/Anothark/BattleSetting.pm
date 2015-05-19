package Anothark::BattleSetting;
#
# ˆ¤
#
$|=1;


use strict;
use Encode;

use LoggingObjMethod;
use base qw( LoggingObjMethod );

#our $sel_map = {
use constant SETTYPE_MAP => {
    1 => 'UŒ‚',
    2 => '½·Ù',
    3 => 'W’†',
    4 => 'ˆÚ“®',
    5 => '±²ÃÑ',
#   6 => '—»‹@'.
};

#our $template_map = {
use constant TEMPLATE_MAP => {
    2 => "body_bs_skill_list.html",
    4 => "body_bs_position_list.html",
    5 => "body_bs_item_list.html",
    6 => "body_bs_pet_list.html",
    7 => "body_bs_skill_list.html",
};

our $update_parse_map = {
    2 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 AND skill_id = ? ",
    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 AND position_id = ? ORDER BY position_id DESC",
    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6 AND item_id = ? ",
    7 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) AND setting_slot = 0 ",
};

our $update_query_map = {
    1 => "UPDATE t_user_battle_setting SET turn1_extra_info = ?, turn1_setting_id = ? WHERE user_id = ?",
    2 => "UPDATE t_user_battle_setting SET turn2_extra_info = ?, turn2_setting_id = ? WHERE user_id = ?",
    3 => "UPDATE t_user_battle_setting SET turn3_extra_info = ?, turn3_setting_id = ? WHERE user_id = ?",
    4 => "UPDATE t_user_battle_setting SET turn4_extra_info = ?, turn4_setting_id = ? WHERE user_id = ?",
    5 => "UPDATE t_user_battle_setting SET turn5_extra_info = ?, turn5_setting_id = ? WHERE user_id = ?",
   -2 => "UPDATE t_user_battle_setting SET slot1_skill_id = ? WHERE LENGTH(?) > 0 AND user_id = ?",
   -1 => "UPDATE t_user_battle_setting SET slot2_skill_id = ? WHERE LENGTH(?) > 0 AND user_id = ?",
};

our $getlist_sql_map = {
    2 => "SELECT skill_id AS list_id,CONCAT(CONVERT(skill_name USING cp932),'[',skill_cost,']') AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 ",
    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 ORDER BY position_id DESC",
    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6",
    7 => "SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) ",
};



our $getid_sql_map = {
    2 => "SELECT skill_id AS list_id, skill_name AS list_name, setting_slot FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type = 1 AND skill_id = ? ",
    4 => "SELECT position_id AS list_id, position_name AS list_name FROM t_position_master WHERE LENGTH(?) > 0 AND position_id = ? ORDER BY position_id DESC",
    5 => "SELECT item_id AS list_id,item_label AS list_name FROM t_item_master JOIN t_user_item USING(item_master_id) WHERE user_id = ? AND item_type_id = 6 AND item_id = ?",
    7 => "SELECT skill_id AS list_id,skill_name AS list_name, 0 AS setting_slot FROM t_skill_master WHERE skill_id = 1 UNION SELECT skill_id AS list_id,skill_name AS list_name, setting_slot FROM t_skill_master JOIN t_user_having_skill USING(skill_id) WHERE user_id = ? AND skill_type IN( 2,3 ) AND skill_id = ? ",
};

our $rebind_sql_map = {
    2 => "UPDATE t_user_having_skill SET setting_slot = ? WHERE user_id = ? AND skill_id = ?",
    7 => "UPDATE t_user_having_skill SET setting_slot = ? WHERE user_id = ? AND skill_id = ?",
};

our $postclear_bind_sql_map = {
    2 => "UPDATE t_user_having_skill SET setting_slot = 0 WHERE user_id = ? AND setting_slot = ? AND skill_id <> ?",
    7 => "UPDATE t_user_having_skill SET setting_slot = 0 WHERE user_id = ? AND setting_slot = ? AND skill_id <> ?",
};

our $clear_bind_map = {
    1 => "UPDATE t_user_battle_setting SET turn1_extra_info = 0, turn1_setting_id = 1 WHERE user_id = ?",
    2 => "UPDATE t_user_battle_setting SET turn2_extra_info = 0, turn2_setting_id = 1 WHERE user_id = ?",
    3 => "UPDATE t_user_battle_setting SET turn3_extra_info = 0, turn3_setting_id = 1 WHERE user_id = ?",
    4 => "UPDATE t_user_battle_setting SET turn4_extra_info = 0, turn4_setting_id = 1 WHERE user_id = ?",
    5 => "UPDATE t_user_battle_setting SET turn5_extra_info = 0, turn5_setting_id = 1 WHERE user_id = ?",
   -2 => "UPDATE t_user_battle_setting SET slot1_skill_id = 1 WHERE user_id = ?",
   -1 => "UPDATE t_user_battle_setting SET slot2_skill_id = 1 WHERE user_id = ?",
};


my $user_id = undef;

sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setDbHandler($db_handle);

    return $self;
}



sub isDescTemplateSettingType
{
    my $class = shift;
    my $setting_type = shift;
    return scalar(grep { $setting_type eq $_ } keys %{ TEMPLATE_MAP() });
}

sub parsePosition
{
    my $class = shift;
    my $slot = shift;
    my $position = ($slot =~ /^ac(.+)$/)[0];
    return $position;
}

sub updateSimpleTemplate
{
    my $class = shift;
    my $position = shift;
    my $setting_type = shift;
    my $user_id = $class->getUserId();
    my $db = $class->getDbHandler();

    my $up_sth  = $db->prepare( $update_query_map->{$position} );
    my $up_stat = $up_sth->execute(( 0,$setting_type, $user_id ));
    $up_sth->finish();
    $class->notice("UPDATE status is [$up_stat]");
    return $up_stat;
}


sub checkDescTemplate
{
    my $class = shift;
    my $position = shift;
    my $setting_type = shift;
    my $list_id = shift;
    my $user_id = $class->getUserId();
    my $db = $class->getDbHandler();

    my $chk_sth  = $db->prepare( $getid_sql_map->{$setting_type} );
    my $chk_stat = $chk_sth->execute(( $user_id,$list_id ));
    my $chk_rownum = $chk_sth->rows();
    my $chk_row  = $chk_sth->fetchrow_hashref();
    $chk_sth->finish();

    return ($chk_rownum, $chk_row->{setting_slot});
}

sub updateDescTemplate
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();
    my $position = shift;
    my $setting_type = shift;
    my $list_id = shift;
    my $slot = shift;
    my $pre_slot = shift;

    my $db = $class->getDbHandler();

    my $up_sth  = $db->prepare( $update_query_map->{$position} );
    my $up_stat = $up_sth->execute(($list_id, $setting_type, $user_id ));
    $class->warning("[POS] $position");
    $class->warning("[SQL] $update_query_map->{$position}");
    $class->warning("[PRM] " . join("/",($list_id, $setting_type, $user_id )));
    $up_sth->finish();
    my $message = "Desc save.";
    if ( scalar( grep { $setting_type eq $_ } keys %{$rebind_sql_map} ) )
    {

        # Skill Rebind 
        my $rebind_sth  = $db->prepare( $rebind_sql_map->{$setting_type} );
        my $rebind_stat = $rebind_sth->execute(($position, $user_id,$list_id ));
        $rebind_sth->finish();

        # Pre slot clear.
        $class->debug("Pre_Slot is [$pre_slot]");
#        my $pre_slot = $chk_row->{setting_slot};
        my $clear_sth   = $db->prepare( $clear_bind_map->{$pre_slot} );
        my $clear_stat = $clear_sth->execute(( $user_id ));
        $clear_sth->finish();


        # Skill postclear bind 
        my $postclear_bind_sth  = $db->prepare( $postclear_bind_sql_map->{$setting_type} );
        my $postclear_bind_stat = $postclear_bind_sth->execute(($user_id,$position,$list_id ));
        $postclear_bind_sth->finish();


    }
    $class->notice("UPDATE status is [$up_stat]");
    return $message;
}

### SAVING ###
# simple save


our $list_sql = "
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


sub getSettingList
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();
    my $setting_type = shift;

    my $db = $class->getDbHandler();

    my $sth = $db->prepare( $getlist_sql_map->{$setting_type} );
    my $stat = $sth->execute(($user_id));
    my $rownum = $sth->rows();
    my $result = "";
    if ( $rownum == 0 )
    {
        $result = "";
    }
    else
    {
        $result = $sth->fetchall_arrayref( +{} );
    }

    $sth->finish();
    return $result;

}

sub getBattleSettings
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();

    my $db = $class->getDbHandler();

    my $sth  = $db->prepare( $list_sql );
    my $stat = $sth->execute(($user_id));
    my $rownum = $sth->rows();
    my $result = "";

    if ( $rownum == 0 )
    {
        $result = "";
    }
    else
    {
        $result = $sth->fetchall_arrayref( +{} );
    }
    $sth->finish();
    return $result;
}




sub setDbHandler
{
    my $class = shift;
    return $class->setAttribute( 'db_handler', shift );
}

sub getDbHandler
{
    return $_[0]->getAttribute( 'db_handler' );
}


sub setUserId
{
    my $class = shift;
    return $class->setAttribute( 'user_id', shift );
}

sub getUserId
{
    return $_[0]->getAttribute( 'user_id' );
}



1;
