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
use Anothark::SkillLoader;
use Anothark::Skill;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


my $selects = {
    'effect_type'      => [0,1,2,3,4,5,6],
    'learn_type_id'    => [0,1,2],
    'type_id'          => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'sub_type_id'      => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'skill_type'       => [1,2,3,4],
    'power_source'     => [0,1,2],
    'concent_type'     => [0,1,2,3,4],
    'random_type'      => [0,1,2,3,4,5,6],
    'formula_type'     => [0,1],
    'base_type'        => [1,2,3,4],
    'base_element'     => [0,1,2,3,4,-1,11,12,13,14],
    'sub_base_type'    => [0,1,2,3,4],
    'sub_base_element' => [0,1,2,3,4,-1,11,12,13,14],
    'length_type'         => [1,2,3],
    'range_type'          => [1,2,3],
    'target_type'         => [1,2,3],
    'position_limit_type' => [0,1,2],
    'flying_limit_type'   => [0,1,2],
    'phaseout_limit_type' => [0,1,2],
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
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}




our $out = $at->getOut();

##############
### depend ###
##############
$at->setBase("adm_template.html");
$at->setBody("body_admin_skill.html");
$at->setPageName("ŠÇ— - ½·ÙŠÇ—");
my $version = "0.1a20130415";



############
### Main ###
############

my $skill_id = $c->param("skill_id") || 0;

my $sql = "SELECT * FROM t_skill_master WHERE skill_id = ?";
my $sth  = $db->prepare($sql);
my $stat = $sth->execute(($skill_id));




$out->{RESULT_TITLE} = "ŠÇ— - ½·ÙŠÇ—";
my $lines = 0;

if ( $sth->rows > 0 )
{
    $out->{RESULT} = "<form name=\"skill\" method=\"get\" action=\"edit_skill.cgi\">\n";
    my $row  = $sth->fetchrow_hashref();
    my $names = $sth->{'NAME'};
    map { $out->{$_} = $row->{$_};} @{$names};

    if ( $c->param("act") eq "saveconfirm" )
    {
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
            $out->{ "_".$select_element } = { map { ( $_ => ( $c->param($select_element) eq $_ ? $pu->getSelectedStr() : "" ) ) } @{$selects->{$select_element}}};
        }
        foreach my $key ( @{$names} )
        {
            if ( $c->param($key) ne undef )
            {
                if ( $row->{$key} ne $c->param($key) )
                {
                    $out->{"difference"} .= sprintf("%s:%s->%s<br />\n", $key,$row->{$key},$c->param($key));
                }
            }
        }
        if ( $out->{"difference"} ne "" )
        {
            $out->{"save_form"}  = '<input type="submit" value="save" />';
        }
    }
    elsif ( $c->param("act") eq "save" )
    {
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
            $out->{ "_".$select_element } = { map { ( $_ => ( $c->param($select_element) eq $_ ? $pu->getSelectedStr() : "" ) ) } @{$selects->{$select_element}}};
        }
    }
    else
    {
        $out->{"difference"} = "";
        $out->{"save_form"}  = "";
        foreach my $select_element (keys %{$selects})
        {
            $out->{ "_".$select_element } = { map { ( $_ => ( $out->{$select_element} eq $_ ? $pu->getSelectedStr() : ""  ) ) } @{$selects->{$select_element}}};
        }
    }
}

$sth->finish();

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


