package AaTemplate;

#
# 愛
#

$|=1;
use strict;


use CGI;
use LoggingObjMethod;
use Avatar;
use LocalConfig;
use Anothark::Character;
use Anothark::Character::Player;
use Anothark::Character::StatusIO;
use Anothark::SnsNoticeManager;
use base qw( LoggingObjMethod );

use UniversalAnalytics;

my $base = "template.html";
my $css = "template.css";

my $spbase = "sptemplate.html";
my $spcss = "sptemplate.css";

my $sp_admin = "adm_sptemplate.html";
my $admin    = "adm_template.html";

my $body = undef;
my $base_html = undef;
my $body_html = undef;
my $base_css = undef;
my $status_io = undef;

my $page_util = undef;
my $mobile_util = undef;

my $db_handler = undef;
my $out = {};

my $notice = undef;

my $strict = 0;

my $ad_str = undef;
my $page_name = "No Name";

#my $gm_img = '<img src="img/icon/ico_gm.gif" />';
my $gm_img = '<img src="imgld.cgi?i=icon/ico_gm.gif&guid=ON" />';


my $img = undef;
my $task_str = '<a href="viewtasks.cgi?guid=ON">&gt;やることﾒﾓ</a>';
my $has_notice_task_str = '<a class="has_notice" href="viewtasks.cgi?guid=ON">&gt;やることﾒﾓ(__NOTICE_NUMBER__)</a>';

my $local_menu = undef;




our $common_base_sql = "
SELECT
    b.user_id AS user_id,
    b.user_name AS user_name,
    mn.rel AS rel,
    mn.vel AS vel,
    b.msg AS msg,
    b.face_type AS face_type,
    b.hair_type AS hair_type,
    b.is_gm AS is_gm,
    b.owner_id AS owner_id,
    s.rp AS rp,
    s.max_hp    AS max_hp,
    s.a_max_hp  AS a_max_hp,
    s.hp        AS hp,
    s.a_hp      AS a_hp,
    s.agl       AS agl,
    s.a_agl     AS a_agl,
    s.kehai     AS kehai,
    s.a_kehai   AS a_kehai,
    s.chikaku   AS chikaku,
    s.a_chikaku AS a_chikaku,
    s.luck      AS luck,
    s.a_luck    AS a_luck,
    s.kikyou    AS kikyou,
    s.a_kikyou  AS a_kikyou,
    s.chrm      AS chrm,
    s.a_chrm    AS a_chrm,
    s.atack     AS atack,
    s.a_atack   AS a_atack,
    s.magic     AS magic,
    s.a_magic   AS a_magic,
    s.def       AS def,
    s.a_def     AS a_def,
    s.stamina AS stamina,
    s.node_id AS node_id,
    s.position_code AS position,
    b.uuid,
    n.node_name
FROM
    t_user AS b
    JOIN
    t_user_money AS mn USING(user_id)
    JOIN
    t_user_status s USING( user_id )
    JOIN
    t_node_master n USING(node_id)
WHERE
    b.delete_flag = 0
";








sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setOut($out);
    $class->setPageName($page_name);
    $class->setBase($base);
    $class->setCss($css);
    $class->setTaskStr($task_str);
    $class->setStrict($strict );
}


sub setAdStr
{
    my $class = shift;
    return $class->setAttribute( 'ad_str', shift );
}

sub getAdStr
{
    return $_[0]->getAttribute( 'ad_str' );
}


sub setPageName
{
    my $class = shift;
    return $class->setAttribute( 'page_name', shift );
}

sub getPageName
{
    return $_[0]->getAttribute( 'page_name' );
}


sub setOut
{
    my $class = shift;
    return $class->setAttribute( 'out', shift );
}

sub getOut
{
    return $_[0]->getAttribute( 'out' );
}

sub setPageUtil
{
    my $class = shift;
    return $class->setAttribute( 'page_util', shift );
}

sub getPageUtil
{
    return $_[0]->getAttribute( 'page_util' );
}

sub setBodyHtml
{
    my $class = shift;
    return $class->setAttribute( 'body_html', shift );
}

sub getBodyHtml
{
    return $_[0]->getAttribute( 'body_html' );
}

sub setBaseHtml
{
    my $class = shift;
    return $class->setAttribute( 'base_html', shift );
}

sub getBaseHtml
{
    return $_[0]->getAttribute( 'base_html' );
}



sub setImg
{
    my $class = shift;
    return $class->setAttribute( 'img', getImagePath(shift) );
}

