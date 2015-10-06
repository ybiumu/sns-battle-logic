package Anothark::QueingBase;
#
# ��
#
$|=1;
use strict;

use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );

use DbUtil;
use MobileUtil;
use PageUtil;
use AaTemplate;
use Anothark::Battle;
use Anothark::Battle::Exhibition;
use Anothark::Character;
use Anothark::Skill;

use Anothark::Party;
use Anothark::PartyLoader;


use LoggingObjMethod;
use base qw( LoggingObjMethod );
sub new
{
    my $class   = shift;
    my $at = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setAt($at);
    return $self;
}




my $force = 0;
sub setForce
{
    my $class = shift;
    return $class->setAttribute( 'force', shift );
}

sub getForce
{
    return $_[0]->getAttribute( 'force' );
}


my $at = undef;
sub setAt
{
    my $class = shift;
    return $class->setAttribute( 'at', shift );
}

sub getAt
{
    return $_[0]->getAttribute( 'at' );
}


## �S���̑I����

our $select_members_selection = "
SELECT
    q.selection_id,
    COUNT(selection_id) AS num,
    SUM(
        CASE
        WHEN u.owner_id = 0
        THEN
            1
        ELSE
            0
        END
    ) AS priority
FROM
    t_user AS u
    JOIN 
    t_selection_que q
    USING( user_id )
WHERE
    ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
    AND
    q.selection_id <> 0
GROUP BY selection_id
ORDER BY num DESC, priority DESC LIMIT 1
";


# loop before
#
# TODO: party member�S���̏󋵂𓥂܂��Ȃ���΂����Ȃ�
#           -> �C�x���g�i�s�󋵂̏d�˂��킹
#               -> group by flagment_id HAVING COUNT(user_id) > party_member_num ?
# TODO: ����A���[�_�[�̑I�������������g���Ȃ�
#
#
# re:
# rc:
# r : �n���Ɋ�Â��i�s���U���g
our $select_result_summary_old = "
SELECT"
    .
    # �i�s��̃C�x���g�̃��U���g���Ƃꂽ��C�x���g 
    #    
    "
    IFNULL(
        re.result_id,
        IFNULL(
            r.result_id,
            rc.result_id
        )
    ) AS result_id,"
    .
    "
    IFNULL(
        re.enemy_group_id,
        IFNULL(
            r.enemy_group_id,
            rc.enemy_group_id
        )
    ) AS enemy_group_id,
    IFNULL(
        NULLIF(re.next_node_id, 0),
        IFNULL(
            NULLIF(r.next_node_id, 0),
            IFNULL(
                NULLIF(sel.next_node_id,0),
                s.node_id
            )
        )
    ) AS next_node_id
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_selection_que AS q USING(user_id)
    LEFT JOIN t_selection AS sel USING(selection_id)"
    .
## t_result_master.next_node_id ����T��
# �I�������̂��C�x���g�^
    "
    LEFT JOIN (
        t_event_master AS e
        LEFT JOIN
        t_result_master AS re
        ON ( e.event_id = re.parent_event_id )
        LEFT JOIN
        t_user_flagment AS cfe
        ON ( re.close_flag_id = cfe.flag_id )" . # XXX  ���O�����ł́H XXX user_id �ƌ������Ȃ��Ƒʖڂł́H XXX
"
    ) ON ( sel.event_id = e.event_id )"
    .
## t_selection.next_node_id ����T��
# �ړ���ŃC�x���g�����^
    "
    LEFT JOIN (
        t_user_flagment AS f
        LEFT JOIN
        t_result_master AS r
        ON ( f.flag_id = r.flag_id )
        LEFT JOIN
        t_user_flagment AS cf
        ON ( r.close_flag_id = cf.flag_id )" . # ���O����: �o���ς݂Ȃ甭�����Ȃ� XXX user_id �ƌ������Ȃ��Ƒʖڂł́H XXX
"
    ) ON ( f.user_id = u.user_id AND r.node_id = sel.next_node_id )"
    .
