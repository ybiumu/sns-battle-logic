#!/usr/bin/perl


############
### INIT ###
############
use lib qw( .htlib ../../.htlib );
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
my $t  = "$dp/el_temp";
my $base_template = "$t/template.html";
my $body_template = "$t/body_howmany.html";

#my $p  = "$dp/user";
#my $index_list = "$p/index.list";
#my $last_index = "$p/last_index.txt";

my $system_log = "../../.htlog/howmany_loop.log";

my $version = "0.1a20110512";
#my $debug_strings = "";


my $content_type = "text/html";
my $browser = "P";
my $uid ="";

if( $ENV{HTTP_USER_AGENT} =~ /^DoCoMo\/(1|2)/)
{
    $browser = "D";
    $uid = $ENV{X_DOCOMO_GUID};
    $content_type = "application/xhtml+xml";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /UP\.Browser\// )
{
    $browser = "A";
    $uid = $ENV{X_UP_SUBNO};
    $content_type = "application/xhtml+xml";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /^(J-PHONE|Vodafone|MOT-|SoftBank)/ )
{
    $browser = "S";
    $uid = $ENV{X_JPHONE_UID};
    $content_type = "application/xhtml+xml";
}



our $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
our $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';

our $_format_line = qq[%04s: 熟練度が%s上がった。現在%.1f];


##################
### Data Parse ###
##################
my $c = new CGI();

output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');

my $name = <<_NAME_;
ﾙｰﾌﾟ、あと何更新?
_NAME_

# 現在の熟練
my $cj = $c->param("cj") || 0;
# なりたいLv
my $tl = $c->param("tl") || 0;
# 敵ﾊﾟｰﾃｨLv
my $pl = $c->param("pl") || 0;

# ｳｪｲﾄﾘｽﾄﾊﾞﾝﾄﾞ使用
my $c_isw = $c->param("isw") ? "$checked_str" : "";

my $rate = $c_isw ? 1.2 : 1;


# 現在の熟練(作業用)
my $wcj = $cj;
# 現在の熟練(ﾚﾍﾞﾙ算出用一時)
my $tmp_cj = ($wcj - 0.5) * 2;
# 現在のﾚﾍﾞﾙ
my $cl = int(sqrt($tmp_cj < 0 ? 0 : $tmp_cj) );


############
### calc ###
############
my $_logs = "";
if ( $tl == 0 )
{
    $_logs = qq[なりたいLvを入力してください];
}
elsif ( $tl <= $cl )
{
    $_logs = qq[君の熟練度はもう上がらない…];
}
else
{
    my @stack;

    my $dl = $tl - $cl; # 目標との差異
    my $tcnt = 0;
    my $tmp_c = 0;

    # 各ﾚﾍﾞﾙごとに計算
    for ( my $i = 1; $i <= $dl; $i++ )
    {
        # 計算用にLvをあげる
        my $n  = $cl + $i;
        # そのLvに必要な熟練度算出
        my $rj = int(($n**2)/2 + 1);
        # 敵ﾊﾟｰﾃｨｰとのLv差異
        my $rl = $pl - ($n - 1);
        if ( $rl <= 0)
        {
            unshift(@stack, sprintf("Lv%s で打ち止めだけどね…\n", $n - 1));
            last;
        }
#    printf STDERR "N : %s<br />\n", $n;
#    printf STDERR "PL: %s<br />\n", $pl;
#    printf STDERR "RL: %s<br />\n", $rl;
        # ゲットできる熟練
        my $gj = ( ( $rl > 10 ? 10 : $rl ) * $rate ) / 2;
#    printf STDERR "GJ: %s<br />\n", $gj;
        # ループ回数
        my $cnt  = int(( $rj - $wcj ) / $gj);
        # 端数算出
        $cnt += ((( $rj - $wcj )*10) % ($gj*10) ? 1 : 0);
        # このﾚﾍﾞﾙでのﾙｰﾌﾟ処理
        for (my $j = 0; $j < $cnt; $j++)
        {
            $wcj += $gj;
            push(@stack,sprintf($_format_line , ++$tmp_c, $gj, $wcj ) );
        }
        $tcnt += $cnt;
    }

    unshift(@stack, sprintf("%s ﾙｰﾌﾟ頑張れ!\n", $tcnt));

    $_logs = join("<br/>\r\n", @stack);
}





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

$base_temp_html =~ s/__ADD_SPACE__/$add_str/g;

$base_temp_html =~ s/__LOGS__/$_logs/g;

print <<_HEADER_;
Content-type: $content_type;

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
    notice($v);
    my $selected = [ "", $selected_str, "" ];

    my $opt = sprintf '<option value="0"%s>×</option><option value="1"%s>○</option>', (@{$selected})[1-$v,2-$v];
    return $opt;
}

#sub setLogStack
#{
#    $debug_strings .= sprinf("%s<br />\n",shift);
#}
