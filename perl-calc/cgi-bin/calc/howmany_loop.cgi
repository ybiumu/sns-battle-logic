#!/usr/local/bin/perl


############
### INIT ###
############
use lib qw( .htlib ../../.htlib );
use CGI;



my $dp = "../../data";
my $t  = "$dp/el_temp";
my $base_template = "$t/template.html";
my $body_template = "$t/body_howmany.html";

#my $p  = "$dp/user";
#my $index_list = "$p/index.list";
#my $last_index = "$p/last_index.txt";

my $system_log = "../../.htlog/howmany_loop.log";

my $version = "0.1a20110512";
#my $debug_strings = "";


my $browser = "P";
my $uid ="";

if( $ENV{HTTP_USER_AGENT} =~ /^DoCoMo\/(1|2)/)
{
    $browser = "D";
    $uid = $ENV{X_DOCOMO_GUID};
}
elsif( $ENV{HTTP_USER_AGENT} =~ /UP\.Browser\// )
{
    $browser = "A";
    $uid = $ENV{X_UP_SUBNO};
}
elsif( $ENV{HTTP_USER_AGENT} =~ /^(J-PHONE|Vodafone|MOT-|SoftBank)/ )
{
    $browser = "S";
    $uid = $ENV{X_JPHONE_UID};
}



our $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
our $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';

our $_format_line = qq[%04s: 熟練度が%s上がった。現在%s];


##################
### Data Parse ###
##################
my $c = new CGI();

output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');

my $name = <<_NAME_;
ﾙｰﾌﾟ、あと何更新?
_NAME_

my $cj = $c->param("cj") || 0;
my $tl = $c->param("tl") || 0;
my $pl = $c->param("pl") || 0;


my $wcj = $cj;



############
### calc ###
############
my $tmp_cj = ($wcj - 0.5) * 2;
my $cl = int(sqrt($tmp_cj < 0 ? 0 : $tmp_cj) );
my @stack;

my $r = $tl - $cl;
my $tc = 0;
my $tmp_c = 0;
for ( my $i = 1; $i <= $r; $i++ )
{
    my $n  = $cl + $i;
    my $rj = int(($n**2)/2 + 1);
    my $rl = $pl - ($n - 1);
#    printf STDERR "N : %s<br />\n", $n;
#    printf STDERR "PL: %s<br />\n", $pl;
#    printf STDERR "RL: %s<br />\n", $rl;
    my $gj = ( $rl > 10 ? 10 : $rl ) / 2;
#    printf STDERR "GJ: %s<br />\n", $gj;
    my $c  = int(( $rj - $wcj ) / $gj);
    # 端数算出
    $c += ((( $rj - $wcj )*10) % ($gj*10) ? 1 : 0);
    for (my $j = 0; $j < $c; $j++)
    {
        $wcj += $gj;
        push(@stack,sprintf($_format_line , ++$tmp_c, $gj, $wcj ) );
    }
    $tc += $c;
}

unshift(@stack, sprintf("%s\n", $tc));

my $_logs = join("<br/>\r\n", @stack);





# page
open(TEMP, $base_template) || ( printError("Can't open template 1") && die);
my $base_temp_html = join("",<TEMP>);
close(TEMP);

#printf "%s\n", $base_template;
#printf "%s\n", $base_temp_html;

open(BODY, $body_template) || ( printError("Can't open template 2") && die );
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


$base_temp_html =~ s/__LOGS__/$_logs/g;

print <<_HEADER_;
Content-type: application/xhtml+xml;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_

print $base_temp_html;

#__PAGE_TITLE__
#__TITLE__
#__MESSAGE_BODY__

#print $c->end_html();

exit;

sub output_log
{
    open LOG, ">>$system_log" or die;
    printf LOG "[%s] %s\n", scalar(localtime()), join(" ", @_);
    close LOG;
}

sub notice
{
    output_log(sprintf("[NOTICE] %s", join(" ", @_) ));
}

sub error
{
    output_log(sprintf("[ERROR] %s", join(" ", @_) ));
}

sub warning
{
    output_log(sprintf("[WARNING] %s", join(" ", @_) ));
}

sub printError
{
    error(join(@_));
print <<_HEADER_;
Content-type: application/xhtml+xml;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
<html>
<head>
<title>ERROR!</title>
</head>
<body>
Having error!
</body>
</html>
_HEADER_
    exit;
}


sub getOptionTag
{
    my $v = shift;
    notice($v);
    my $selected = [ "", $selected_str, "" ];

    my $opt = sprintf '<option value="0"%s>×</option><option value="1"%s>○</option>', (@{$selected})[1-$v,2-$v];
    return $opt;
}

#sub setLogStack
#{
#    $debug_strings .= sprinf("%s<br />\n",shift);
#}
