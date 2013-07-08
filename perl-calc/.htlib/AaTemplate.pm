package AaTemplate;

#
# ˆ¤
#

$|=1;
use strict;


use ObjMethod;
use Avatar;
use LocalConfig;
use Anothark::Character;
use base qw( ObjMethod );


my $base = "template.html";
my $css = "template.css";
my $body = undef;
my $base_html = undef;
my $body_html = undef;
my $base_css = undef;

my $page_util = undef;
my $mobile_util = undef;

my $db_handler = undef;
my $out = {};

my $ad_str = undef;
my $page_name = "No Name";

my $gm_img = '<img src="img/icon/ico_gm.gif" />';



sub init
{
    my $class = shift;
    $class->setOut($out);
    $class->setPageName($page_name);
    $class->setBase($base);
    $class->setCss($css);
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
    return $class->setAttribute( 'mobile_util', shift );
}

sub getMobileUtil
{
    return $_[0]->getAttribute( 'mobile_util' );
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

    my $base_css  = $class->{base_css};
    my $page_name = $class->getPageName();
    my $ad_str    = $class->getAdStr();

    $class->{base_html} =~ s/__TITLE__/$page_name/g;
    $class->{base_html} =~ s/__PAGE_TITLE__/$page_name/g;
    $class->{base_html} =~ s/__BASE_CSS__/$base_css/g;
    $class->{base_html} =~ s/__MESSAGE_BODY__/$tmp_html/g;
    $class->{base_html} =~ s/__ADD_SPACE__/$ad_str/g;
}

sub output
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
    if ($class->getMobileUtil()->getCarrierId())
    {
        $class->printFpHeader();
    }
    else
    {
        $class->printSpHeader();
    }

    print $class->getBaseHtml();
}



sub printFpHeader
{
    my $class = shift;
    my $ct = $class->getPageUtil()->getContentType();
    print <<_HEADER_;
Content-type: $ct;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_
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


sub setupBaseData
{
    my $class = shift;
    my $result = 0;
    my $get_base_sql = "
        SELECT
            b.user_id AS user_id,
            b.user_name AS user_name,
            mn.rel AS rel,
            mn.vel AS vel,
            b.msg AS msg,
            b.face_type AS face_type,
            b.hair_type AS hair_type,
            b.is_gm AS is_gm,
            s.a_max_hp AS max_hp,
            s.rp AS rp,
            s.a_agl AS a_agl,
            s.a_kehai AS a_kehai,
            s.a_chikaku AS a_chikaku,
            s.a_luck AS a_luck,
            s.a_kikyou AS a_kikyou,
            s.a_chrm   AS a_chrm,
            s.node_id AS node_id,
            s.a_hp AS hp,n.node_name
        FROM
            t_user AS b JOIN t_user_money AS mn USING(user_id) JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.carrier_id = ? AND b.uid = ?";
    my $sth  = $class->getDbHandler()->prepare($get_base_sql);
    my $stat = $sth->execute(($class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid()));
    my $row  = $sth->fetchrow_hashref();

    $class->getPageUtil()->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, row: %s",$class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid(), $sth->rows() ));

    if ( $sth->rows() == 0 )
    {
        return $result;
    }

    $result = 1;
    $class->{out}->{NAME} = sprintf("(%s)%s%s",$row->{user_id} , $row->{is_gm} ? $gm_img : "", $row->{user_name});

    $class->{out}->{V_HP} =  $row->{hp};
    $class->{out}->{V_MHP} = $row->{max_hp};
    $class->{out}->{MSG}   = $row->{msg};
    $class->{out}->{PLACE} = $row->{node_name};
    $class->{out}->{NODE_ID} = $row->{node_id};
    $class->{out}->{USER_ID} = $row->{user_id};
    $class->{out}->{VEL}     = $row->{vel};
    $class->{out}->{REL}     = $row->{rel};
    $class->{out}->{GM}      = $row->{is_gm};



    $class->{out}->{V_CON} = $row->{rp};
    $class->{out}->{V_ATK} = 0;
    $class->{out}->{V_MAG} = 0;
    $class->{out}->{V_DEF} = 0;
    $class->{out}->{V_AGL} = $row->{a_agl};
    $class->{out}->{V_KHI} = $row->{a_kehai};
    $class->{out}->{V_SNC} = $row->{a_chikaku};
    $class->{out}->{V_LUK} = $row->{a_luck};
    $class->{out}->{V_HMT} = $row->{a_kikyou};
    $class->{out}->{V_CHR} = $row->{a_chrm};


    $class->{out}->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
    $class->{out}->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};

    return $result;
}