sub getImg
{
    return $_[0]->getAttribute( 'img' );
}

sub setBody
{
    my $class = shift;
    return $class->setAttribute( 'body', getTemplatePath(shift) );
}

sub getBody
{
    return $_[0]->getAttribute( 'body' );
}

sub setBase
{
    my $class = shift;
    return $class->setAttribute( 'base', getTemplatePath(shift) );
}

sub getBase
{
    return $_[0]->getAttribute( 'base' );
}


sub setCss
{
    my $class = shift;
    return $class->setAttribute( 'css', getTemplatePath(shift) );
}

sub getCss
{
    return $_[0]->getAttribute( 'css' );
}

sub setBaseCss
{
    my $class = shift;
    return $class->setAttribute( 'base_css', shift );
}

sub getBaseCss
{
    return $_[0]->getAttribute( 'base_css' );
}


sub getTemplatePath
{
    return sprintf("%s/%s", $LocalConfig::TEMPLATE_DIR, shift );
}

sub getImagePath
{
    return sprintf("%s/gw/img/%s", $LocalConfig::BASE_DIR, shift );
}


sub setDbHandler
{
    my $class = shift;
    return $class->setAttribute( 'db_handler', shift );
}

sub getDbHandler
{
#    $_[0]->getAttribute( 'db_handler' )->do("set names sjis");
    return $_[0]->getAttribute( 'db_handler' );
}


sub setMobileUtil
{
    my $class = shift;
    my $mu = $class->setAttribute( 'mobile_util', shift );
    $class->setStrict(0);
    if ( $mu->getBrowser() eq "P")
    {
        $class->setBase( $spbase );
        $class->setCss( $spcss );
    }
    return $mu;
}

sub setAdminUtil
{
    my $class = shift;
    my $mu = $class->setAttribute( 'mobile_util', shift );
    $class->setStrict(1);
    if ( $mu->getBrowser() eq "P")
    {
        $class->setBase( $sp_admin );
        $class->setCss( $spcss );
    }
    else
    {
        $class->setBase( $admin );
        $class->setCss( $css );
    }

    return $mu;
}


sub setStrict
{
    my $class = shift;
    return $class->setAttribute( 'strict', shift );
}

sub getStrict
{
    return $_[0]->getAttribute( 'strict' );
}


sub getMobileUtil
{
    return $_[0]->getAttribute( 'mobile_util' );
}


my $card_title = undef;
my $bg_id = undef;
my $enemy_id = undef;
sub setCardTitle
{
    my $class = shift;
    return $class->setAttribute( 'card_title', shift );
}

sub getCardTitle
{
    return $_[0]->getAttribute( 'card_title' );
}

sub setBgId
{
    my $class = shift;
    return $class->setAttribute( 'bg_id', shift );
}

sub getBgId
{
    return $_[0]->getAttribute( 'bg_id' );
}

sub setEnemyId
{
    my $class = shift;
    return $class->setAttribute( 'enemy_id', shift );
}

sub getEnemyId
{
    return $_[0]->getAttribute( 'enemy_id' );
}



sub setTaskStr
{
    my $class = shift;
    return $class->setAttribute( 'task_str', shift );
}

sub getTaskStr
{
    return $_[0]->getAttribute( 'task_str' );
}


sub setLocalMenu
{
    my $class = shift;
    return $class->setAttribute( 'local_menu', shift );
}

sub getLocalMenu
{
    return $_[0]->getAttribute( 'local_menu' );
}