## t_user_status.node_id ����T��
# �ؗ����C�x���g�^
    "
    LEFT JOIN (
        t_user_flagment AS fc
        LEFT JOIN
        t_result_master AS rc 
        ON ( fc.flag_id = rc.flag_id )
        LEFT JOIN
        t_user_flagment AS cfc
        ON ( rc.close_flag_id = cfc.flag_id )" . #���O����: �o���ς݂Ȃ甭�����Ȃ� XXX user_id �� �������Ȃ��Ƒʖڂł�? XXX
"
    ) ON ( fc.user_id = u.user_id AND rc.node_id = s.node_id )"
    .
## ����ȊO�͌��ݒn��node_id
# �P���ؗ�
    "
WHERE u.user_id = ? AND cf.flag_id IS NULL AND cfc.flag_id IS NULL
ORDER BY RAND() * re.priority * re.rate DESC, re.result_id DESC, RAND() * r.priority * r.rate DESC, r.result_id DESC, RAND() * rc.priority * rc.rate DESC,rc.result_id DESC LIMIT 1"
;

#SELECT
#    IFNULL(r.result_id, rc.result_id) AS result_id,
#    IFNULL(r.enemy_group_id, rc.enemy_group_id) AS enemy_group_id,
#    IFNULL(NULLIF(sel.next_node_id,0), s.node_id ) AS next_node_id
#FROM
#    t_user AS u
#    JOIN t_user_status AS s USING(user_id)
#    JOIN t_selection_que AS q USING(user_id)
#    LEFT JOIN t_selection AS sel USING(selection_id)
#    LEFT JOIN t_result_master AS r ON ( r.node_id = sel.next_node_id )
#    JOIN t_result_master AS rc ON ( rc.node_id = s.node_id )
#WHERE u.user_id = ? ";



#        LEFT JOIN
#        t_result_master AS re
#        ON ( e.event_id = re.parent_event_id )
#        LEFT JOIN
#        t_user_flagment AS cfe
#        ON ( re.close_flag_id = cfe.flag_id )" . # XXX  ���O�����ł́H XXX user_id �ƌ������Ȃ��Ƒʖڂł́H XXX
#
# TODO 
# UNION���� UNION���Ƀv���C�I���e�B�t����LIMIT 1
#
# 1. �C�x���g�̈ړ���Ŕ�������C�x���g�̌���
#   1.1 ->
=pod
    t_selection AS sel  # �I����
      +t_event_master ON (sel.event_id = e.event_id ) # �I��������Ăяo�����C�x���g
        +t_result_master AS re ON ( e.event_id = re.parent_event_id ) # �C�x���g�ɕR�Â����U���g
          *(
            SELECT
               *
            FROM
                t_user AS u
                JOIN
                t_user_flagment AS uf 
                USING(user_id)
                JOIN
                (
                    t_selection AS sel
                    JOIN
                    t_event_master AS e
                    ON( sel.selection_id = ? AND  sel.event_id = e.event_id  )
                    JOIN
                    t_result_master AS re
                    ON( e.event_id = re.parent_event_id )
                )
                ON ( re.close_flag_id = uf.flag_id )
            WHERE
                ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) ) 
          )                                             # ���U���g�𔭐������邽�߂ɕK�v�ȃt���O�̔��@
=cut
#
#
# 2. �ʏ�s���̈ړ���Ŕ�������C�x���g�̌���
# 3. �ؗ����̏ꏊ�Ŕ�������C�x���g�̌���
# 
#



=pod
SELECT
    1 AS priority,
    re.result_id,
    re.enemy_group_id,
    IFNULL(
        NULLIF(re.next_node_id, 0),
        sel.next_node_id
) AS next_node_id
FROM
    t_user AS u
    JOIN
    t_user_flagment AS uf 
    USING(user_id)
    JOIN
    (
        t_selection AS sel
        JOIN
        t_event_master AS e
        ON( sel.selection_id = ? AND  sel.event_id = e.event_id  )
        JOIN
        t_result_master AS re
        ON( e.event_id = re.parent_event_id )
    )
    ON ( re.close_flag_id = uf.flag_id )
WHERE
    ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
GROUP BY
    result_id,enemy_group_id,next_node_id
HAVING COUNT(re.result_id) = ?
=cut


