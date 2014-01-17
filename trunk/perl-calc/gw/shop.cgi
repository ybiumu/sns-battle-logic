#!/usr/bin/perl
#
# ˆ¤
#
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

use Anothark::ShopManager;
use Anothark::Shop;

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
our $money_unit = 'VEL';
my $user_id = $out->{USER_ID};



##############
### depend ###
##############
$at->setBody("body_shop.html");
my $version = "0.1a20130415";

my $shop_id = $c->param("sid") || undef;

my $sm = new Anothark::ShopManager( $db );
my @oddeven = ( "odd", "even" );
my $tr = $c->param("tr") || 0;

$out->{TMP_MONEY} = $out->{$money_unit};
# Check record exists.
if ( $shop_id )
{
    my $shop = $sm->loadShopDescr( $user_id, $shop_id );
    $pu->output_log(sprintf( "c: %s ", $carrier_id));
    $out->{sid} = $shop_id;

    if ( $shop->getShopId() )
    {
        $out->{NODE_ID}  = $shop->getNodeId();
        $out->{SHOP_ID}  = $shop->getShopId();
        $out->{SHOP_IMAGE} = $shop->getShopImage() || "operator.jpg";
        $out->{SHOP_DESCR} = $shop->getShopDescr();
        $out->{SHOP_NAME}  = $shop->getShopName();


        $at->setPageName($out->{SHOP_NAME});

        if ( $tr == 2 )
        {
            $at->setPageName( $at->getPageName() . '/w“üŠm”F');
            my $seid = $c->param("item") || 0;
$at->warning("SEID: $seid");
            my $item = $shop->getItems()->{$seid};

$at->warning("ITEM:  $item");
$at->warning("ITEM2: ".ref($item));
            $at->setBody("body_shop_descr.html");
            $out->{ITEM_LABEL} = $item->getItemLabel();
            $out->{ITEM_DESCR} = $item->getItemDescr();
            $out->{PRICE} = $item->getPrice();
            $out->{SEID}  = $item->getShopElementId();
            $out->{SHOP_ID} = $shop_id;
        }
        elsif( $tr == 3 )
        {
            my $rb = $c->param("rb") || 0;
            my $ci = $c->param("ci") || 0;
            my $n  = $c->param("n")  || 0;
            my $hm = $c->param("hm") || 0;
            my $seid = $c->param("item") || 0;


            if ( $ci )
            {
                # B B ‘Î‰ž
                if ( $hm != $out->{$money_unit} )
                {
                    # Not same session!
                }
                else
                {
                    my $status = $sm->trading( $at->{PLAYER}, $shop, $seid, $money_unit, $n);
                    $out->{SHOP_DESCR} = $status;
                }

            }
            $tr = 0;
        }

        unless ( $tr )
        {
            my $lines = 0;
            foreach my $item ( sort { $a->getItemTypeId() cmp $b->getItemTypeId() && $a->getPrice() cmp $b->getPrice() } values %{ $shop->getItems() } )
            {
                $lines++;
                $out->{RESULT} .= sprintf("<div class='item_%s'><input type='radio' name='item' value='%s'>%s :%s</div>\n",$oddeven[$lines%2],$item->getShopElementId(), $item->getItemLabel(), $item->getPrice() );
            }

            $out->{RESULT} .= sprintf('<input type="hidden" name="sid" value="%s" />',$shop_id);
        }
    }
    else
    {
        $at->Critical();
#        $at->Error();
        $at->{out}->{RESULT} = "“X•Ü‚ª‘¶Ý‚µ‚Ü‚¹‚ñ";

    }
}
else
{
    my $shop_list = $sm->getShopList($user_id);
#    my $sth  = $db->prepare("
#SELECT
#    s.node_id,
#    p.shop_id,
#    p.shop_name,
#    p.shop_descr,
#    p.shop_image
#FROM
#    t_user AS u
#    JOIN
#    t_user_status AS s USING(user_id)
#    JOIN t_shop_master AS p USING(node_id)
#WHERE user_id = ?
#");
#    my $stat = $sth->execute(($user_id));
    $pu->output_log(sprintf( "c: %s ", $carrier_id));
    my $rownum = scalar(@{$shop_list});
    if ( $rownum > 0 )
    {
        my $lines = 0;
        while( my $row  = shift(@{$shop_list}) )
        {
            $lines++;
#        $out->{RESULT} .= sprintf("<input type=\"checkbox\" name=\"i_%s\" />&nbsp;%s<br />\n",$row->{item_id}, $row->{item_label})
            $out->{RESULT} .= sprintf("<div class='item_%s'><a href='shop.cgi?guid=ON&sid=%s'>%s</a></div>\n",$oddeven[$lines%2], $row->{shop_id}, $row->{shop_name});
        }


        $at->setBody("body_shop_list.html");
        $at->setPageName("¼®¯Ìß");
    }
    else
    {
        $at->Critical();
#        $at->Error();
        $at->{out}->{RESULT} = "“X•Ü‚ª‘¶Ý‚µ‚Ü‚¹‚ñ";

    }
}

############
### Main ###
############





##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->debug("[BEFORE SETFUP]");
$at->setup();
$at->debug("[AFTER SETFUP]");
$at->output();





exit;


