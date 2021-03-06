#!/usr/bin/perl
############
### LOAD ###
############
use lib qw( .htlib ../../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::ItemManager;
use Anothark::Item;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

my $ad_str = "";


my $selects = {
#    'effect_type'      => [0,1,2,3,4,5,6],
#    'learn_type_id'    => [0,1,2],
#    'type_id'          => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
#    'sub_type_id'      => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
#    'item_type'       => [1,2,3,4],
#    'power_source'     => [0,1,2],
#    'concent_type'     => [0,1,2,3,4],
#    'random_type'      => [0,1,2,3,4,5,6],
#    'formula_type'     => [0,1],
#    'base_type'        => [1,2,3,4],
#    'base_element'     => [0,1,2,3,4,-1,11,12,13,14],
#    'sub_base_type'    => [0,1,2,3,4],
#    'sub_base_element' => [0,1,2,3,4,-1,11,12,13,14],
#    'length_type'         => [1,2,3],
#    'range_type'          => [1,2,3],
#    'target_type'         => [1,2,3],
#    'position_limit_type' => [0,1,2],
#    'flying_limit_type'   => [0,1,2],
#    'phaseout_limit_type' => [0,1,2],

    'item_type_id'          => [1,2,3,4,5,6],
    'item_sub_type_id'      => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,33],
    'use_effect_target'     => [0,1,2],
    'use_effect_range'      => [0],
    'is_external_exec'      => [0,1],
};






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
    print $c->redirect("../setup.cgi?guid=ON");    
    exit;
}




our $out = $at->getOut();
#unless ( $out->{GM} )
#{
#    print $c->header( -status=>"404 Not found" );
#    exit 1;
#}

##############
### depend ###
##############
$at->setBody("body_admin_item.html");
$at->setPageName("�Ǘ� - ���ѕҏW");
my $version = "0.1a20130415";



############
### Main ###
############

my $item_master_id = $c->param("item_master_id") || 0;

#my $sql = "SELECT * FROM t_item_master WHERE item_id = ?";
#my $sth  = $db->prepare($sql);
#my $stat = $sth->execute(($item_id));

my $im = new Anothark::ItemManager( $db );

my $item = $im->loadItem($item_master_id);

my $lines = 0;

$pu->warning($item->getItemMasterId());

if ( $item->getItemMasterId() > 0 )
{
$out->{RESULT_TITLE} = "�Ǘ� - ���ѕҏW";
    $out->{RESULT} = "<form name=\"item\" method=\"get\" action=\"edit_item.cgi\">\n";
#    my $row  = $sth->fetchrow_hashref();
#    my $names = $sth->{'NAME'};
    map { $out->{$_} = $item->{$_};} @{$item->getFieldNames()};

    if ( $c->param("act") eq "saveconfirm" )
    {
        my $code = "(1)";
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
            $out->{ "_".$select_element } = { map { ( $_ => ( $c->param($select_element) eq $_ ? $pu->getSelectedStr() : "" ) ) } @{$selects->{$select_element}}};
        }
        foreach my $key ( @{$item->getFieldNames()} )
        {
            if ( $c->param($key) ne undef )
            {
                my $old = $item->{$key};
                my $new = $c->param($key);
#                $out->{PRE_RESULT} .= sprintf("%s: %s/%s<br />\n",$key,$old,$new);
                if ( $old ne $new )
                {
                    $out->{"difference"} .= sprintf("%s:%s->%s<br />\n", $key,$item->{$key},$c->param($key));
                    $out->{PRE_RESULT} .= $out->{"difference"};
                }
            }
        }
        if ( $out->{"difference"} ne "" )
        {
            $out->{"save_form"}  = '<input type="submit" value="save" />';
        }
        else
        {
            $code = "(1->3)";
        }
$out->{RESULT_TITLE} .= $code;
    }
    elsif ( $c->param("act") eq "save" )
    {
$out->{RESULT_TITLE} .= "(2)";
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
            $out->{ "_".$select_element } = { map { ( $_ => ( $c->param($select_element) eq $_ ? $pu->getSelectedStr() : "" ) ) } @{$selects->{$select_element}}};
        }
    }
    else
    {
$out->{RESULT_TITLE} .= "(3)";
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
#            $out->{ "_".$select_element } = { map { $pu->warning( sprintf("[%s] map[%s] [%s]",$select_element , $_ , $out->{$select_element}));( $_ => ( $out->{$select_element} eq $_ ? ( $pu->warning( " ->")) && $pu->getSelectedStr() : ""  ) ) } @{$selects->{$select_element}}};
            $out->{ "_".$select_element } = { map { ( $_ => ( $out->{$select_element} eq $_ ? $pu->getSelectedStr() : ""  ) ) } @{$selects->{$select_element}}};
        }
    }
}
else
{
$out->{RESULT_TITLE} = "�Ǘ� - ���ѕҏWnotfound";
}

#$sth->finish();

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