# in: selection_id, owner_id, owner_id, member_num
# node_id, flag_id, close_flag_id,result_id,enemy_group_id,next_node_id
our $new_sql_part_1 = "
SELECT
    1 AS priority,
    re.result_id,
    re.enemy_group_id,
    IFNULL(
        NULLIF(re.next_node_id, 0),
        sel.next_node_id
) AS next_node_id
FROM
    t_user AS u
    JOIN
    t_user_flagment AS uf 
    USING(user_id)
    JOIN
    (
        t_selection AS sel
        JOIN
        t_event_master AS e
        ON( sel.selection_id = ? AND  sel.event_id = e.event_id  )
        JOIN
        t_result_master AS re
        ON( e.event_id = re.parent_event_id )
    )
    ON ( re.close_flag_id = uf.flag_id )
WHERE
    ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
GROUP BY
    result_id,enemy_group_id,next_node_id
HAVING COUNT(re.result_id) = ?
";

# TODO
# in: selection_id, owner_id, owner_id, member_num
# node_id, flag_id, close_flag_id,result_id,enemy_group_id,next_node_id
our $new_sql_part_2 = "
SELECT
    2 AS priority,
    re.result_id,
    re.enemy_group_id,
    IFNULL(
        NULLIF(re.next_node_id, 0),
        sel.next_node_id
) AS next_node_id
FROM
    t_user AS u
    JOIN
    t_user_flagment AS uf 
    USING(user_id)
    JOIN
    (
        t_selection AS sel
        JOIN
        t_result_master AS re
        ON ( sel.selection_id = ? AND sel.next_node_id = re.node_id)
    )
    ON ( uf.flag_id = re.flag_id )
    LEFT JOIN
    t_user_flagment AS cuf
    ON ( cuf.user_id = u.user_id AND  re.close_flag_id = cuf.flag_id )
WHERE
    ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
GROUP BY
    result_id,enemy_group_id,next_node_id
HAVING COUNT(re.result_id) = ?
";

# in: owner_id, owner_id, member_num
our $new_sql_part_3 = "
SELECT
    3 AS priority,
    re.result_id,
    re.enemy_group_id,
    s.node_id AS next_node_id
FROM
    t_user AS u
    JOIN
    t_user_status AS s
    USING(user_id)
    LEFT JOIN
    t_user_flagment AS uf 
    USING(user_id)
    LEFT JOIN
    t_result_master AS re
    ON ( s.node_id = re.node_id AND uf.flag_id = re.flag_id )
    LEFT JOIN
    t_user_flagment AS cuf
    ON ( cuf.user_id = u.user_id AND  re.close_flag_id = cuf.flag_id )
WHERE
    ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
    AND
    cuf.flag_id IS NULL
GROUP BY
    result_id,enemy_group_id,next_node_id
HAVING COUNT(re.result_id) = ?
";




our $select_result_summary = "
SELECT
    *
FROM
(
    SELECT
        1 AS priority,
        re.result_id,
        re.enemy_group_id,
        IFNULL(
            NULLIF(re.next_node_id, 0),
            sel.next_node_id
    ) AS next_node_id
    FROM
        t_user AS u
        JOIN
        t_user_flagment AS uf 
        USING(user_id)
        JOIN
        (
            t_selection AS sel
            JOIN
            t_event_master AS e
            ON( sel.selection_id = ? AND  sel.event_id = e.event_id  )
            JOIN
            t_result_master AS re
            ON( e.event_id = re.parent_event_id )
        )
        ON ( re.close_flag_id = uf.flag_id )
    WHERE
        ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
    GROUP BY
        result_id,enemy_group_id,next_node_id
    HAVING COUNT(re.result_id) = ?
    ORDER BY RAND() * re.priority * re.rate DESC, re.result_id DESC LIMIT 1
) AS q1
UNION ALL
SELECT
    *
