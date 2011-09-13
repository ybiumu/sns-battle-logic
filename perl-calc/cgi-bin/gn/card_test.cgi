#!/usr/local/bin/perl

use lib qw( .htlib ../../.htlib );
use CGI;

#require "../../.htlib/jcode.pl";
require "jcode.pl";


our $dp = "../../data";
our $p  = "$dp/post_map";
our $t  = "$dp/gn_temp";
our $base_template = "$t/template.html";
our $body_template = "$t/body_card_test.html";
our $system_log = "../../.htlog/gn_post_map.log";

our $version = "0.1a20110728";


our $browser = "P";
our $mons_list;
our $mons_list_name;
our $base_temp_html = "";

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



our $monster_map = {};





our $c = new CGI();

load_base_template();

card_test();

outputHtml();


exit;


sub load_base_template
{
    open(TEMP, $base_template) || ( printError("Can't open template 1") && die);
    $base_temp_html = join("",<TEMP>);
    close(TEMP);
}






sub card_test
{
    my $name = <<_NAME_;
ëIÇÒÇ≈ÇÀ
_NAME_

    my $key_map = [ map{ my $t = $_; map{ sprintf("%s%s", $t,$_ ) } (1 .. 5 ) } ('A','M','D') ];
    my $pr = {
        map {  $_ => ( $c->param($_) || '0' ) } (@{$key_map})
    };

    my $num = $c->param("num") || '1';

    my %_C = (
        map {  $_ => getOptionTag( $pr->{$_}, [0 .. 20] )   } (@{$key_map})
    );
    my $_num = getOptionTag( $num, [1 .. 3]);

    my $view = $c->param("view") || undef;
    my $toomany  = 0;
    my $toosmall = 0;
    my $deck = [];
    my $deck_map = { };
    my $_result_message = "";
    if ( $view )
    {
        # sum
        my $an = 0;


##        map { $an += $pr->{$_}; push(@{$deck},( ($_,)x$pr->{$_} )) }((@{$key_map}));
#        map {
#            my $tg_key = $_;
#            $an += $pr->{$tg_key};
#            map{ push(@{$deck},$tg_key) } (0 .. $pr->{$tg_key});
#         } (@{$key_map});
#        if ( $an > 20 )
#        {
#            $toomany = 1;
#        }
#        elsif( $an < 13 )
#        {
#            $toosmall = 13 - $an;
#            $an = 13;
#            map { push(@{$deck},"D1" ) } ( 0 .. $toosmall );
#        }
        
        map { $an += $pr->{$_}; push(@{$deck},( ($_)x$pr->{$_} )) }((@{$key_map}));
        if ( $an > 20 )
        {
            $toomany = 1;
        }
        elsif( $an < 13 )
        {
            $toosmall = 13 - $an;
            $an = 13;
            push(@{$deck},(("D1") x $toosmall ))
        }

        if ( not $toomany )
        {
            # Sheeting.
            my @real =  sort {rand() <=> rand()} @{$deck};
            my @first = (@real)[0 .. (6-$num)-1];
            my @remain = (@real)[(6-$num) .. scalar(@real)];
            $_result_message .= sprintf( "[%s]",join("][", @first));
            $_result_message .= "<br />\n";
            map { $_result_message .= sprintf("%s<br />\n",$_); } @remain;
        }
        else
        {
            $_result_message = '<div style="background-color:#FF0000;color:#FFFFFF;"><span style="font-weight: bold;font-size: medium;">∂∞ƒﬁÇ™ëΩÇ∑Ç¨Ç‹Ç∑!<br />Å¶ç≈ëÂ20ñá</span></div>';
        }
    }


    open(BODY, $body_template) || ( printError("Can't open template 2") && die );
    my $body_temp_html = join("",<BODY>);
    close(BODY);

    my $tmp_html = "";

    my $_monster_list = sprintf('<option value="0">--ëIÇÒÇ≈ÇÀ--</option>');
    foreach my $tmp_mname_id ( sort { $a <=> $b } keys %{$mons_list_name})
    {
        $_monster_list .= sprintf('<option value="%s">%s</option>', $tmp_mname_id,  $mons_list_name->{$tmp_mname_id} );
    }


    eval(
        "\$tmp_html .= <<_HERE_;
$body_temp_html
_HERE_"
    );

    $base_temp_html =~ s/__TITLE__/$name/g;
    $base_temp_html =~ s/__PAGE_TITLE__/$name/g;
    $base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;

    $base_temp_html =~ s/__RESULT_MESSAGE__/$_result_message/g;
}




sub outputHtml
{
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
}


sub output_log
{
    open LOG, ">>$system_log" or die;
    printf LOG "[%s] %s\n", scalar(localtime()), join("",@_);
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
    my $error = join("<br />", @_); 
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
Having error!<br />
$error
</body>
</html>
_HEADER_
    exit;
}

sub auto_increment
{
    my $datafile = shift;
    my $line = -1;
    if ( -f $datafile )
    {
#        local $SIG{ALRM} = sub { die "time out" };
        open(OUT, "+< $datafile");
#        alarm(5);
#        flock(OUT, 2) or die;
        seek(OUT, 0, 0);
        chomp($line = <OUT>);
        seek(OUT, 0, 0);
        printf OUT "%s\n",$line+1;
        truncate(OUT, tell(OUT));
        close(OUT);
#        alarm(0);
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
    my $list = shift;

    my $opt = join("",(map { sprintf '<option value="%s"%s>%s</option>',$_,($_ eq $v ? $selected_str: ""),$_ } @{$list}) );
    return $opt;
}

sub strOptimize
{
    my $str = shift;
    return if not $$str;
    &jcode::z2h_sjis($str);
    $$str =~ s/(ÅA|§|°)/,/g;
}
