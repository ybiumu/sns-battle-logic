#!/usr/bin/perl

use lib qw( .htlib ../../.htlib );
use Ellark::Battle::BaseValue;
use Ellark::Battle::TargetValue;
use Ellark::Battle::StatusValue;
use CGI;


use LWP::UserAgent;
#use Time::HiRes qw(gettimeofday);
use URI::Escape;

sub google_append_color {
  my @color_array = split(/,/, $_[0]);
  return $color_array[$_[1] % @color_array];
}

sub google_append_screen_res {
  my $screen_res = $ENV{"HTTP_UA_PIXELS"};
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_UP_DEVCAP_SCREENPIXELS"};
  }
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_JPHONE_DISPLAY"};
  }
  my @res_array = split("[x,*]", $screen_res);
  if (@res_array == 2) {
    return "&u_w=" . $res_array[0] . "&u_h=" . $res_array[1];
  }
}

sub google_append_muid {
  my $muid = $ENV{"HTTP_X_DCMGUID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  $muid = $ENV{"HTTP_X_UP_SUBNO"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  $muid = $ENV{"HTTP_X_JPHONE_UID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
  $muid = $ENV{"HTTP_X_EM_UID"};
  if ($muid) {
    return "&muid=" . $muid;
  }
}

sub google_append_via_and_accept {
  if ($_[0] eq "") {
    my $via_and_accept;
    my $via = uri_escape($ENV{"HTTP_VIA"});
    if ($via) {
      $via_and_accept = "&via=" . $via;
    }
    my $accept = uri_escape($ENV{"HTTP_ACCEPT"});
    if ($accept) {
      $via_and_accept = $via_and_accept . "&accept=" . $accept;
    }
    if ($via_and_accept) {
      return $via_and_accept;
    }
  }
}

#my $google_dt = sprintf("%.0f", 1000 * gettimeofday());
my $google_dt = sprintf("%.0f000", time);
my $google_scheme = ($ENV{"HTTPS"} eq "on") ? "https://" : "http://";
my $google_user_agent = uri_escape($ENV{"HTTP_USER_AGENT"});

my $google_ad_url = "http://pagead2.googlesyndication.com/pagead/ads?" .
  "ad_type=text_image" .
  "&channel=1601906528" .
  "&client=ca-mb-pub-6767456309495643" .
  "&color_border=" . google_append_color("000000", $google_dt) .
  "&color_bg=" . google_append_color("F0F0F0", $google_dt) .
  "&color_link=" . google_append_color("0000FF", $google_dt) .
  "&color_text=" . google_append_color("000000", $google_dt) .
  "&color_url=" . google_append_color("008000", $google_dt) .
  "&dt=" . $google_dt .
  "&format=mobile_double" .
  "&ip=" . uri_escape($ENV{"REMOTE_ADDR"}) .
  "&markup=xhtml" .
  "&oe=sjis" .
  "&output=xhtml" .
  "&ref=" . uri_escape($ENV{"HTTP_REFERER"}) .
  "&url=" . uri_escape($google_scheme . $ENV{"HTTP_HOST"} . $ENV{"REQUEST_URI"}) .
  "&useragent=" . $google_user_agent .
  google_append_screen_res() .
  google_append_muid() .
  google_append_via_and_accept($google_user_agent);

my $google_ua = LWP::UserAgent->new;
my $google_ad_output = $google_ua->get($google_ad_url);
my $add_str = undef;
if ($google_ad_output->is_success) {
    $add_str = $google_ad_output->content;
}



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
my $content_type = "text/html";
my $browser = "P";

if( $ENV{HTTP_USER_AGENT} =~ /^DoCoMo\/(1|2)/)
{
        $browser = "D";
        $content_type = "application/xhtml+xml";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /UP\.Browser\// )
{
        $browser = "A";
        $content_type = "application/xhtml+xml";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /^(J-PHONE|Vodafone|MOT-|SoftBank)/ )
{
        $browser = "S";
        $content_type = "application/xhtml+xml";
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

$base_temp_html =~ s/__ADD_SPACE__/$add_str/g;

$base_temp_html =~ s/__RESULT__/$_result/g;

print <<_HEADER_;
Content-type: $content_type;

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


