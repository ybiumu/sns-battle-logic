#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DBI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;



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

$debug_str .= "CT: $content_type <br />\n";
$debug_str .= "BW: $browser <br />\n";
$debug_str .= "CI: $carrier_id <br />\n";


my $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();

$debug_str .= "UI: $mob_uid <br />\n";
my $c = new CGI();

our $out  = {};

$out->{m}  = $c->param("m") || "d";
$out->{id} = $c->param("id") || "0";


my $sth;
my $stat;
if ( $out->{m} eq "d")
{
    $sth  = $db->prepare("SELECT result_id, scenario_id, node_id, result_text FROM t_result_master WHERE result_id = ?");
    $stat = $sth->execute( $out->{id} );

    my $row  = $sth->fetchrow_hashref();
    my $rownum = $sth->rows();
    my $result_id   = $row->{result_id};
    my $scenario_id = $row->{scenario_id};
    my $node_id     = $row->{node_id};

    $body_

    my $result_id = 0;
    my $r_row = "";
    my $result_text = "";
    my $first = 0;

    if ( $sth->rows() > 0 )
    {

        $out->{NAME} = sprintf("%s", $row->[1]);
        my $sth2 = $db->prepare("SELECT result_id, result_title, result_text FROM t_user_result WHERE user_id = ? ORDER BY result_date LIMIT 1 ");
        my $stat2 = $sth2->execute(($user_id));
        $r_row  = $sth2->fetchrow_arrayref();
        my $rownum2 = $sth2->rows();

        if ( $rownum2 == 0 )
        {
            $first = 1;
        }

        $result_text  = $r_row->{result_text};

    }
}
else
{
    $sth  = $db->prepare("SELECT result_id, scenario_id, node_id FROM t_result_master LIMIT 50");
}
$stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();
my $rownum = $sth->rows();
my $user_id   = $row->{user_id};
my $user_name = $row->{user_name};

my $result_id = 0;
my $r_row = "";
my $result_text = "";
my $first = 0;

##printf STDERR "%s\n", $sth->rows();
if ( $sth->rows() > 0 )
{

    $out->{NAME} = sprintf("%s", $row->[1]);
    my $sth2 = $db->prepare("SELECT result_id, result_title, result_text FROM t_user_result WHERE user_id = ? ORDER BY result_date LIMIT 1 ");
    my $stat2 = $sth2->execute(($user_id));
    $r_row  = $sth2->fetchrow_arrayref();
    my $rownum2 = $sth2->rows();

    if ( $rownum2 == 0 )
    {
        $first = 1;
    }

    $result_text  = $r_row->{result_text};

}
else
{
}

$db->disconnect();



$debug_str .= "RN: $rownum <br />\n";


output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
my $name = $r_row->{"result_title"};


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