sub setup
{
    my $class = shift;
    $class->loadBaseHtml();
    $class->loadBaseCss();
    $class->loadBodyHtml();


    my $out = $class->getOut();

    my $tmp_html;
eval(
    "\$tmp_html = <<_HERE_;
$class->{body_html}
_HERE_"
);

    if( $@ )
    {
        $tmp_html = sprintf "Template failure.<br />%s\n",$@;
    }

    my $base_css   = $class->{base_css};
    my $page_name  = $class->getPageName();
    my $ad_str     = $class->getAdStr();
    my $task_html  = $class->getTaskStr();
    my $local_menu = $class->getLocalMenu();
    my $notice     = $class->{out}->{NOTICE_NUMBER};

    if ( $class->getMobileUtil()->getBrowser() ne "P" )
    {
        $task_html = "<br />" . $task_html;
    }
    else
    {
        $task_html =~ s/&gt;//g;
    }

    if ( $ad_str )
    {
        $ad_str = '<div class="contents2">広告</div>'. $ad_str
    }

    $class->{base_html} =~ s/__TITLE__/$page_name/g;
    $class->{base_html} =~ s/__PAGE_TITLE__/$page_name/g;
    $class->{base_html} =~ s/__BASE_CSS__/$base_css/g;
    $class->{base_html} =~ s/__MESSAGE_BODY__/$tmp_html/g;
    $class->{base_html} =~ s/__LINK_TASKS__/$task_html/g;
    $class->{base_html} =~ s/__LOCAL_MENU__/$local_menu/g;
    $class->{base_html} =~ s/__ADD_SPACE__/$ad_str/g;
    $class->{base_html} =~ s/__NOTICE_NUMBER__/$notice/g;

    my $card_title = $class->getCardTitle();
    my $bg_id      = $class->getBgId();
    my $enemy_id   = $class->getEnemyId();

    $class->{base_html} =~ s/__CARD_TITLE__/$card_title/g;
    $class->{base_html} =~ s/__BG_ID__/$bg_id/g;
    $class->{base_html} =~ s/__ENEMY_ID__/$enemy_id/g;
}

sub output
{
    my $class = shift;
    $class->printHeader();

    print $class->getBaseHtml();
    if ( $class->getMobileUtil()->getBrowser() ne "P" )
    {
        $class->pageview();
    }
}

sub pageview
{
    my $class = shift;
    return UniversalAnalytics::pageview($class);
}

sub event
{
    my $class = shift;
    my $ec = shift;
    my $ea = shift;
    my $el = shift;
    my $ev = shift;

    return UniversalAnalytics::event($class, $ec,$ea,$el,$ev);
}

sub item
{
    my $class = shift;
    my $ti = shift;
    my $in = shift;
    my $ip = shift;
    my $iq = shift;

    return UniversalAnalytics::item($class, $ti,$in,$ip,$iq );
}

sub printHeader
{
    my $class = shift;
#    my $ct = $class->getPageUtil()->getContentType();
#    print <<_HEADER_;
#Content-type: $ct;
#
#<?xml version="1.0" encoding="Shift_JIS"?>
#<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
# "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
#_HEADER_
    if ($class->getMobileUtil() && $class->getMobileUtil()->getCarrierId())
    {
        $class->printFpHeader();
    }
    else
    {
        $class->printSpHeader();
    }
}

sub printFpHeader
{
    my $class = shift;
    my $ct = $class->getPageUtil()->getContentType();
    my $bw = $class->getMobileUtil()->getBrowser();
    if ( $bw eq "P" )
    {
        print <<_HEADER_;
Content-type: $ct;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html>
_HEADER_
    }
    else
    {
        print <<_HEADER_;
Content-type: $ct;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_
    }
}


sub printSpHeader
{
    my $class = shift;
    my $ct = $class->getPageUtil()->getContentType();
    print <<_HEADER_;
Content-type: $ct;

<!DOCTYPE html>
_HEADER_
}

sub loadBaseHtml
{
    my $class = shift;
    open(TEMP, $class->getBase()) || ( $class->getPageUtil()->printError("Can't open template 1") && exit);
    $class->setBaseHtml( join("",<TEMP>) );
    close(TEMP);
}


sub loadBaseCss
{
    my $class = shift;
    open(TEMP, $class->getCss()) || ( $class->getPageUtil()->printError("Can't open template 3") && exit);
    $class->setBaseCss( join("",<TEMP>) );
    close(TEMP);
}

sub loadBodyHtml
{
    my $class = shift;

    open(BODY, $class->getBody()) || ( $class->getPageUtil()->printError("Can't open template 2") && exit );
    $class->setBodyHtml( join("",<BODY>) );
    close(BODY);


}

# 自分のデータ
# getBaseDataByUserIdに統合したい
# -> けど自分以外で持ってきては行けないデータもある。継続。
sub setupBaseData
{
    my $class = shift;
    my $without_skill = shift || 0;
    my $template = "";
    if ($without_skill)
    {
        $template = new Anothark::Character::Player( {without_skill => 1} );
    }
    else
    {
        $template = new Anothark::Character::Player();
    }
    my $result = 0;
    my $char = $class->getMyCharacter( $template );

    if ( not $char )
    {
        # Not registerd.
        return $result;
    }

    if ( $class->getStrict() && not $char->getIsGm )
    {
        print CGI->header( -status => "404");
        exit 1;
    }


    $class->loadEquipData( $char );
    my $user_id = $char->getUserId();
    $class->{PLAYER} = $char;

    $result = 1;

    $class->setupOutFromCharacter( $char );

    $class->setStatusIo( $char->getStatusIo() );


    my $sns = new Anothark::SnsNoticeManager( $class );
    my $notice = $sns->hasNotice( $user_id );
    $class->{out}->{NOTICE_NUMBER} = $notice;

    if ( $notice )
    {
        $class->setTaskStr($has_notice_task_str);
    }

    return $result;
}