FROM
(
    SELECT
        2 AS priority,
        re.result_id,
        re.enemy_group_id,
        IFNULL(
            NULLIF(re.next_node_id, 0),
            sel.next_node_id
    ) AS next_node_id
    FROM
        t_user AS u
        JOIN
        t_user_flagment AS uf 
        USING(user_id)
        JOIN
        (
            t_selection AS sel
            JOIN
            t_result_master AS re
            ON ( sel.selection_id = ? AND sel.next_node_id = re.node_id)
        )
        ON ( uf.flag_id = re.flag_id )
        LEFT JOIN
        t_user_flagment AS cuf
        ON ( cuf.user_id = u.user_id AND  re.close_flag_id = cuf.flag_id )
    WHERE
        ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
    GROUP BY
        result_id,enemy_group_id,next_node_id
    HAVING COUNT(re.result_id) = ?
    ORDER BY RAND() * re.priority * re.rate DESC, re.result_id DESC LIMIT 1
) AS q2
UNION ALL
SELECT
    *
FROM
(
    SELECT
        3 AS priority,
        re.result_id,
        re.enemy_group_id,
        s.node_id AS next_node_id
    FROM
        t_user AS u
        JOIN
        t_user_status AS s
        USING(user_id)
        LEFT JOIN
        t_user_flagment AS uf 
        USING(user_id)
        LEFT JOIN
        t_result_master AS re
        ON ( s.node_id = re.node_id AND uf.flag_id = re.flag_id )
        LEFT JOIN
        t_user_flagment AS cuf
        ON ( cuf.user_id = u.user_id AND  re.close_flag_id = cuf.flag_id )
    WHERE
        ( u.owner_id = ? OR ( u.owner_id = 0 AND u.user_id = ? ) )
        AND
        cuf.flag_id IS NULL
    GROUP BY
        result_id,enemy_group_id,next_node_id
    HAVING COUNT(re.result_id) = ?
    ORDER BY RAND() * re.priority * re.rate DESC, re.result_id DESC LIMIT 1
) AS q3
ORDER BY priority LIMIT 1
";


our $bookin_log_id = "
INSERT INTO t_result_log (user_id, wday,hour, sequence_id, memo )
SELECT
    u.user_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    'for bokking batch'
FROM
    t_user AS u
WHERE
    u.user_id = ?
";

our $clear_current_result_sql = "
DELETE
    r
FROM
    t_result_log AS r
    JOIN
    t_user AS u
    USING(user_id)
WHERE
    u.user_id = ?
    AND
    r.wday = WEEKDAY(NOW())
    AND
    r.hour = HOUR(NOW())
";


our $cancel_result_sql = "
DELETE
    r
FROM
    t_result_log AS r
    JOIN
    t_user AS u
    USING(user_id)
WHERE
    u.user_id = ?
    AND
    r.result_log_id = ?
";



our $insert_pre = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text,memo)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    CONCAT(?,IFNULL(t.result_text,\"\"),?) AS result_text,
    'for prepost batch'
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.result_id = ? AND r.node_id = ? )
    LEFT JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? )
WHERE u.user_id = ? ";

our $insert_prepost = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text,memo)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    CONCAT(?,IFNULL(t.result_text,\"\"),?) AS result_text,
    'for prepost batch'
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.result_id = ? AND r.node_id = ? )
    LEFT JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? )
WHERE u.user_id = ? ";

our $flag_update = "
INSERT IGNORE INTO t_user_flagment(user_id,flag_id,enable)
SELECT
    ? AS user_id,
    append_flag_id,
    1
FROM
    t_event_master AS e
    JOIN
    t_flag_append AS f
    USING(event_id)
WHERE
    e.node_id = ?
    AND
    e.result_id = ?
";


# TODO ���ׂ����Ƃ́A
# sel ���T�u�N�G����

### BUGBUG
our $update_commit_node_sql = "
UPDATE
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    LEFT JOIN t_node_master AS sel ON ( sel.node_id = ? )
    LEFT JOIN t_node_master AS nm ON( sel.node_id = nm.node_id )
SET
    s.node_id = CASE
                WHEN nm.can_stay = 1
                THEN
                    IFNULL(NULLIF(sel.node_id,0), s.node_id )
                ELSE
                    s.node_id
                END,

    s.last_link_node = CASE
                       WHEN nm.node_id IS NOT NULL AND nm.use_link = 1
                       THEN
                           IFNULL(NULLIF(sel.node_id,0), s.node_id )
                       ELSE
                           s.last_link_node
                       END,
    s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )
WHERE
    u.user_id = ?
