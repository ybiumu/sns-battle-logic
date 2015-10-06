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
use Anothark::Character::Npc;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

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


my $npcid  = $c->param("i") || 0;
my $vector = $c->param("v") || 0;
my $mode   = $c->param("m") || 0;

my $get_npcinfo_list_sql = "SELECT npc_id, npc_name FROM t_npc_master WHERE npc_id > ? ORDER BY npc_id LIMIT 20 ";
my $get_npcinfo_list_desc_sql = "SELECT * FROM ( SELECT npc_id, npc_name FROM t_npc_master WHERE npc_id < ? ORDER BY npc_id DESC LIMIT 20 ) AS b ORDER BY npc_id";
my $get_npc_desc_sql = "SELECT * FROM t_npc_master WHERE npc_id = ?;";





my $sql;

if ( $mode eq "1" )
{
    $sql = $get_npc_desc_sql;
}
else
{
    if ( $vector eq "1" )
    {
        $sql = $get_npcinfo_list_desc_sql;
    }
    else
    {
        $sql = $get_npcinfo_list_sql;
    }
}



my $rs_sth = $db->prepare( $sql );
$pu->output_log($rs_sth->execute(($npcid)));

my $rs_row  = $rs_sth->fetchall_arrayref( +{} );
if ( ! $rs_sth->rows() > 0 )
{
    exit;
}


my @npcs = map { new Anothark::Character::Npc( { preset => $_, npc_id => $_->{npc_id}, npc_name => $_->{npc_name} } );} @{$rs_row};

 






our $out = $at->getOut();

##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName("ÃÞÊÞ¯¸Þ:NPC");
my $version = "0.1a20130415";
our @oddeven = ( "odd", "even" );



############
### Main ###
############

if ( $mode eq "1" )
{
    $at->setBody("body_adm_npc_view.html");
    $out->{_npc_descr} = $npcs[0];
}
else
{
    my $lines = 0;
    foreach my $line ( @npcs )
    {
        $lines++;
        $out->{RESULT} .= sprintf(
            qq[<div class="item_%s"><a href="adm_npc_view.cgi?m=1&i=%s">&nbsp;(%s)&nbsp;%s</a></div>\n],
            $oddeven[$lines%2], $line->getNpcId(), $line->getNpcId(),$line->getNpcName()
        );
    }
}


##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