# 汎用ユーザーデータ取得
# 他人のマイペ
sub getBaseDataByUserId
{
    my $class = shift;
    my $user_id = shift;
    my $result = 0;
    my $template = new Anothark::Character::Player();

    my $char = $class->getCharacterByUserId($user_id,$template);
    if ( not $char )
    {
        return $result;
    }

    $class->loadEquipData( $char );


    $result = 1;

    $class->setupOutFromCharacter( $char );


    $char->fixInit();
    return $result;
}




sub loadEquipData
{
    my $class = shift;
    my $char  = shift;
    my $user_id = $char->getUserId();
    my $sql = <<_SQL_;
SELECT
    SUM(im.max_hp) AS max_hp,
    SUM(im.hp) AS hp,
    SUM(im.magic) AS magic,
    SUM(im.agl) AS agl,
    SUM(im.kikyou) AS kikyou,
    SUM(im.atack) AS atack,
    SUM(im.def) AS def,
    SUM(im.chrm) AS chrm,
    SUM(im.chikaku) AS chikaku,
    SUM(im.luck) AS luck,
    SUM(im.kehai) AS kehai,
    SUM(im.rp) AS rp,
    SUM(im.stamina) AS stamina,
    SUM( im.equip_skill_id ) AS equip_skill_id
FROM
    (
        SELECT
            pos.user_id,
            pos.position,
            pos.equip,
            ui.item_id,
            CASE WHEN pos.position = 9 THEN pos.equip
            ELSE ui.item_master_id
            END AS item_master_id
        FROM
            (
                SELECT
                    u.user_id,
                    p.position,
                    CASE
                    WHEN p.position = 1 THEN ue.pos_1
                    WHEN p.position = 2 THEN ue.pos_2
                    WHEN p.position = 3 THEN ue.pos_3
                    WHEN p.position = 4 THEN ue.pos_4
                    WHEN p.position = 5 THEN ue.pos_5
                    WHEN p.position = 6 THEN ue.pos_6
                    WHEN p.position = 7 THEN ue.pos_7
                    WHEN p.position = 8 THEN ue.pos_8
                    WHEN p.position = 9 THEN ue.pos_9
                    END AS equip
                FROM
                    t_user AS u
                    JOIN
                    (
                        pivot_equip AS p
                        JOIN
                        t_user_equip AS ue
                    )
                    USING(user_id)
                WHERE
                    u.user_id = ?
            ) AS pos
            LEFT JOIN
            t_user_item ui
            ON( pos.position < 9 AND ui.user_id = pos.user_id AND ui.item_id = pos.equip AND ui.delete_flag = 0 )
    ) AS base
    JOIN
    t_item_master im
    USING ( item_master_id )
_SQL_

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($user_id));
    my $row  = $sth->fetchrow_hashref();

    $char->getHp()->addBoth($row->{max_hp});
    $char->getHp()->mergeTotalStackValues();
    $char->setEquipSkillId( $row->{equip_skill_id} );
    map {
        warn "[KEY] $_ [add] $row->{$_} [BASE] $char->{$_}->{max_value}";
        $char->{$_}->addBoth( $row->{$_} );
        $char->{$_}->mergeTotalStackValues();
    } grep { ( not /^max_hp$/ ) && ( not /^equip_skill_id$/ ) } sort keys %{$row};

}

sub getBattlePlayerByUserId
{
    my $class   = shift;
    my $user_id = shift;
    my $w       = shift || 0;
    my $char = $class->getPlayerByUserId( $user_id, $w );
    # Load Equip
    $class->warning( "load equip [$user_id]" );

    $class->loadEquipData( $char );
    $char->fixInit();

    return $char;
}

