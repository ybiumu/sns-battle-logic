#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use PageUtil;
use AaTemplate;
use Anothark::Battle;
use Anothark::Character;
use Anothark::Skill;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



my $hour = (localtime())[2];

$pu->output_log("Start que at `$hour'.");




############
### Main ###
############

# ¡‚ÌŽžŠÔ‚Éˆ—‚·‚éƒ†[ƒU[‚ÌŒŸõ
my $select_users = "SELECT user_id FROM t_selection_que WHERE queing_hour = ? AND qued = 0";

my $rs_sth = $db->prepare( $select_users );
$pu->output_log($rs_sth->execute(( $hour )));

my $rs_row  = $rs_sth->fetchall_arrayref();
if ( ! $rs_sth->rows() > 0 )
{
    $rs_sth->finish();
    $db->disconnect();
    $pu->output_log("No target exists.");
    exit;
}

$rs_sth->finish();

my $seq_id = 0;
my $ins_pre = "";
my $ins_post = "";
# log_id‚Ì—\–ñ
my $bookin_log_id = "
INSERT INTO t_result_log (user_id, wday,hour, sequence_id )
SELECT
    u.user_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?
FROM
    t_user AS u
WHERE
    u.user_id = ?
";

my $insert_prepost = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    CONCAT(?,t.result_text,?) AS result_text
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.node_id = ? )
    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.user_id = ? ";

my $booking_sth = $db->prepare( $bookin_log_id );
my $result_sth = $db->prepare( $insert_prepost );
my $affected = "";

foreach my $user_id ( @{$rs_row} )
{
    $seq_id = 0;
    $pu->output_log(sprintf "Value [%s]",join("/",($seq_id,$user_id[0])));
    my $booking_result = $booking_sth->execute(($seq_id++, $user_id[0]));
    $pu->output_log(sprintf("Booking result [%s]",$booking_result));
    my $log_id = $db->{'mysql_insertid'};

    if (! $booking_result )
    {
        $pu->output_log(sprintf("Can't queing user_id[%s]",$user_id[0]));
        next;
    }
    else
    {

# –{“–‚Ínode‚É•R•t‚¢‚½ƒCƒxƒ“ƒg‚àŒ‹‡‚µ‚ÄA—Dæ‡ˆÊ‚Ì‚‚¢ƒCƒxƒ“ƒg‚©‚çˆ—‚·‚é‚æ‚¤‚É‚µ‚È‚¢‚Æ‚¢‚¯‚È‚¢
# insert result;
#my $insert_prepost = "
#INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,sequence_id,result_text)
#SELECT
#    ?,
#    u.user_id ,
#    r.result_id,
#    WEEKDAY(NOW()),
#    ?,
#    t.result_text
#FROM
#    t_user AS u
#    JOIN t_user_status AS s USING(user_id)
#    JOIN t_selection_que AS q USING(user_id)
#    JOIN t_selection AS sel USING(selection_id)
#    JOIN t_result_master AS r ON ( r.node_id = sel.next_node_id )
#    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.carrier_id = ? AND u.uid = ? ";


# next_node_id‚Å”­¶‚·‚éƒCƒxƒ“ƒg‚ÌŒŸõ
#
# SELECT * FROM t_event_master JOIN t_flag_append USING(event_id) LEFT JOIN t_user_flagment AS u ON (append_flag_id = u.flag_id AND u.user_id = 1 ) WHERE node_id = 2 AND u.user_id IS NULL
#ORDER BY priority LIMIT 1;


        $ins_pre = "";
        $ins_post = "";
        $affected = "";

        $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'pre',$user_id));
        $pu->output_log("insert result[$affected]");
        $seq_id++ if ( $affected && $affected ne "0E0" );
        $pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );
    }
}

$booking_sth->finish();

