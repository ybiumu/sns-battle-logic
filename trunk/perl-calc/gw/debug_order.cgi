#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);

my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


# init check
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


our $out = $at->getOut();


# depend
$at->setBody("body_debug_order.html");
$at->setPageName("�s�����e�X�g");

my $version = "0.1a20120328";

#my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();

our $names = {
    p1 => "����1",
    p2 => "����2",
    p3 => "����3",
    p4 => "����4",
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
our $players = {};
sub genObject
{
    my $c = shift;
    my $n = shift;
    my $ep = shift;
    my $pid = sprintf("%s%s",$ep,$n);
    my $sp = sprintf("%s_sp",$pid); 
    my $st = sprintf("%s_st",$pid); 
    $players->{$pid} = {
        ep => $ep,
        sp => $c->param("$sp") || 0,
        st => $c->param("$st") || 0 ,
    };
    return ($sp => $players->{$pid}->{sp}, $st => $players->{$pid}->{st} );
}

$out = $at->setOut( { map { (genObject($c,$_,"e" ) , genObject($c,$_,"p")) } ( 1 .. 4) } ); 

## Main


$db->disconnect();





$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');





#my $result = $out->{RESULT};
if ( $c->param("exec") )
{
    $out->{RESULT} .= "<div style='background-color: #efbfbf'>\n<br />\n";
    foreach my $turn ( 1 .. 5 )
    {
#        $out->{RESULT} .= sprintf "<center>== Turn %s ==</center><br />", $turn;
        $out->{RESULT} .= sprintf '<center><img src="imgdl.cgi?guid=ON&i=turn1.gif" alt="turn%s" /></center><br />', $turn;
        map {
            $out->{RESULT} .= sprintf $act_template, $symbol->{$players->{$_}->{ep}}->{align}, $symbol->{$players->{$_}->{ep}}->{head},$names->{$_}
        } sort { getTotalAgility($turn,$b) <=> getTotalAgility($turn,$a) } keys %{$players};
#        $result .= printf "<center>== Turn %s ==</center><br />", $turn;
    }
    $out->{RESULT} .= "</div>";
}


$at->setup();


$at->output();





exit;

sub getTotalAgility
{
    my $t   = shift;
    my $pid = shift;
    my $agi = getCurrentAgility($t,$players->{$pid}->{sp},$players->{$pid}->{st});
    return $agi + (0,1,2,3,4,5,6,7,8,9)[int(rand(10))];
}

sub getCurrentAgility
{
    my $t = shift;
    my $s = shift;
    my $v = shift;
    my $r = (1 - (($v - 50) - 10*($t - 1))/-100);
    my $rs = $s * ($r > 1 ? 1 : $r);
    return $rs;
}