sub getPlayerByUserId
{
    my $class   = shift;
    my $user_id = shift;
    my $w       = shift || 0;
    my $template = "";
    if ($w)
    {
        $template = new Anothark::Character::Player( {without_skill => 1} );
    }
    else
    {
        $template = new Anothark::Character::Player();
    }
    my $char = $class->getCharacterByUserId($user_id,$template);
    if ( not defined $char )
    {
        $class->warning( "undefined character. id [$user_id]" );
        return $char;
    }
#    my $ref = ref($char);
    $class->warning( "char is [$char]");
#    $char->setStatusIo( new Anothark::Character::StatusIO( $class->getDbHandler() ) );

    return $char;
}



sub setupCharacter
{
    my $class = shift;
    my $char  = shift;
    my $row   = shift;

    $char->setName($row->{user_name});
    $char->getHp()->setCurrentValue($row->{hp});
    $char->getHp()->setTotalStackValues($row->{a_hp});
    $char->getHp()->setMaxValue($row->{max_hp});
    $char->getMaxHp()->setBothValue($row->{max_hp});
    $char->setMsg($row->{msg});
    $char->setFaceType($row->{face_type});
    $char->setHairType($row->{hair_type});
    $char->setId($row->{user_id});
    $class->debug("Record user_id: " . $row->{user_id});
    $class->debug("getId:" . $char->getId() . " getUserId:" . $char->getUserId());
    $char->setNodeName(  $row->{node_name} );
    $char->setNodeId(  $row->{node_id} );

    $char->getConcentration()->setBothValue($row->{rp});

    $char->getAtack()->setBothValue($row->{atack});
    $char->getMagic()->setBothValue($row->{magic});
    $char->getDefence()->setBothValue($row->{def});
    $char->getAgility()->setBothValue($row->{agl});
    $char->getKehai()->setBothValue($row->{kehai});
    $char->getChikaku()->setBothValue($row->{chikaku});
    $char->getLuck()->setBothValue($row->{luck});
    $char->getKikyou()->setBothValue($row->{kikyou});
    $char->getCharm()->setBothValue($row->{chrm});

    $char->getAtack()->setTotalStackValues($row->{a_atack});
    $char->getMagic()->setTotalStackValues($row->{a_magic});
    $char->getDefence()->setTotalStackValues($row->{a_def});
    $char->getAgility()->setTotalStackValues($row->{a_agl});
    $char->getKehai()->setTotalStackValues($row->{a_kehai});
    $char->getChikaku()->setTotalStackValues($row->{a_chikaku});
    $char->getLuck()->setTotalStackValues($row->{a_luck});
    $char->getKikyou()->setTotalStackValues($row->{a_kikyou});
    $char->getCharm()->setTotalStackValues($row->{a_chrm});


    $char->getStamina()->setBothValue($row->{stamina});
    $char->getPosition()->setBothValue($row->{position});

    $char->setIsGm( $row->{is_gm} );
    $char->setOwnerId( $row->{owner_id} );

    $char->setVel( $row->{vel} );
    $char->setRel( $row->{rel} );


    ## SetSkill
    $char->setStatusIo( new Anothark::Character::StatusIO( $class->getDbHandler() ) );

    $char->setExperiments( $class->loadExp( $char->getUserId()) );


}


sub setupOutFromCharacter
{
    my $class = shift;
    my $char  = shift;


    $class->{out}->{CHAR} = $char;
    $class->{out}->{NAME} = sprintf("(%s)%s%s", $char->getUserId(), $char->getIsGm() ? $gm_img : "", $char->getName());
    $class->{out}->{V_HP} =  $char->getHp()->current();
    $class->{out}->{V_MHP} = $char->getHp()->max();
    $class->{out}->{MSG}   = $char->getMsg();
    $class->{out}->{FACE}  = Avatar::Face::TYPE->{$char->getFaceType()};
    $class->{out}->{HAIR}  = Avatar::Hair::TYPE->{$char->getHairType()};
    $class->{out}->{PLACE} = $char->getNodeName();
    $class->{out}->{NODE_ID} = $char->getNodeId();
    $class->{out}->{USER_ID} = $char->getUserId();
    $class->{out}->{USER_NAME} = $char->getUserName();
    $class->{out}->{VEL}     = $char->getVel();
    $class->{out}->{REL}     = $char->getRel();
    $class->{out}->{GM}      = $char->getIsGm();



    $class->{out}->{V_CON} = $char->getConcentration()->current();
    $class->{out}->{V_ATK} = $char->getAtack()->current();
    $class->{out}->{V_MAG} = $char->getMagic()->current();
    $class->{out}->{V_DEF} = $char->getDefence()->current();
    $class->{out}->{V_AGL} = $char->getAgility()->current();
    $class->{out}->{V_KHI} = $char->getKehai()->current();
    $class->{out}->{V_SNC} = $char->getChikaku()->current();
    $class->{out}->{V_LUK} = $char->getLuck()->current();
    $class->{out}->{V_HMT} = $char->getKikyou()->current();
    $class->{out}->{V_CHR} = $char->getCharm()->current();


    $class->{out}->{EXP}   = join(
        "<br />\n",
        map {
            sprintf "%s Lv%s (%s)", 
            Anothark::Skill::typeId2typeName2($_),
            $char->getTypeLevel($_),
            int $char->getTypeExperiment($_),
        } sort {$a <=> $b} keys %{$char->getExperiments() }
    );

}