";




#our $update_commit_node_sql = "
#UPDATE
#    t_user AS u
#    JOIN t_user_status AS s USING(user_id)
#    JOIN t_selection_que AS q USING(user_id)
#    LEFT JOIN t_selection AS sel ON( q.selection_id = sel.selection_id )
#    LEFT JOIN t_node_master AS nm ON( sel.next_node_id = nm.node_id )
#SET
#    s.node_id = CASE
#                WHEN nm.can_stay = 1
#                THEN
#                    IFNULL(NULLIF(sel.next_node_id,0), s.node_id )
#                ELSE
#                    s.node_id
#                END,
#
#    s.last_link_node = CASE
#                       WHEN nm.node_id IS NOT NULL AND nm.use_link = 1
#                       THEN
#                           IFNULL(NULLIF(sel.next_node_id,0), s.node_id )
#                       ELSE
#                           s.last_link_node
#                       END,
#    s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )
#WHERE
#    u.user_id = ?
#";

our $rollback_node_sql = "
UPDATE
    t_user AS u
    JOIN
    t_user_status AS s
    USING(user_id)
SET
    s.node_id = s.last_link_node,
    s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )
WHERE
    u.user_id = ?
";




our $update_que_sql = "
REPLACE INTO
    t_selection_que(user_id,selection_id,queing_hour,qued)
SELECT u.user_id, 0, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.user_id = ? ";


our $insert_battle = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text,memo)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    ? AS result_text,
    'for battle batch'
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.result_id = ? AND r.node_id = ? )
    LEFT JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.user_id = ?";






# TODO �C�x���g�̌��ʁA���肷��A�C�e���ENPC�E������A�C�e���E�x�������K���̏�������؍l�����ĂȂ��B




















our $booking_sth;
our $result_pre_sth;
our $select_members_selection_sth;
our $result_sth;
our $rs_sth;
our $up_commit_sth;
our $up_rollback_sth;
our $up_que_sth;
our $result_sth_b;
our $clear_current_result_sth;

our $rollback_result_sth;

our $flagment_sth;
our $pl;
our $party;