sub commitCharctorStatus
{
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


sub getBaseDataByUserId
{
    my $class = shift;
    my $user_id = shift;
    my $result = 0;
#    my $get_base_sql = "
#        SELECT
#            b.user_id AS user_id,
#            b.user_name AS user_name,
#            b.msg AS msg,
#            b.face_type AS face_type,
#            b.hair_type AS hair_type,
#            s.a_max_hp AS max_hp,
#            s.rp AS rp,
#            s.a_agl AS a_agl,
#            s.a_kehai AS a_kehai,
#            s.a_chikaku AS a_chikaku,
#            s.a_luck AS a_luck,
#            s.a_kikyou AS a_kikyou,
#            s.a_chrm   AS a_chrm,
#            s.node_id AS node_id,
#            s.a_hp AS hp,n.node_name
#        FROM
#            t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.user_id = ?";
#    my $sth  = $class->getDbHandler()->prepare($get_base_sql);
#    my $stat = $sth->execute(($user_id));
#    my $row  = $sth->fetchrow_hashref();
#
#    $class->getPageUtil()->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, target_user_id: %s,row: %s",$class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid(), $user_id, $sth->rows() ));
#
#    if ( $sth->rows() == 0 )
#    {
#        return $result;
#    }

    my $char = $class->getCharacterByUserId($user_id);
    if ( not $char )
    {
        return $result;
    }



    $result = 1;
    $class->{out}->{NAME} = sprintf("(%s)%s%s", $user_id, $char->getIsGm() ? $gm_img : "", $char->getName());
    $class->{out}->{V_HP} =  $char->getHp()->current();
    $class->{out}->{V_MHP} = $char->getHp()->max();
    $class->{out}->{MSG}   = $char->getMsg();
    $class->{out}->{FACE}  = Avatar::Face::TYPE->{$char->getFaceType()};
    $class->{out}->{HAIR}  = Avatar::Hair::TYPE->{$char->getHairType()};
    $class->{out}->{PLACE} = $char->getNodeName();
    $class->{out}->{NODE_ID} = $char->getNodeId();
    $class->{out}->{USER_ID} = $user_id;
    $class->{out}->{VEL}     = $char->getVel();
    $class->{out}->{REL}     = $char->getRel();

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

    return $result;
}


sub getCharacterByUserId
{
    my $class = shift;
    my $user_id = shift;
    my $get_base_sql = "
        SELECT
            b.user_id AS user_id,
            b.user_name AS user_name,
            mn.rel AS rel,
            mn.vel AS vel,
            b.msg AS msg,
            b.face_type AS face_type,
            b.hair_type AS hair_type,
            b.is_gm AS is_gm,
            s.a_max_hp AS max_hp,
            s.rp AS rp,
            s.a_agl AS a_agl,
            s.a_kehai AS a_kehai,
            s.a_chikaku AS a_chikaku,
            s.a_luck AS a_luck,
            s.a_kikyou AS a_kikyou,
            s.a_chrm   AS a_chrm,
            s.node_id AS node_id,
            s.a_hp AS hp,
            n.node_name
        FROM
            t_user AS b JOIN t_user_money AS mn USING(user_id) JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.user_id = ?";
    my $sth  = $class->getDbHandler()->prepare($get_base_sql);
    my $stat = $sth->execute(($user_id));
    my $row  = $sth->fetchrow_hashref();

    $class->getPageUtil()->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, target_user_id: %s,row: %s",$class->getMobileUtil()->getCarrierId(), $class->getMobileUtil()->get_muid(), $user_id, $sth->rows() ));

    if ( $sth->rows() == 0 )
    {
        return undef;
    }
    my $char = new Anothark::Character();

    $char->setName($row->{user_name});
    $char->getHp()->setCurrentValue($row->{hp});
    $char->getHp()->setMaxValue($row->{max_hp});
    $char->setMsg($row->{msg});
    $char->setFaceType($row->{face_type});
    $char->setHairType($row->{hair_type});
    $char->setId($row->{user_id});
    $char->setNodeName(  $row->{node_name} );
    $char->setNodeId(  $row->{node_id} );
    $char->getConcentration()->setBothValue($row->{rp});
    $char->getAtack()->setBothValue(0);
    $char->getMagic()->setBothValue(0);
    $char->getDefence()->setBothValue(0);
    $char->getAgility()->setBothValue($row->{a_agl});
    $char->getKehai()->setBothValue($row->{a_kehai});
    $char->getChikaku()->setBothValue($row->{a_chikaku});
    $char->getLuck()->setBothValue($row->{a_luck});
    $char->getKikyou()->setBothValue($row->{a_kikyou});
    $char->getCharm()->setBothValue($row->{a_chrm});

    $char->setIsGm( $row->{is_gm} );

    $char->setVel( $row->{vel} );
    $char->setRel( $row->{rel} );

    return $char;
}

1;
