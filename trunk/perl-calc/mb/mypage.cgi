#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;



my $ad_str = "";

my $db = DbUtil::getDbHandler();

our $out = {
    NAME  => "ななし",
    MSG   => "よろしく",
    BRD   => "ちわー",
    PLACE => "彼の庭",
    GOLD  => 120327,
    FACE  => 0,
    HAIR  => 0,
    V_HP  => 100,
    V_MHP => 100,
    V_CON => "0&nbsp;&nbsp;",
    V_ATK => "89&nbsp;",
    V_MAG => "0&nbsp;&nbsp;",
    V_DEF => "60&nbsp;",
    V_AGL => "55&nbsp;",
    V_KHI => "100",
    V_SNC => "100",
    V_LUK => "100",
    V_HMT => "100",
    V_CHR => "100",
};

my $dp = "../data";
my $t  = "$dp/anothark";
my $base_template = "$t/template.html";
my $body_template = "$t/body_mypage.html";
#my $index_list = "$p/index.list";
#my $last_index = "$p/last_index.txt";
my $system_log = "../.htlog/aa_calc.log";
my $access_log = "../.htlog/aa_access.log";

my $version = "0.1a20120328";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




my $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
#my $mob_uid = get_muid();
my $c = new CGI();


my $sth  = $db->prepare("SELECT b.user_id AS user_id, b.user_name AS user_name, b.msg AS msg, b.face_type AS face_type, b.hair_type AS hair_type, s.a_max_hp AS max_hp, s.a_hp AS hp  FROM t_user AS b JOIN t_user_status s USING( user_id ) WHERE b.carrier_id = ? AND b.uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();


if ( ! $sth->rows() > 0 )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}

$out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
$out->{V_HP} =  $row->{hp};
$out->{V_MHP} = $row->{max_hp};
$out->{MSG}   = $row->{msg};
$out->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
$out->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};
$db->disconnect();





output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
my $name = <<_NAME_;
マイページ
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

    my $opt = sprintf '<option value="0"%s>--</option><option value="1"%s>○</option><option value="2"%s>×</option>', (@{$selected})[2-$v,3-$v,4-$v];
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