sub doQueing
{

    my $last_status = 0;
    my $class  = shift;
    my $at     = $class->getAt();
    my $pu     = $at->getPageUtil();
    my $db     = $at->getDbHandler();
    my $rs_row = shift;
    my $pl = new Anothark::PartyLoader( $at );

    # �X�V�Ώۃ��[�U�[��(�I�[�i�[��)
    foreach my $user_id ( @{$rs_row} )
    {

        my $me = $at->getBattlePlayerByUserId($user_id->[0]);
        $party = $pl->loadBattlePartyByUser( $me, 'p' );
        $last_status = 0;

        $pu->notice("Target party_owner id[$user_id->[0]]");
# �����o�[�̑I��������D�悳���I������r�擾
        $pu->notice($select_members_selection_sth->execute(($user_id->[0], $user_id->[0])));
        my $sel_row = $select_members_selection_sth->fetchrow_hashref();
        my $selection_id = 0;
        if ( $select_members_selection_sth->rows() > 0 )
        {
            $selection_id = $sel_row->{selection_id};
        }
        else
        {
            $pu->notice(sprintf("Cannot found selection for owner[%s]", $user_id->[0]));
#            next;
        }


        my $members = [ $party->getPartyPlayer() ];
        my $member_num = scalar(@{$members});

# �I�����ʂ̃��U���g�T��
        $pu->notice("Target user id[$user_id->[0]]");
        $pu->notice(
            $rs_sth->execute(
                (
                    $selection_id, $user_id->[0],$user_id->[0], $member_num,
                    $selection_id, $user_id->[0],$user_id->[0], $member_num,
                    $user_id->[0],$user_id->[0], $member_num
                )
            )
        );
        my $rsum_row  = $rs_sth->fetchrow_hashref();
        if ( ! $rs_sth->rows() > 0 )
        {
            $pu->notice(sprintf("Cannot found result for owner[%s]", $user_id->[0]));
            next;
        }

        my $rid  = $rsum_row->{result_id};
        my $egid = $rsum_row->{enemy_group_id};
        my $nnid = $rsum_row->{next_node_id};
        $pu->notice("result summary [$rid/$egid/$nnid]");


        my $seq_id = 0;
        my $ins_pre = "";
        my $ins_post = "";
# log_id�̗\��

        # �����t���O
        $pu->debug("[Force Flag] : " . $class->getForce() );
        if ( $class->getForce() )
        {
            $pu->notice("Force queing.");
            map {
                my $id = $_->getId();
                $pu->notice("Clear duplicace result.[$id]");
                my $clear_result = $clear_current_result_sth->execute( ($id) );
                $pu->notice("Clear result.[$clear_result]");
            } @{$members}
        }

###############
### BOOKING ###
###############

        my $log_ids = {};
        my $booking_failure = 0;
        # TODO:DONE �S�����\��A��l�ł��~�X������H
        #     -> �S�����s�Ɋ񂹂�
        #         -> ���s���ꂽ�\��͔j������
        map {
            my $id = $_->getId();
            $pu->notice(sprintf "Value [%s]",join("/",($seq_id,$id)));
            my $booking_result = $booking_sth->execute(($seq_id, $id));
            $pu->notice(sprintf("Booking result [%s]",$booking_result));
            $booking_failure = 1 if ( not $booking_result);
            $log_ids->{$id} = $db->{'mysql_insertid'};
        } @{$members};


        $seq_id = 1;

        if ( $booking_failure )
        {
            $pu->warning(sprintf("Can't queing user_id[%s]",$user_id->[0]));
            # Rollback booking;
            $class->rollbackQueingResult($log_ids);
            $last_status = 2;
            next;
        }
        else
        {

# TODO �P���C�x���g�͂ǂ����������߂ĂȂ��B
# TODO �o�g�����Ȃ��ꍇ�́E�E�Epost�̂݁H
#   �ł��K��pre �����H



# next_node_id�Ŕ�������C�x���g�̌���
#
# SELECT * FROM t_event_master JOIN t_flag_append USING(event_id) LEFT JOIN t_user_flagment AS u ON (append_flag_id = u.flag_id AND u.user_id = 1 ) WHERE node_id = 2 AND u.user_id IS NULL
#ORDER BY priority LIMIT 1;





            my $pre_failure = 0;
            map {
                my $id = $_;
                my $log_id = $log_ids->{$id};
                my $affected = $result_pre_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$rid,$nnid,'pre',$id));
                $pu->notice("insert result[$affected]");
#        $seq_id++ if ( $affected && $affected ne "0E0" );
                if ( $affected eq "" || $affected eq "0E0")
                {
                    $pu->error("SQL error[" . $result_pre_sth->errstr . "]");
                    $pre_failure = 1;
                }
            } keys %{$log_ids};

            $seq_id = 2;

            if ( $pre_failure )
            {
                $pu->warning(sprintf("Can't queing user_id[%s]",$user_id->[0]));
                # Rollback pre and booking;
                $class->rollbackQueingResult($log_ids);
                $last_status = 2;
                next;
            }

            ## TODO flagment pre







##############
### Battle ###
##############
            # �G���J�E���g��������ꍇ
            if ( $egid > 0 )
            {
                my $battle = new Anothark::Battle( $at );
#                my $me = $at->getPlayerByUserId($user_id->[0]);
                # �o�g���p�̃v���C���[�Ɗ�����p�̃v���C���[�𕪂��邽�߁A
                # ���s���Ƀv���C���[���Z�b�g�������B
                my $tmp_player = $at->{PLAYER};
                $at->{PLAYER} = $me;

                # �o�g���̎��{
                # �o�g���̗l�X�ȏ��ɂ��A�N�Z�X�ł���悤�ɁABattle�I�u�W�F�N�g��Ԃ����ق�������?
                $battle->party($party);
                my $battle_html = Anothark::Battle::Exhibition::doExhibitionMatch( $battle, $me, $nnid );
                # �߂�
                $at->{PLAYER} = $tmp_player;





                my $battle_failure = 0;
                # 1. ���ʂ̕ۑ�
                # 1-1. �퓬text
                $pu->notice("SQL battle [$insert_battle]");
                map {
                    my $id = $_;
                    my $log_id = $log_ids->{$id};
                    my $affected = "";
                    $pu->notice(sprintf "Value [%s]",join("/",($log_id,$seq_id, $battle_html ,$rid ,$nnid,'battle',$id)));
                    $affected = $result_sth_b->execute(($log_id,$seq_id, $battle_html ,$rid,$nnid,'battle',$id));
                    $pu->notice("insert result[$affected]");
                    if ( $affected eq "" || $affected eq "0E0" )
                    {
                        $pu->error("SQL error[" . $result_sth_b->errstr . "]");
                        $battle_failure = 1;
                    }
                } keys %{$log_ids};


                $seq_id = 3;


                if ( $battle_failure )
                {
                    $pu->warning(sprintf("Can't battle queing user_id[%s]",$user_id->[0]));
                    # Rollback pre and booking;
                    $class->rollbackQueingResult($log_ids);
                    $last_status = 2;
                    next;
                }


################################
### Post Result after battle ###
################################
                if ($battle->isWin())
                {
                    $ins_pre = $battle->getResultText();

                    my $drops   = $battle->checkDropItems();
                    my ( $chk_exp, $exps ) = $battle->checkExperiment();
                    my $drop_items = { map { ( $_->getId() => [] ) } @{$members}};
#                    my $party   = $battle->getPartyMember();

                    # Drop item check
                    $ins_pre .= $chk_exp;
                    foreach my $items ( @{$drops} )
                    {
                        my $target = $members->[int(rand(scalar(@{$members})))];
#        $class->warning( sprintf( "[DROP R] %s", $items->getItemLabel()));
                        $ins_pre .= sprintf('<br />��%s��%s����ɓ��ꂽ!', $target->getName(),$items->getItemLabel());
#                        $target->getStatusIo()->getItem( $items->getItemMasterId() );
                        push(@{$drop_items->{$target->getId()}}, $items->getItemMasterId() );
                    }
                    $ins_pre .= "<br /><br />" if(scalar(@{$drops}));


# XXX Post �ɐi��ł������̋�����
## 'failure'��p�ӂ���H
# ENUM('failure')��p�ӂ���
# failure�𗘗p����SQL�̔��s�ƁA�e�L�X�g�̏���
#

                    my $post_failure = 0;
                    $pu->notice("SQL prepost [$insert_prepost]");
                    map{
                        my $id = $_;
                        my $log_id = $log_ids->{$id};
                        $pu->notice(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$id)));
                        my $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$id));
                        $pu->notice("insert result[$affected]");
                        if ( $affected eq "" || $affected eq "0E0" )
                        {
                            $pu->error("SQL error[" . $result_sth->errstr . "]");
                            $post_failure = 1;
                        }
                    } keys %{$log_ids};

                    $seq_id = 4;


                    if ( $post_failure )
                    {
                        $pu->warning(sprintf("Can't post queing user_id[%s]",$user_id->[0]));
                        # Rollback pre and booking;
                        $class->rollbackQueingResult($log_ids);
                        $last_status = 2;
                        next;
                    }


                    map {
                        my $char = $_;
                        my $id = $char->getId();
# TODO �����ɏ����������̂ł͂Ȃ��A�����ł�commit�𔭍s���邾���ɂ�����
                        map { $char->getStatusIo()->getItem($_) } @{$drop_items->{$id}};
                        $char->getStatusIo()->updateExp($exps->{$id});
                        $pu->notice("Win status: " . $up_commit_sth->execute(($nnid, $id)));
                        $pu->notice("Flagment status: " . $flagment_sth->execute(($id, $nnid, $rid)));
                    } @{$members};

