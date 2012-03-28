#!/usr/bin/perl

use lib qw( .htlib ../../.htlib );
use CGI;



my $dp = "../../data";
my $p  = "$dp/monster";
my $t  = "$dp/el_temp";
my $base_template = "$t/template.html";
my $body_template = "$t/body_monster.html";
my $index_list = "$p/index.list";
my $last_index = "$p/last_index.txt";
my $system_log = "../../.htlog/get_data.log";

my $version = "0.1a20100903";


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



our $selected_str = $browser eq "P" ? ' selected="true" ' : ' selected';
our $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';






my $c = new CGI();

my $id   = $c->param("id")   || undef ;
my $name = $c->param("name") || undef;
my $hp =   $c->param("hp") || 0;
my $ap =   $c->param("ap") || 0;
my $mp =   $c->param("mp") || 0;
my $sp =   $c->param("sp") || 0;

my $type = { map { ( $_ => ( $c->param($_) || 0 ) ) } (1 .. 14)  };

#    í‘°:
#    [<input type="checkbox" name="type" value="1">ËŞ°½Ä]
#    [<input type="checkbox" name="type" value="2">²İ¾¸Ä]
#    [<input type="checkbox" name="type" value="3">Ìß×İÄ]
#    <br>
#    [<input type="checkbox" name="type" value="4">±İÃŞ¯ÄŞ]
#    [<input type="checkbox" name="type" value="5">Ë­°ÏÉ²ÄŞ]
#    [<input type="checkbox" name="type" value="6">±½Ä×Ù]
#    <br>
#    [<input type="checkbox" name="type" value="7">–‚“®‘Ì]
#    [<input type="checkbox" name="type" value="8">‹@ŠB‘Ì]
#    [<input type="checkbox" name="type" value="9">ÄŞ×ºŞİ]
#    <br>
#    [<input type="checkbox" name="type" value="10">¹²µ½]
#    [<input type="checkbox" name="type" value="11">Ù°À°]
#    [<input type="checkbox" name="type" value="12">Ù°×°]
#    <br>
#    [<input type="checkbox" name="type" value="13">ÎŞ½]


my $t_slash  = $c->param("t_slash") || 0;
my $t_crush  = $c->param("t_crush") || 0;
my $t_thrust = $c->param("t_thrust") || 0;
my $t_mind   = $c->param("t_mind") || 0;
my $t_fire   = $c->param("t_fire") || 0;
my $t_cold   = $c->param("t_cold") || 0;
my $t_light  = $c->param("t_light") || 0;
my $t_dark   = $c->param("t_dark") || 0;





#    [‘®«‘Ï«]
#    aŒ‚<input type="text" name="t_slash"  value="0"> ‰Š<input type="text" name="t_fire"     value="0"><br>
#    ÕŒ‚<input type="text" name="t_crush"  value="0"> —â<input type="text" name="t_cold"     value="0"><br>
#    ŠÑ’Ê<input type="text" name="t_thrust" value="0"> Œõ<input type="text" name="t_light"    value="0"><br>
#    ¸_<input type="text" name="t_mind"   value="0"> ˆÅ<input type="text" name="t_dark"     value="0"><br>


#    [ó‘Ô‘Ï«]
#    <option value="0">-</option><option value="1">›</option><option value="2">~</option>
#    yó‘Ô‘Ï«z
#    ‚k|Dn|Dr|‚v|‚r|‚a|ˆø|’e|
#    <select name="t_lift"></select>|<select name="t_down"></select>|<select name="t_dry"></select>|<select name="t_wet"></select>|<select name="t_shock"></select>|<select name="t_blank"></select>|<select name="t_draw></select>|<select name="t_knockback></select>
#    ”R|“€|–ƒ|Œ¶|‡|“Å|–Ò|
#    <select name="t_burn"></select>|<select name="t_freeze"></select>|<select name="t_para"></select>|<select name="t_confuse"></select>|<select name="t_sleep"></select>|<select name="t_poison"></select>|<select name="t_venom"></select>
#    Î|‹°|˜T|”ò|d|•ß|
#    <select name="t_stone"></select>|<select name="t_fear"></select>|<select name="t_disconcent"></select>|<select name="t_fly"></select>|<select name="t_gravity"></select>|<select name="t_capture"></select>


