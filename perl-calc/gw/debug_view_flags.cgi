#!/usr/bin/perl

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


##############
### depend ###
##############
$at->setBody("body_debug_order.html");
my $version = "0.1a20120328";
$at->setPageName("ÉtÉâÉOämîF");






############
### Main ###
############
our $names = {
    p1 => "ñ°ï˚1",
    p2 => "ñ°ï˚2",
    p3 => "ñ°ï˚3",
    p4 => "ñ°ï˚4",
    e1 => "ìG1",
    e2 => "ìG2",
    e3 => "ìG3",
    e4 => "ìG4",
};
our $symbol = {
    e => {
        head  => "Å°",
        align => "right",
    },
    p => {
        head => "Å†",
        align => "left",
    },
};
our $act_template = '<div style="text-align:%s">%s%sÇÃçUåÇ!</div>';
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

our $out = $at->setOut( { map { (genObject($c,$_,"e" ) , genObject($c,$_,"p")) } ( 1 .. 4) } ); 

## Main

#my $get_result_list_sql = "
#    SELECT
#        l.result_log_id,
#        l.result_id,
#        l.last_update
#    FROM
#        t_result_log AS l
#        JOIN
#        t_user AS b
#        USING(user_id)
#    WHERE
#        b.carrier_id = ? AND b.uid = ? AND l.sequence_id = 0
#    GROUP BY result_log_id
#    ORDER BY last_update DESC";
#my $sth  = $db->prepare($get_result_list_sql);
#my $stat = $sth->execute(($carrier_id, $mob_uid));
#my $row ;



#if ( $sth->rows() > 0 )
#{
#    my $lines = 0;
#    while( $row  = $sth->fetchrow_hashref() )
#    {
#        $lines++;
#        $out->{RESULT} .= sprintf(qq[<a href="resulttext.cgi?guid=ON&result_log_id=%s">&nbsp;%s</a><hr />\n],$row->{result_log_id}, $row->{last_update})
#    }
#    $pu->output_log("passed find result row. count[$lines]");
#}
#else
#{
#    $sth->finish();
#    $db->disconnect();
#    print $c->redirect("setup.cgi?guid=ON");    
#    exit;
#}
#$sth->finish();

#$out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
#$out->{V_HP} =  $row->{hp};
#$out->{V_MHP} = $row->{max_hp};
#$out->{MSG}   = $row->{msg};
#$out->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
#$out->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};
#$out->{PLACE} = $row->{node_name};
#$db->disconnect();




#my $result = $out->{RESULT};
if ( $c->param("exec") )
{
    $out->{RESULT} .= "<div style='background-color: #efbfbf'>\n<br />\n";
    foreach my $turn ( 1 .. 5 )
    {
#        $out->{RESULT} .= sprintf "<center>== Turn %s ==</center><br />", $turn;
        $out->{RESULT} .= sprintf '<center><img src="turn1.gif" alt="turn%s" /></center><br />', $turn;
        map {
            $out->{RESULT} .= sprintf $act_template, $symbol->{$players->{$_}->{ep}}->{align}, $symbol->{$players->{$_}->{ep}}->{head},$names->{$_}
        } sort { getTotalAgility($turn,$b) <=> getTotalAgility($turn,$a) } keys %{$players};
#        $result .= printf "<center>== Turn %s ==</center><br />", $turn;
    }
    $out->{RESULT} .= "</div>";
}

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');







$db->disconnect();
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
