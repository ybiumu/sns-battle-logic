#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DBI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;



my $ad_str = "";

my $db = DbUtil::getDbHandler();


my $dp = "../data";
my $t  = "$dp/anothark";
my $base_template = "$t/template.html";
my $body_template = "$t/body_setup.html";
my $system_log = "../.htlog/aa_calc.log";
my $access_log = "../.htlog/aa_access.log";

my $version = "0.1a20120328";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();

my $debug_str = "";




our $out = {
    name   => "",
    face   => 0,
    hair   => 0,
    gendar => 0,
};
#$debug_str .= "CT: $content_type <br />\n";
#$debug_str .= "BW: $browser <br />\n";
#$debug_str .= "CI: $carrier_id <br />\n";


my $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();

#$debug_str .= "UI: $mob_uid <br />\n";
my $c = new CGI();
my $_face = Avatar::Face::TYPE();
my $_hair = Avatar::Hair::TYPE();
my $_gender = Avatar::Gender::TYPE();


# param parse.
$out->{name}   = $c->param("name") || $out->{name};
$out->{gender} = $c->param("gender") || $out->{gender};
$out->{face}   = $c->param("face") || $out->{face};
$out->{hair}   = $c->param("hair") || $out->{hair};


# default values
my $r_gender  = { map {($_ => $_ == $out->{gender} ? $checked_str : '') } keys %{$_gender} };
my $r_face    = { map {($_ => $_ == $out->{face} ? $checked_str : '') } keys %{$_face} };
my $r_hair    = { map {($_ => $_ == $out->{hair} ? $checked_str : '') } keys %{$_hair} };

#map { $debug_str .= sprintf("C2[%s]:%s <br />", $_, $r_face->{$_})}  sort keys %{$r_face};


$r_gender->{$c->param("r_gender")} = $checked_str if ( defined $c->param("r_gender") );
my $genders = join "", map {sprintf( "<input type=\"radio\" name=\"gender\" value=\"%s\"%s />%s\n", $_, $r_gender->{$_}, $_gender->{$_})} sort keys %{$_gender};

$r_face->{$c->param("r_face")} = $checked_str if ( defined $c->param("r_face") );
my $faces = join "", map {sprintf( "<input type=\"radio\" name=\"face\" value=\"%s\"%s />%s<br />\n", $_, $r_face->{$_}, $_face->{$_})} sort keys %{$_face};


$r_hair->{$c->param("r_hair")} = $checked_str if ( defined $c->param("r_hair") );
my $hairs = join "", map {sprintf( "<input type=\"radio\" name=\"hair\" value=\"%s\"%s />%s<br />\n", $_, $r_hair->{$_}, $_hair->{$_})} sort keys %{$_hair};




# Check record exists.
my $sth  = $db->prepare("SELECT user_id, user_name FROM t_user WHERE carrier_id = ? AND uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_arrayref();
my $rownum = $sth->rows();
if ( $rownum > 0 )
{
    # Redirect event mapper
    $db->disconnect();
}
elsif ( $c->param("commit") eq "OK" )
{
    $sth  = $db->prepare("INSERT INTO t_user SET carrier_id = ?, uid = ?, user_name = ?, face_type = ?, hair_type = ?, gender = ?");
    $stat = $sth->execute( $carrier_id, $mob_uid, $c->param("name"), $c->param("face"), $c->param("hair"), $c->param("gender") );
    my $id = $db->{'mysql_insertid'};
    my $sth2 = $db->prepare("INSERT INTO t_user_status(user_id) VALUES(?);");
    $stat = $sth2->execute($id);

    # Check.
    # Redirect event mapper
    $db->disconnect();
    $body_template = "$t/body_setup_ok.html";
}



# progress status
my $st = $c->param("st") || 0;
if ( $st == 1 )
{
    $body_template = "$t/body_setup_chk.html";
}


#$debug_str .= "RN: $rownum <br />\n";


output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
my $name = <<_NAME_;
ÉÜÅ[ÉUÅ[ìoò^
_NAME_

#my $_damage = "";
my $_value  = "";

#
# my $engine = undef;
# $engine->load();



my $_damages = "";
# $_damages = $engine->getContents();






open(TEMP, $base_template) || ( printError("Can't open template 1") && exit);
my $base_temp_html = join("",<TEMP>);
close(TEMP);


open(BODY, $body_template) || ( printError("Can't open template 2") && exit );
my $body_temp_html = join("",<BODY>);
close(BODY);
my $tmp_html;
eval(
    "\$tmp_html = <<_HERE_;
$body_temp_html
_HERE_"
);

$tmp_html = $debug_str . $tmp_html;

$base_temp_html =~ s/__TITLE__/$name/g;
$base_temp_html =~ s/__PAGE_TITLE__/$name/g;
$base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;


$base_temp_html =~ s/__ADD_SPACE__/$ad_str/g;

print <<_HEADER_;
Content-type: $content_type;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_

print $base_temp_html;


exit;


sub output_access_log
{
    open LOG, ">>$access_log"  || ( printError("Can't open log 1") && exit );
    printf LOG "[%s] %s\r\n", scalar(localtime()), join(" ",@_);
    close LOG;
}

sub output_log
{
    open LOG, ">>$system_log" || ( printError("Can't open log 2") && exit );
    printf LOG "[%s] %s\r\n", scalar(localtime()), join("",@_);
    close LOG;
}

sub notice
{
    output_log(sprintf("[NOTICE] %s", join("",@_) ));
}

sub error
{
    output_log(sprintf("[ERROR] %s", join("",@_) ));
}

sub warning
{
    output_log(sprintf("[WARNING] %s", join("",@_) ));
}

sub printError
{
    my $error_str = join("",@_);
    error($error_str);
print <<_HEADER_;
Content-type: $content_type;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
<html>
<head>
<title>ERROR!</title>
</head>
<body>
Having error!
<br />
$error_str
</body>
</html>
_HEADER_
    exit;
}


sub getOptionTag
{
    my $v = shift;
    my $selected = [ "","", "$selected_str", "", "" ];

    my $opt = sprintf '<option value="0"%s>--</option><option value="1"%s>Åõ</option><option value="2"%s>Å~</option>', (@{$selected})[2-$v,3-$v,4-$v];
    return $opt;
}


sub calcDef
{
    my $tmp_value  = shift;
    my $tmp_regist = shift;
    my $ap         = shift;
    return 0 if ( $tmp_regist == 0 );
    my $value = sprintf "%d", ($tmp_value - ( ( abs($tmp_value) < abs($ap/2) ? $tmp_value : ($ap/2)) * ( $tmp_regist / abs( $tmp_regist) ) ) );
    return $value;
}