else
{










##############
### Battle ###
##############
    my $battle = new Anothark::Battle( $pu );
#    $battle->setCharacter();
#    my $me = new Anothark::Character();
    my $me = $at->getCharacterByUserId($out->{USER_ID});
#    $me->setId( $out->{USER_ID} );
    $me->setSide("p");
    $battle->appendCharacter( $me );

    my $npc1 = new Anothark::Character();
    $npc1->setId("hagis1");
    $npc1->setName("–ì—ÇÊ·Þ½A");
    $npc1->getHp()->setBothValue(20);
    $npc1->gDef()->setBothValue(0);
    $npc1->setCmd([
        [],
        new Anothark::Skill( '’´’áŽü”g' , {skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , {skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , {skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , {skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , {skill_rate => 6 ,length_type => 1, range_type => 2 } ),
    ]);
    $npc1->setSide("p");
    $npc1->getPosition()->setBothValue("f");
    $battle->appendCharacter( $npc1 );

    my $npc2 = new Anothark::Character();
    $npc2->setId("hagis2");
    $npc2->setName("–ì—ÇÊ·Þ½B");
    $npc2->getHp()->setBothValue(20);
    $npc2->gDef()->setBothValue(0);
    $npc2->setCmd([
        [],
        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
    ]);

    $npc2->setSide("p");
    $npc2->getPosition()->setBothValue("b");
    $battle->appendCharacter( $npc2 );



    my $rnd = int(rand(3));
    if ( $rnd )
    {
        my $enemy = new Anothark::Character();
        $battle->setPartyName("“¹’[‚Ì•óÎ");
        $battle->setPartyImg("load_king");
        $enemy->setId("load_king");
        $enemy->setName("Û°ÄÞ¥µ³Þ¥¼ÞªÑ½Ä°Ý");
        $enemy->getHp()->setBothValue(999);
        $enemy->gDef()->setBothValue(10);
        $enemy->setCmd([
            [],
            new Anothark::Skill( 'Ñ°Ý½Ä°Ý×²Ä'     , {skill_rate => 7 ,length_type => 3 } ),
            new Anothark::Skill( '¼ÞªÀÞ²Ä½Ìß×¯¼­' , {skill_rate => 5 ,length_type => 2 } ),
            new Anothark::Skill( 'ÙËÞ°½Íß¸ÄÙ'     , {skill_rate => 10 ,length_type => 3 }),
            new Anothark::Skill( 'ÀÞ²ÔÓÝÄÞ¸×¯¼­'  , {skill_rate => 20 ,length_type => 1 } ),
            new Anothark::Skill( 'ÒÃµÆ¯¸¥¼ÞªÑ½Ä°Ñ', {skill_rate => 15 ,length_type => 3 } ),
        ]);
        $enemy->setSide("e");
        $enemy->getPosition()->setBothValue("f");
        $battle->appendCharacter( $enemy );
    }
    else
    {
        $battle->setPartyName("ŒJ‚è•Ô‚·ˆ«–²");
        $battle->setPartyImg("endless_nightmare");

        my $enemy1 = new Anothark::Character();
        $enemy1->setId("zwei");
        $enemy1->setName("Â³Þ§²");
        $enemy1->getHp()->setBothValue(666);
        $enemy1->setCmd([
            [],
            new Anothark::Skill( 'ÌÞ¯¸½Ï¯¼­'    , {skill_rate => 7 ,length_type => 1 }),
            new Anothark::Skill( '²Ý»°ÄÏ°¶°'    , {skill_rate => 7 ,length_type => 1 }),
            new Anothark::Skill( 'ÌÞ¯¸Ø¯ËßÝ¸Þ'  , {skill_rate => 7 ,length_type => 3 }),
            new Anothark::Skill( '±ÊÞ×Ý½²ÝÀÌ¨±' , {skill_rate => 99,length_type => 3 }),
            new Anothark::Skill( 'ÌÞ¯¸´ÝÄÞ'     , {skill_rate => 99,length_type => 3 }),
        ]);
        $enemy1->setSide("e");
        $enemy1->getPosition->setBothValue("f");


        my $enemy2 = new Anothark::Character();
        $enemy2->setId("ein");
        $enemy2->setName("±²Ý");
        $enemy2->getHp()->setBothValue(666);
        $enemy2->setCmd([
            [],
            new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2 }),
            new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3 }),
            new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2 }),
            new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3 }),
            new Anothark::Skill( 'ÌÞ¯¸´ÝÄÞ'    , {skill_rate => 99 ,length_type => 3 }),
        ]);
        $enemy2->setSide("e");
        $enemy2->getPosition()->setBothValue("b");


        my $enemy3 = new Anothark::Character();
        $enemy3->setId("drei");
        $enemy3->setName("ÄÞ×²");
        $enemy3->getHp()->setBothValue(666);
        $enemy3->setCmd([
            [],
            new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3 }),
            new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2 }),
            new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3 }),
            new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2 }),
            new Anothark::Skill( 'ÌÞ¯¸´ÝÄÞ'    , {skill_rate => 99 ,length_type => 3 }),
        ]);
        $enemy3->setSide("e");
        $enemy3->getPosition()->setBothValue("b");

        $battle->appendCharacter( $enemy1 );
        $battle->appendCharacter( $enemy2 );
        $battle->appendCharacter( $enemy3 );
    }

    $battle->doBattle();

    my $battle_html = $battle->getBattleText();









    my $insert_battle = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    ? AS result_text
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.node_id = ? )
    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.carrier_id = ? AND u.uid = ? ";

    my $result_sth_b = $db->prepare( $insert_battle );
    my $affected_b = "";

    $pu->output_log("SQL [$insert_battle]");
    $pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id, $battle_html, ,$nnid,'battle',$carrier_id, $mob_uid)));
    $affected_b = $result_sth_b->execute(($log_id,$seq_id, $battle_html ,$nnid,'battle',$carrier_id, $mob_uid));
    $pu->output_log("insert result[$affected_b]");
    $seq_id++ if ( $affected_b && $affected_b ne "0E0" );
    $pu->output_log("SQL error[" . $result_sth_b->errstr . "]") if ( $affected_b eq "" );






