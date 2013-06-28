#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::Character;
use Anothark::Battle;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);

my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


# init check
my $c = new CGI();
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


our $out = $at->getOut();


# depend
$at->setBody("body_debug_target.html");
$at->setPageName("�^�[�Q�b�g�e�X�g");

my $version = "0.1a20120328";

#my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();

our $names = {
    p1 => "����1",
    e1 => "�G1",
    e2 => "�G2",
    e3 => "�G3",
    e4 => "�G4",
};
our $symbol = {
    e => {
        head  => "��",
        align => "right",
    },
    p => {
        head => "��",
        align => "left",
    },
};
our $act_template = '<div style="text-align:%s">%s%s�̍U��!</div>';
our $target_template = '<div style="text-align:%s">-&gt;%s</div>';
our $dmg_template = '<div style="text-align:%s">%s��Ұ��!</div>';
our $players = {};

my $battle = new Anothark::Battle( $pu );


sub genObject
{
    my $battle = shift;
    my $c = shift;
    my $n = shift;
    my $ep = shift;
    my $pid = sprintf("%s%s",$ep,$n);
    my $hp = sprintf("%s_hp",$pid); 
    my $df = sprintf("%s_df",$pid); 
    my $kh = sprintf("%s_kh",$pid); 
    my $ch = sprintf("%s_ch",$pid); 
    my $char = new Anothark::Character();
    $char->setId($n);
    $char->setName(sprintf("�G%s",$n));
    $char->getHp()->setBothValue($c->param("$hp") || 100);
    $char->getDefence()->setBothValue($c->param("$df") || 0);
    $char->getKehai()->setBothValue($c->param("$kh") || 100);
    $char->getCharm()->setBothValue($c->param("$ch") || 100);

    $char->setSide($ep);
    $battle->appendCharacter($char);
    $players->{$pid} = $char;

    return (
        $hp => $char->getHp()->current(),
        $df => $char->getDefence()->current(),
        $kh => $char->getKehai()->current(),
        $ch => $char->getCharm()->current(),
    );
}

$out = $at->setOut( { map { (genObject($battle,$c,$_,"e" ) ) } ( 1 .. 4 ) } ); 


my $player = new Anothark::Character();
$player->getChikaku()->setBothValue( $c->param("p1_ck") || 100);
$player->getKikyou()->setBothValue( $c->param("p1_kk") || 100);

$out->{"p1_ck"} = $player->getChikaku()->current();
$out->{"p1_kk"} = $player->getKikyou()->current();
$out->{"p1_d"}  = $c->param("p1_d") || 0;

## Main


$db->disconnect();





$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');





#my $result = $out->{RESULT};
if ( $c->param("exec") )
{
    $out->{RESULT} .= "<div style='background-color: #efbfbf'>\n<br />\n";
    my @target_order = (
        sort {
            $players->{$b}->getTargetingValue( getRealDamage($out->{"p1_d"}, $players->{$b}->getDefence()->current()), $out->{"p1_ck"}, $out->{"p1_kk"} ) <=> $players->{$a}->getTargetingValue( getRealDamage($out->{"p1_d"}, $players->{$a}->getDefence()->current() ) , $out->{"p1_ck"}, $out->{"p1_kk"} ) or $players->{$a}->getId() <=> $players->{$b}->getId()
        } keys %{$players} 
    );

    $out->{RESULT} .= sprintf $act_template, $symbol->{p}->{align}, $symbol->{p}->{head},$names->{p1};
    $out->{RESULT} .= sprintf $target_template, $symbol->{p}->{align},$names->{$target_order[0]};
    $out->{RESULT} .= sprintf $dmg_template, $symbol->{p}->{align}, getRealDamage($out->{"p1_d"}, $players->{$target_order[0]}->getDefence()->current());

    $out->{RESULT} .= "<hr />\n";

    foreach my $enemy ( @target_order )
    {
        $out->{RESULT} .= sprintf("%s:%s<br />\n", $players->{$enemy}->getName(), $players->{$enemy}->getTargetingValue( getRealDamage($out->{"p1_d"},$players->{$enemy}->getDefence()->current() ), $out->{"p1_ck"}, $out->{"p1_kk"} ));
    }

    $out->{RESULT} .= "</div>";
}


$at->setup();


$at->output();





exit;

sub getRealDamage
{
    my $dmg = shift;
    my $df  = shift;

    my $r   = $dmg - ( $df / 2 );
    return $r > 0 ? $r : 0;
}