# TODO �X�e�[�^�X�̕ۑ�
# �X�e�[�^�X�ُ�EHP�E���v�̂ݕۑ�

                }
                elsif( $battle->isDraw() )
                {
## TODO
# -> checkExp for drawing.

# change user_status for flag;
                    map {
                        my $char = $_;
                        my $id = $char->getId();
                        $pu->notice("Draw status: " . $up_rollback_sth->execute(($id)));
                    } @{$members};
                }
                else
                {
# change user_status for flag;
                    map {
                        my $char = $_;
                        my $id = $char->getId();
                        $pu->notice("Other status: " .$up_rollback_sth->execute(($id)));
                    } @{$members};
                }


            }
            # �G���J�E���g���Ȃ��ꍇ
            else
            {

# XXX Post �ɐi��ł������̋�����
# ENUM('failure')��p�ӂ���
# failure�𗘗p����SQL�̔��s�ƁA�e�L�X�g�̏���
#

                $pu->notice("SQL prepost [$insert_prepost]");
                my $result_failure = 0;
                map {
                    my $id = $_;
                    my $log_id = $log_ids->{$id};
                    $pu->notice(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$id)));
                    my $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$id));
                    $pu->notice("insert result[$affected]");
#            $seq_id++ if ( $affected && $affected ne "0E0" );
                    if ( $affected eq "" || $affected eq "0E0" )
                    {
                        $pu->error("SQL error[" . $result_sth->errstr . "]");
                        $result_failure = 1;
                    }
                } keys %{$log_ids};

                $seq_id = 3;

                if ( $result_failure )
                {
                    $pu->warning(sprintf("Can't result queing user_id[%s]",$user_id->[0]));
                    # Rollback pre and booking;
                    $class->rollbackQueingResult($log_ids);
                    $last_status = 2;
                    next;
                }

                map {
                    my $char = $_;
                    my $id = $char->getId();
                    # �m�[�h�̈ړ�����
                    $pu->notice("Commit node  status: " . $up_commit_sth->execute(($nnid, $user_id->[0])));
                    # �t���O����������Ȃ痧�Ă�
                    $pu->notice("Flagment status: " . $flagment_sth->execute(($user_id->[0], $nnid, $rid)));
                } @{$members};

            }


            map {
                my $id = $_;
                my $log_id = $log_ids->{$id};
                $pu->notice("Update next que status: " . $up_que_sth->execute($id));
            } keys %{$log_ids};


            $pu->notice("End que.");
        }

        # �X�V�����㏈��
        map {
            my $char = $_;
            my $id = $char->getId();
            # Party���U�̃N���A
            $pl->clearInvite($id);

            # Food�̃N���A

            # ���_�Ȃ��

        } @{$members};
    }
    return $last_status;
}


