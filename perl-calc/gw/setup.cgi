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

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";

my $disable = 1;
my $start_node_id = 5;

my $reg_count = 1;

{
    my $sth_reg  = $db->prepare("SELECT cnt FROM regist_count WHERE cnt < ?");
    my $stat_reg = $sth_reg->execute(($reg_count));
    my $row_reg  = $sth_reg->fetchrow_arrayref();
    my $rownum_reg = $sth_reg->rows();
    $pu->debug("regnum [$rownum_reg]");
    $sth_reg->finish();
    if ( $rownum_reg == 1 )
    {
        $disable = 0;
    }
}


$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ("test 1")) .'"');
our $out = $at->setOut({
    name   => "",
    face   => 0,
    hair   => 0,
    gendar => 0,
});


$pu->setContentType( $mu->getContentType() );
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();

##############
### depend ###
##############

if ( $disable )
{
    $at->setBody("body_disable.html");
    $at->setPageName("ƒ†[ƒU[“o˜^");
    $at->setBase("small_template.html");
    $pu->notice(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
    $at->setup();
    $at->output();
    $db->disconnect();
    exit;
}

$at->setBody("body_setup.html");
$at->setPageName("ƒ†[ƒU[“o˜^");
my $version = "0.1a20120328";

my $debug_str = "";



$out->{_face} = Avatar::Face::TYPE();
$out->{_hair} = Avatar::Hair::TYPE();
$out->{_gender} = Avatar::Gender::TYPE();


# param parse.
$out->{name}   = $c->param("name") || $out->{name};
$out->{gender} = $c->param("gender") || $out->{gender};
$out->{face}   = $c->param("face") || $out->{face};
$out->{hair}   = $c->param("hair") || $out->{hair};


# default values
my $r_gender  = { map {($_ => $_ == $out->{gender} ? $checked_str : '') } keys %{$out->{_gender}} };
my $r_face    = { map {($_ => $_ == $out->{face} ? $checked_str : '') }   keys %{$out->{_face}} };
my $r_hair    = { map {($_ => $_ == $out->{hair} ? $checked_str : '') }   keys %{$out->{_hair}} };

#map { $debug_str .= sprintf("C2[%s]:%s <br />", $_, $r_face->{$_})}  sort keys %{$r_face};


$r_gender->{$c->param("r_gender")} = $checked_str if ( defined $c->param("r_gender") );
$out->{genders} = join "", map {sprintf( "<input type=\"radio\" name=\"gender\" value=\"%s\"%s />%s\n", $_, $r_gender->{$_}, $out->{_gender}->{$_})} sort keys %{$out->{_gender}};


$r_face->{$c->param("r_face")} = $checked_str if ( defined $c->param("r_face") );
$out->{faces} = join "", map {sprintf( "<input type=\"radio\" name=\"face\" value=\"%s\"%s />%s<br />\n", $_, $r_face->{$_}, $out->{_face}->{$_})} sort keys %{$out->{_face}};


$r_hair->{$c->param("r_hair")} = $checked_str if ( defined $c->param("r_hair") );
$out->{hairs} = join "", map {sprintf( "<input type=\"radio\" name=\"hair\" value=\"%s\"%s />%s<br />\n", $_, $r_hair->{$_}, $out->{_hair}->{$_})} sort keys %{$out->{_hair}};




# Check record exists.
my $sth  = $db->prepare("SELECT user_id, user_name FROM t_user WHERE carrier_id = ? AND uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_arrayref();
my $rownum = $sth->rows();
$sth->finish();
$pu->output_log(qq[row: $rownum,] . sprintf(" findrow: %s %s",$row->[0], $row->[1]));
if ( $rownum > 0 )
{
    # Redirect event mapper
    $at->setBody("body_any.html");
    $out->{"RESULT"} = 'Šù‚É“o˜^‚³‚ê‚Ä‚¢‚Ü‚·B';
}
elsif ( $c->param("commit") eq "OK" )
{
    $sth  = $db->prepare("INSERT INTO t_user SET carrier_id = ?, uid = ?, user_name = ?, face_type = ?, hair_type = ?, gender = ? ");
    $stat = $sth->execute( $carrier_id, $mob_uid, $c->param("name"), $c->param("face"), $c->param("hair"), $c->param("gender") );
    my $id = $db->{'mysql_insertid'};
    my $sth2 = $db->prepare("INSERT INTO t_user_status(user_id,node_id) VALUES(?,?);");
    $stat = $sth2->execute($id, $start_node_id );
    $sth2->finish();
    my $sth3 = $db->prepare("INSERT INTO t_user_money(user_id,vel,rel) VALUES(?,0,0);");
    $stat = $sth3->execute($id);
    $sth3->finish();

    my $sth4 = $db->prepare("INSERT INTO t_user_battle_setting(user_id) VALUES(?);");
    $stat = $sth4->execute($id);
    $sth4->finish();

    my $sth5 = $db->prepare("INSERT INTO t_selection_que(user_id,selection_id,queing_hour,qued) VALUES(?,0,HOUR(NOW() + interval 8 hour) ,0);");
    $stat = $sth5->execute($id);
    $sth5->finish();

    my $sth6 = $db->prepare("INSERT INTO t_user_flagment(user_id,flag_id,enable) VALUES(?,0,1);");
    $stat = $sth6->execute($id);
    $sth6->finish();


    my $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued)  SELECT u.user_id, sel.selection_id, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) JOIN t_selection sel USING( node_id ) WHERE sel.selection_id = ? AND u.carrier_id = ? AND u.uid = ? ");
    $up_sth->execute((1,$carrier_id, $mob_uid));

    # Check.
    # Redirect event mapper
    $at->setBody("body_setup_ok.html");

    {
        my $sth_reg  = $db->prepare("UPDATE regist_count SET cnt = cnt + 1;");
        my $stat_reg = $sth_reg->execute();
        $sth_reg->finish();
    }

}

$db->disconnect();


# progress status
my $st = $c->param("st") || 0;
if ( $st == 1 )
{
    $at->setBody("body_setup_chk.html");
}




$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;


