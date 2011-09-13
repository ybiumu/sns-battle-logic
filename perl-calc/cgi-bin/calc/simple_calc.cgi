#!/usr/local/bin/perl

use lib qw( .htlib ../../.htlib );
use Ellark::Battle::BaseValue;
use Ellark::Battle::TargetValue;
use Ellark::Battle::StatusValue;
use CGI;



my $dp = "../../data";
my $p  = "$dp/moncenter";
my $t  = "$dp/el_temp";
my $base_template = "$t/template.html";
my $body_template = "$t/body_calc.html";
#my $index_list = "$p/index.list";
#my $last_index = "$p/last_index.txt";
my $system_log = "../../.htlog/calc.log";
my $access_log = "../../.htlog/access.log";

#my $version = "0.1a20100726";
#my $version = "0.1a20100803";
#my $version = "0.1a20100805";
my $version = "0.1a20101208";



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

output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
#output_access_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}"], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');

#my $id   = $c->param("id")   || undef ;
my $name = <<_NAME_;
êÌì¨åvéZéÆ
_NAME_
#my $hp =   $c->param("hp") || 0;
my $ap =   $c->param("ap") || 0;

#my $_damage = "";
my $_value  = "";
my $base = new Ellark::Battle::BaseValue();
my $status = new Ellark::Battle::StatusValue();
my $target = new Ellark::Battle::TargetValue();




# -A-
my $ps   = $c->param("ps") || 0;
$base->setPs($ps);
my $sr   = $c->param("sr") || 1;
$base->setSr($sr);

my $main_expr   = $c->param("main_expr") || 0;
$base->setMainExpr($main_expr);
my $sub_expr   = $c->param("sub_expr") || 0;
$base->setSubExpr($sub_expr);
my $expr_rate   = $c->param("expr_rate") || 1;
$base->setExprType($expr_rate);

my %_er =(1=>"",2=>"",3=>"", 4=>"" , 5=>"");
$_er{$expr_rate} = "$selected_str";

my $range_rate   = $c->param("range_rate") || 1;
$base->setRange($range_rate);

my %_range = ( 1 => "", 0.9 => "", 0.8 => "" );
$_range{$range_rate} = "$selected_str";


my $rand_rate   = $c->param("rand_rate") || 0;
my %_rand = ( 0 => "", 5 => "", 10 => "", 20 => "", 25 => "", 50 => "", 100 => "");
$base->setRand($rand_rate);
$_rand{$rand_rate} = "$selected_str";


# -B-
my $concent_type = $c->param("concent_type") || 0;
$target->setConcentType($concent_type);
my %_c = (0=>"",1=>"",2=>"");
$_c{$concent_type} = "$selected_str";


my $concent   = $c->param("concent") || 0;
$target->setConcent($concent);
my $power_val   = $c->param("power_val") || 0;
$target->setPlaceVal($power_val);
my $chain   = $c->param("chain") || 1;
$target->setChain($chain);

# -C-
my $seed_rate  = $c->param("seed_rate") || 0;
$status->setSeedRateType($seed_rate);
my $_weak   = "";
my $_normal = "";
my $_strong = "";

if ( $seed_rate == -1 ) 
{
    $_weak = "$selected_str";
}
elsif ( $seed_rate == 1 ) 
{
    $_strong = "$selected_str";
}
else
{
    $_normal = "$selected_str";
}

my $main_regist   = $c->param("main_regist") || 0;
$status->setMainRegist($main_regist);
my $sub_regist   = $c->param("sub_regist") || 0;
$status->setSubRegist($sub_regist);
if( $expr_rate != 1 && $expr_rate != 4 )
{
    $status->setRegistType(1);
}






my $c_sleep = $c->param("sleep") ? "$checked_str" : "";
if ( $c_sleep ) { $status->setSleep(1) };
my $c_stone = $c->param("stone") ? "$checked_str" : "";
if ( $c_stone ) { $status->setStone(1) };

my $_damages = "";