sub openMainSth
{
    my $class = shift;
    my $db    = $class->getAt()->getDbHandler();


    $select_members_selection_sth = $db->prepare($select_members_selection);
    $result_pre_sth = $db->prepare( $insert_pre );
    $result_sth = $db->prepare( $insert_prepost );
    $rs_sth = $db->prepare( $select_result_summary );
    $up_que_sth = $db->prepare( $update_que_sql );
    $up_commit_sth = $db->prepare($update_commit_node_sql);
    $up_rollback_sth = $db->prepare( $rollback_node_sql );
    $booking_sth = $db->prepare( $bookin_log_id );
    $result_sth_b = $db->prepare( $insert_battle );
    $flagment_sth = $db->prepare($flag_update);
    $rollback_result_sth = $db->prepare($cancel_result_sql);
    if ( $class->getForce() )
    {
        $clear_current_result_sth = $db->prepare($clear_current_result_sql);
    }
}

sub finishMainSth
{
    $select_members_selection_sth->finish();
    $result_pre_sth->finish();
    $result_sth->finish();
    $rs_sth->finish();
    $up_que_sth->finish();
    $up_commit_sth->finish();
    $up_rollback_sth->finish();
    $booking_sth->finish();
    $result_sth_b->finish();
    $flagment_sth->finish();
    $rollback_result_sth->finish();
    if ( defined $clear_current_result_sth )
    {
        $clear_current_result_sth->finish();
    }
}


# Rollback not fixed result.
sub rollbackQueingResult
{
    my $class   = shift;
    my $pu = $class->getAt()->getPageUtil();
    my $log_ids = shift;
    map {
        my $user_id = $_;
        my $id = $log_ids->{$user_id};
        if ($id)
        {
            $pu->notice("Rollback booking  result.[$id]");
            my $rollback_result = $rollback_result_sth->execute( ($user_id, $id) );
            $pu->notice("Rollback result.[$rollback_result]");
        }
    } keys %{ $log_ids }
}

1;