my $ts = {
    t_lift       => $c->param("t_lift") || 0,
    t_down       => $c->param("t_down") || 0,
    t_dry        => $c->param("t_dry") || 0,
    t_wet        => $c->param("t_wet") || 0,
    t_shock      => $c->param("t_shock") || 0,
    t_blank      => $c->param("t_blank") || 0,
    t_draw       => $c->param("t_draw") || 0,
    t_knockback  => $c->param("t_knockback") || 0,
    t_burn       => $c->param("t_burn") || 0,
    t_freeze     => $c->param("t_freeze") || 0,
    t_para       => $c->param("t_para") || 0,
    t_confuse    => $c->param("t_confuse") || 0,
    t_sleep      => $c->param("t_sleep") || 0,
    t_poison     => $c->param("t_poison") || 0,
    t_venom      => $c->param("t_venom") || 0,
    t_stone      => $c->param("t_stone") || 0,
    t_fear       => $c->param("t_fear") || 0,
    t_disconcent => $c->param("t_disconcent") || 0,
    t_fly        => $c->param("t_fly") || 0,
    t_gravity    => $c->param("t_gravity") || 0,
    t_capture    => $c->param("t_capture") || 0,
};
my %_t = (
    map { ( $_ =>  getOptionTag($type->{$_}) ) } keys %{$type},
    map { ( $_ =>  getOptionTag($ts->{$_}) )   } keys %{$ts},
);

#my $t_lift       = getOptionTag($ts->{"t_lift"});
#my $t_down       = getOptionTag($ts->{"t_down"});
#my $t_dry        = getOptionTag($ts->{"t_dry"});
#my $t_wet        = getOptionTag($ts->{"t_wet"});
#my $t_shock      = getOptionTag($ts->{"t_shock"});
#my $t_blank      = getOptionTag($ts->{"t_blank"});
#my $t_draw       = getOptionTag($ts->{"t_draw"});
#my $t_knockback  = getOptionTag($ts->{"t_knockback"});
#my $t_burn       = getOptionTag($ts->{"t_burn"});
#my $t_freeze     = getOptionTag($ts->{"t_freeze"});
#my $t_para       = getOptionTag($ts->{"t_para"});
#my $t_confuse    = getOptionTag($ts->{"t_confuse"});
#my $t_sleep      = getOptionTag($ts->{"t_sleep"});
#my $t_poison     = getOptionTag($ts->{"t_poison"});
#my $t_venom      = getOptionTag($ts->{"t_venom"});
#my $t_stone      = getOptionTag($ts->{"t_stone"});
#my $t_fear       = getOptionTag($ts->{"t_fear"});
#my $t_disconcent = getOptionTag($ts->{"t_disconcent"});
#my $t_fly        = getOptionTag($ts->{"t_fly"});
#my $t_gravity    = getOptionTag($ts->{"t_gravity"});
#my $t_capture    = getOptionTag($ts->{"t_capture"});






if ( not defined $id && $c->param("saved") )
{
    # New Id
    $id = auto_increment($last_index);
    if ( $id < 0 )
    {
        printError("Can't get next id!");
    }
}

# save






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
    printf LOG "[%s] %s\n", scalar(localtime()), join(@_);
    close LOG;
}

sub notice
{
    output_log(sprintf("[NOTICE] %s", join(@_) ));
}

sub error
{
    output_log(sprintf("[ERROR] %s", join(@_) ));
}

sub warning
{
    output_log(sprintf("[WARNING] %s", join(@_) ));
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

sub auto_increment
{
    return 1;
    my $datafile = shift;
    my $line = -1;
    if ( -f $datafile )
    {
        local $SIG{ALRM} = sub { die "time out" };
        open(OUT, "+< $datafile");
        alarm(5);
        flock(OUT, 2) or die;
        seek(OUT, 0, 0);
        chomp($line = <OUT>);
        seek(OUT, 0, 0);
        printf OUT "%s\n",$line+1;
        truncate(OUT, tell(OUT));
        close(OUT);
        alarm(0);
        if ($@ =~ /time out/) {
            return -1
        }
        elsif ($@) { die }
    }
    return $line;
}

sub getOptionTag
{
    my $v = shift;
    my $selected = [ "","", $selected_str, "", "" ];

    my $opt = sprintf '<option value="0"%s>--</option><option value="1"%s>›</option><option value="2"%s>~</option>', (@{$selected})[2-$v,3-$v,4-$v];
    return $opt;
}