###################
### Post Result ###
###################
    $ins_pre = $battle->getResultText();


    $pu->output_log("SQL [$insert_prepost]");
    $pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'post',$carrier_id, $mob_uid)));
    $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'post',$carrier_id, $mob_uid));
    $pu->output_log("insert result[$affected]");
    $seq_id++ if ( $affected && $affected ne "0E0" );
    $pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );


    $result_sth->finish();
## Main


#my $get_result_sql = "
#    SELECT
#        REPLACE(REPLACE(r.result_text,'<_NAME_>',b.user_name),'<_SELF_CALL_>',g.self_call) AS result
#    FROM
#        t_user AS b
#        JOIN
#        t_user_status s USING( user_id )
#        JOIN
#        t_result_log r USING( user_id )
#        JOIN
#        t_result_master m USING(result_id)
#        JOIN
#        t_gender_map g USING( gender )
#    WHERE
#        b.carrier_id = ?
#        AND
#        b.uid = ?
#    ORDER BY r.result_log_id,r.sequence_id DESC LIMIT 1
#";
#
#my $sth  = $db->prepare($get_result_sql);
##my $sth  = $db->prepare("SELECT REPLACE(r.result_text,'<_NAME_>',b.user_name) AS result FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_result_log r USING( user_id ) JOIN  t_result_master m USING(result_id) WHERE b.carrier_id = ? AND b.uid = ? ORDER BY r.result_log_id DESC LIMIT 1");
#my $stat = $sth->execute(($carrier_id, $mob_uid));
#my $row  = $sth->fetchrow_hashref();
#
#
#
#
#
#
#if ( ! $sth->rows() > 0 )
#{
#    exit;
#}
#$sth->finish();




# change user_status for flag;
    my $up_sth = $db->prepare("UPDATE t_user AS u JOIN t_user_status AS s USING(user_id) JOIN  t_selection_que AS q  USING(user_id) JOIN t_selection AS sel USING(selection_id)  SET s.node_id = sel.next_node_id, s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )  WHERE u.carrier_id = ? AND u.uid = ? ");
    $pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
    $up_sth->finish();





    my $flag_update = "
INSERT INTO t_user_flagment(user_id,flag_id,enable)
VALUES
    SELECT
        user_id,
        append_flag_id,
        1,
    FROM
        t_flag_append
        LEFT JOIN
        t_user_flagment AS u ON (append_flag_id = u.flag_id AND u.user_id = ? )
    WHERE
        node_id = ?
        AND
        event_id = ?
";

#    $up_sth->prepare($flag_update);
#
#    $pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
#    $up_sth->finish();




    my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued)  SELECT u.user_id, 0, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.carrier_id = ? AND u.uid = ? ");
    $up_sth->execute($carrier_id, $mob_uid);
    $up_sth->finish();

    $db->disconnect();

    $pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
    print $c->redirect("recent_text.cgi?guid=ON");    

    $pu->output_log("End que.");

}




exit;

