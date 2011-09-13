#!/usr/local/bin/perl

use lib qw( .htlib ../../.htlib );
use Ellark::Battle::BaseValue;
use Ellark::Battle::TargetValue;
use Ellark::Battle::StatusValue;
use CGI;



my $dp = "../../data";
my $p  = "$dp/monster";
my $t  = "$dp/el_temp";
my $base_template = "$t/template.html";
my $body_template = "$t/body_calc_diff.html";
#my $index_list = "$p/index.list";
#my $last_index = "$p/last_index.txt";
my $system_log = "../../.htlog/calc.log";
#my $access_log = "../../.htlog/access.log";

#my $version = "0.1a20100726";
#my $version = "0.1a20100803";
my $version = "0.1a20100810";


######################
### BROWSER DETECT ###
######################
my $browser = "P";

if( $ENV{HTTP_USER_AGENT} =~ /^DoCoMo\/(1|2)/)
{
        $browser = "D";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /UP\.Browser\// )
{
        $browser = "A";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /^(J-PHONE|Vodafone|MOT-|SoftBank)/ )
{
        $browser = "S";
}

my $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';




my $c = new CGI();

output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}"], '" '.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
#output_access_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}"], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');

#my $id   = $c->param("id")   || undef ;
my $name = <<_NAME_;
ñhå‰•ëœê´åvéZã@
_NAME_
#my $hp =   $c->param("hp") || 0;

#my $_damage = "";
#my $_value  = "";




# -A-
my $dmw1  = $c->param("dmw1") || 0;
my $dmr1  = $c->param("dmr1") || 0;

my $dmw2  = $c->param("dmw2") || 0;
my $dmr2  = $c->param("dmr2") || 0;


my $_result = "";

my $lv_map = {
    0  => "åüéZÇ…ÇƒÉuÉåñ≥Çµ",
    -1 => "PS1åüéZÇ…ÇƒÉuÉå",
    -2 => "PS2åüéZÇ…ÇƒÉuÉå",
    -3 => "PS1ÅAPS2åüéZÇ…ÇƒÉuÉå",
};


my $line_str  = q[ÇÃ¿ﬁ“∞ºﬁ!];
my $line_deco = q[<span style="font-size:x-small; color: red; font-style: bold;">%3s</span>];
my $line_temp = $line_deco . $line_str;
my @result_rec;
if ( $c->param("calc") )
{
    my $delta_w = $dmw2 - $dmw1;
    if ( $delta_w == 0 )
    {
        push( @result_rec, sprintf( $line_temp, "ó^¿ﬁ“(‹—ƒﬁ)ÇÃç∑Ç™0Ç…Ç»ÇÁÇ»Ç¢ÇÊÇ§Ç…ÇµÇƒÇ≠ÇæÇ≥Ç¢!" ));
    }
    else
    {
#        my $ap  = 2 * ( ( $dmw1 * $dmr2 ) - ($dmw2 * $dmr1) ) / $delta_w;
        my $reg =  ( $dmr2 - $dmr1 ) / $delta_w;
        my $temp_reg = $reg*100;
        my $diff_reg = sprintf("%d", $temp_reg);
        if ( $temp_reg != $diff_reg )
        {
            $temp_reg = $diff_reg + 1;
            $reg = $temp_reg / 100;
        }
        my $ap = sprintf("%d", ($dmw2 + $dmw1) * $reg  - ($dmr2+$dmr1) );


        

        my $ch1 = sprintf("%d",$dmw1 * $reg - $ap / 2);
        my $ch2 = sprintf("%d",$dmw2 * $reg - $ap / 2);
        my $lv  = 0;
        $lv-- if $ch1 != $dmr1;
        $lv-=2 if $ch2 != $dmr2;

        push( @result_rec, sprintf( "ñhå‰" . $line_deco,  $ap  ));
        push( @result_rec, sprintf( "ëœê´" . $line_deco,  100 - ($reg * 100) ));
        push( @result_rec, sprintf( "ê∏ìx".  $line_deco,  $lv ));
        push( @result_rec, sprintf( "Å¶ê∏ìxÇ…ä÷ÇµÇƒ(%s:%s)", $lv, $lv_map->{$lv}));
    }
}

$_result = join("<br/>\r\n", @result_rec);





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

$base_temp_html =~ s/__RESULT__/$_result/g;

print <<_HEADER_;
Content-type: application/xhtml+xml;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_

print $base_temp_html;



exit;


#sub output_access_log
#{
#    open LOG, ">>$access_log" or die;
#    printf LOG "[%s] %s\r\n", scalar(localtime()), join(" ",@_);
#    close LOG;
#}

sub output_log
{
    open LOG, ">>$system_log" or die;
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
    error(join("",@_));
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
    my $selected = [ "","", "$selected_str", "", "" ];

    my $opt = sprintf '<option value="0"%s>--</option><option value="1"%s>Åõ</option><option value="2"%s>Å~</option>', (@{$selected})[2-$v,3-$v,4-$v];
    return $opt;
}