my $line_str  = q[ÇÃ¿ﬁ“∞ºﬁ!];
my $line_deco = q[<span style="font-size:x-small; color: red; font-style: bold;">%3s</span>];
my $line_temp = $line_deco . $line_str;
my @damage_rec;
if ( $c->param("calc") )
{

    my $tmp_value;
    my $tmp_regist = $status->getRegistRate();
    if( $tmp_regist < 0 )
    {
        $tmp_value = $base->calc_min() * $status->calc() * $target->calc();
        push( @damage_rec, sprintf( "ç≈ëÂ".$line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));

        $tmp_value = $base->calc_center() * $status->calc() * $target->calc();
        push( @damage_rec, sprintf( $line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));

        $tmp_value = $base->calc_max() * $status->calc() * $target->calc();
        push( @damage_rec, sprintf( "ç≈è¨".$line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));
    }
    else
    {
        $tmp_value = $base->calc_max() * $status->calc() * $target->calc();
        push( @damage_rec, sprintf( "ç≈ëÂ".$line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));

        $tmp_value = $base->calc_center() * $status->calc() * $target->calc();

#        push( @damage_rec, "[debug] $tmp_value");
#        my $tmp_base_def = ( abs($tmp_value) < abs($ap/2) ? $tmp_value : ($ap/2));
#        my $tmp_dir_def  = ( $tmp_regist / abs( $tmp_regist) );
#        push( @damage_rec, "[debug] $tmp_value");
#        push( @damage_rec, "[debug] $tmp_base_def");
#        push( @damage_rec, "[debug] $tmp_dir_def");
#
#        my $debug_value = $tmp_value - ( $tmp_base_def * $tmp_dir_def );
#        push( @damage_rec, "[debug] $debug_value");
#        $debug_value = sprintf "%d",  $debug_value ;
#        push( @damage_rec, "[debug] $debug_value");

        push( @damage_rec, sprintf( $line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));

        $tmp_value = $base->calc_min() * $status->calc() * $target->calc();
        push( @damage_rec, sprintf( "ç≈è¨".$line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));
    }
#    my $tmp_regist = "1";

#    if ( $tmp_regist == 0 )
#    {
#        warning("[regist]".$status->getRegistRate()); 
#        warning("[serial]".$status->getSerialRegist()); 
#        $_value = 0;
#    }
#    else
#    {
#        $_value = int($tmp_value - ( ( abs($tmp_value) < abs($ap/2) ? $tmp_value : ($ap/2)) * ( $tmp_regist / abs( $tmp_regist) ) ) );
#        $_value = calcDef($tmp_value,$tmp_regist,$ap);
#    }

}
elsif ( $c->param("calc_all") )
{
    my $tmp_value;
    my $tmp_regist;

    my @tmp_line;
    foreach my $rv (reverse ( @{$base->RAND_MAP->{$base->getRand()}} ))
    {
        $tmp_value = $base->calc_target($rv) * $status->calc() * $target->calc();
#        $tmp_value = sprintf("%d",$tmp_value+0.4); 
        $tmp_regist = $status->getRegistRate();
        push( @tmp_line, sprintf( $line_deco,calcDef($tmp_value,$tmp_regist,$ap) ));
        if ( scalar(@tmp_line) == 5 || $rv == 0 )
        {
            push( @damage_rec, join("&nbsp;", @tmp_line) );
            @tmp_line = ();
        }
#        push( @damage_rec, sprintf( $line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));
#        unshift( @damage_rec, sprintf( $line_temp,calcDef($tmp_value,$tmp_regist,$ap) ));
    }
    if ( scalar(@tmp_line) > 0 )
    {
            push( @damage_rec, join("&nbsp;", @tmp_line) );
            @tmp_line = ();
    }
    push(@damage_rec,$line_str);
}

$_damages = join("<br/>\r\n", @damage_rec);

#if ( not defined $id && $c->param("saved") )
#{
#    # New Id
#    $id = auto_increment($last_index);
#    if ( $id < 0 )
#    {
#        printError("Can't get next id!");
#    }
#}
#
## save




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

#$base_temp_html =~ s/__VALUE__/$_value/g;
#$base_temp_html =~ s/__DAMAGE__/$_damage/g;
$base_temp_html =~ s/__DAMAGES__/$_damages/g;

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


sub output_access_log
{
    open LOG, ">>$access_log" or die;
    printf LOG "[%s] %s\r\n", scalar(localtime()), join(" ",@_);
    close LOG;
}

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


sub calcDef
{
    my $tmp_value  = shift;
    my $tmp_regist = shift;
    my $ap         = shift;
    return 0 if ( $tmp_regist == 0 );
    my $value = sprintf "%d", ($tmp_value - ( ( abs($tmp_value) < abs($ap/2) ? $tmp_value : ($ap/2)) * ( $tmp_regist / abs( $tmp_regist) ) ) );
    return $value;
}