# Get only self data
sub getMyCharacter
{
    my $class   = shift;
    my $char    = shift || new Anothark::Character::Player();
    my $get_base_sql = $common_base_sql 
                     . "AND b.carrier_id = ? AND b.uid = ?";

    my $sth  = $class->getDbHandler()->prepare($get_base_sql);
    my $stat = $sth->execute(($class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid()));
    my $row  = $sth->fetchrow_hashref();

    $class->notice(qq["Already registed check: " ], sprintf("carrier: %s, uid: %s, row: %s",$class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid(), $sth->rows() ));

    if ( $sth->rows() == 0 )
    {
        $class->warning("No user record.");
        $sth->finish();
        return undef;
    }


    if ( ! $row->{uuid} )
    {
        #
        $class->{out}->{UUID} = UniversalAnalytics::gen_uuid();
        my $uuid_update_sql = "UPDATE t_user SET uuid = ? WHERE user_id = ?";
        $class->getDbHandler()->do( $uuid_update_sql, undef, $class->{out}->{UUID}, $row->{user_id});
    }
    else
    {
        $class->{out}->{UUID} = $row->{uuid}; 
    }

    $sth->finish();

    $class->setupCharacter( $char, $row );


    return $char;
}




# get each character data
sub getCharacterByUserId
{
    my $class   = shift;
    my $user_id = shift;
    my $char    = shift || new Anothark::Character::Player();
    my $get_base_sql = $common_base_sql 
                     . "AND b.user_id = ?";

    my $sth  = $class->getDbHandler()->prepare($get_base_sql);
    my $stat = $sth->execute(($user_id));
    my $row  = $sth->fetchrow_hashref();

    $class->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, target_user_id: %s,row: %s",$class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid(), $user_id, $sth->rows() ));

    if ( $sth->rows() == 0 )
    {
        $class->warning("No user record.");
        $sth->finish();
        return undef;
    }

    $sth->finish();


    $class->setupCharacter($char, $row);


    return $char;
}


# load experiment
sub loadExp
{
    my $class = shift;
    my $user_id = shift;
    my $exps = {};

    my $get_base_sql = "
        SELECT
            b.type_id AS type_id,
            b.exp     AS exp
        FROM
            t_user AS u JOIN t_user_exp AS b USING(user_id)
        WHERE
            u.user_id = ?";

    my $sth  = $class->getDbHandler()->prepare($get_base_sql);
    my $stat = $sth->execute(($user_id));

    if ( $sth->rows > 0 )
    {
        $exps  = $sth->fetchall_hashref(("type_id"));
    }

    $sth->finish();

    return $exps;
}

sub sameNode
{
    my $class = shift;
    my $player = shift;
    my $other_char = shift;
    if ( $player->getNodeId() == $other_char->getNodeId() )
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

sub setNotice
{
    my $class = shift;
    return $class->setAttribute( 'notice', shift );
}

sub getNotice
{
    return $_[0]->getAttribute( 'notice' );
}



sub setStatusIo
{
    my $class = shift;
    return $class->setAttribute( 'status_io', shift );
}

sub getStatusIo
{
    return $_[0]->getAttribute( 'status_io' );
}



sub commitCharctorStatus
{
}




sub isRelease
{
     return not $LocalConfig::LOCAL_DEBUG;
}

sub Error
{
    my $class = shift;
    $class->setPageName("ERROR");
#    $class->setBase("template.html");
    $class->setBody("body_any.html");
}


sub Critical
{
    my $class = shift;
    $class->setPageName("ERROR");
    $class->setBase("small_template.html");
    $class->setBody("body_any.html");
}

1;
