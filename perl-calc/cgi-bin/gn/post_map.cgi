#!/usr/local/bin/perl

use lib qw( .htlib ../../.htlib );
use CGI;

#require "../../.htlib/jcode.pl";
require "jcode.pl";


our $dp = "../../data";
our $p  = "$dp/post_map";
our $t  = "$dp/gn_temp";
our $base_template = "$t/template.html";
our $body_template = "$t/body_post_map.html";

our $select_body_template = "$t/body_select_map.html";
our $view_body_template = "$t/body_view_map.html";

our $grid_body_template = "$t/body_grid.html";

our $index_list = "$p/index.list";
our $last_index = "$p/last_index.txt";
our $map_data   = "$p/data.txt";
our $mons_index = "$p/mons_index.list";
our $li_mons    = "$p/li_mons.txt";
our $system_log = "../../.htlog/gn_post_map.log";

our $version = "0.1a20110722";

our $MAX_PAGE_SIZE = 10;
our $MAX_INDEX_SIZE = 50;

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
our $grid_element = [];
our $index_record = [];


our $color_map  = {
    0  => "005000",
    1  => "00a000",
    2  => "00ff00",
    3  => "40ff00",
    4  => "80ff00",
    5  => "a0ff00",
    6  => "ffff00",
    7  => "ffb000",
    8  => "ff8000",
    9  => "ff4000",
    10 => "ff0000",
};

our $map_map = [
    'ｼｱﾌｨｰﾙ平原',
    'ﾍﾞﾙｶﾞﾘｵ砂漠',
];


our $c = new CGI();
my $isview = $c->param("view") || undef;

load_base_template();

if ( $isview )
{
    my $view_type = $c->param("view_type") || 1;
    if ( $view_type == 1 )
    {
        select_target();
    }
    elsif( $view_type == 2 )
    {
        view_by_grid()
    }
    elsif( $view_type == 3 )
    {
        view_by_monster()
    }
    elsif( $view_type == 4 )
    {
        view_index();
    }
    elsif( $view_type == 5 )
    {
        view_by_id();
    }
    else
    {
        view_map();
    }
}
else
{
    post_map();
}

outputHtml();


exit;


sub load_base_template
{
    open(TEMP, $base_template) || ( printError("Can't open template 1") && die);
    $base_temp_html = join("",<TEMP>);
    close(TEMP);
}

sub view_by_grid
{
    my $map = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';
    my $x = $c->param("x") || 'A';
    my $y = $c->param("y") || '1';
    my $name = <<_NAME_;
$map $x-$y 詳細
_NAME_

    my $offset  = $c->param("offset") || 0;
    my $preview = $offset - $MAX_PAGE_SIZE >= 0 ? $offset - $MAX_PAGE_SIZE : undef;
    my $next    = $offset + $MAX_PAGE_SIZE;
    load_monster();

    load_mapdata_by_grid($map, $x,$y,$offset);
#    my $tmp_html = "まだ作ってるの<br />" . sprintf("%s-%s",$x,$y);

# page
    open(BODY, $grid_body_template) || ( printError("Can't open template 2") && die );
    my $body_temp_html = join("",<BODY>);
    close(BODY);

    my $tmp_html = "";
    my $strmap = url_encode($map);

    foreach my $record ( @{$grid_element})
    {
        my $ero = $record->{ero};
        my $st1  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st1}) ) ) );
        my $st2  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st2}) ) ) );
        my $st3  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st3}) ) ) );
        my $st4  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st4}) ) ) );
        my $st5  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st5}) ) ) );
        my $drop = $record->{drop};
        my $gets = $record->{gets};
    eval(
        "\$tmp_html .= <<_HERE_;
$body_temp_html
_HERE_"
    );
    }

    $tmp_html .= '<div style="text-align:center;">';
    if ( $offset != 0 )
    {
        $tmp_html .= <<_HERE_;
<a href="post_map.cgi?view_type=2&amp;view=1&amp;x=$x&amp;y=$y&amp;map=$strmap&amp;offset=$preview">前へ</a>
_HERE_
    }
    else
    {
         $tmp_html .= <<_HERE_;
前へ
_HERE_
    }

    if ( scalar(@{$grid_element}) < $MAX_PAGE_SIZE )
    {
        $tmp_html .= <<_HERE_;
|次へ
_HERE_
    }
    else
    {
        $tmp_html .= <<_HERE_;
|<a href="post_map.cgi?view_type=2&amp;view=1&amp;x=$x&amp;y=$y&amp;map=$strmap&amp;offset=$next">次へ</a>
_HERE_
    }

    $tmp_html .= '</div><br />';


    $base_temp_html =~ s/__TITLE__/$name/g;
    $base_temp_html =~ s/__PAGE_TITLE__/$name/g;
    $base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;

#    $base_temp_html =~ s/__SAVE_MESSAGE__/$_save_message/g;
}



sub view_by_id
{
    my $map = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';
    my $x = $c->param("x") || 'A';
    my $y = $c->param("y") || '1';

    my $id  = $c->param("id") || 0;
    load_monster();

    load_mapdata_by_id($id);
#    my $tmp_html = "まだ作ってるの<br />" . sprintf("%s-%s",$x,$y);

# page
    open(BODY, $grid_body_template) || ( printError("Can't open template 2") && die );
    my $body_temp_html = join("",<BODY>);
    close(BODY);

    my $tmp_html = "";
    my $strmap = url_encode($map);

    foreach my $record ( @{$grid_element})
    {
        my $ero = $record->{ero};
        my $st1  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st1}) ) ) );
        my $st2  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st2}) ) ) );
        my $st3  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st3}) ) ) );
        my $st4  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st4}) ) ) );
        my $st5  = join(",", ( map{$mons_list_name->{$_}} ( split(",", $record->{st5}) ) ) );
        my $drop = $record->{drop};
        my $gets = $record->{gets};
        $map = $record->{"map"};
        $x   = $record->{"x"};
        $y   = $record->{"y"};
    eval(
        "\$tmp_html .= <<_HERE_;
$body_temp_html
_HERE_"
    );
    }

    my $name = <<_NAME_;
$map $x-$y 詳細
_NAME_

    $base_temp_html =~ s/__TITLE__/$name/g;
    $base_temp_html =~ s/__PAGE_TITLE__/$name/g;
    $base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;

#    $base_temp_html =~ s/__SAVE_MESSAGE__/$_save_message/g;
}




sub view_map
{
    my $map = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';
    my $name = <<_NAME_;
$map VIEW
_NAME_

    my $x = $c->param("x") || 'A';
    my $y = $c->param("y") || '1';
    load_monster();
    our $map_monster = { map{ my $x = $_; ( $x => { map { ($_ => {} ) } (1 .. 7) } );  } ( A .. F ) };
    our $monster_map = {};
    load_mapdata_by_monster($map);
# page
    open(BODY, $view_body_template) || ( printError("Can't open template 2") && die );
    my $body_temp_html = join("",<BODY>);
    close(BODY);

    my $tmp_html = "";

    foreach my $tmp_mname_id ( keys %{$monster_map})
    {
        my $tmp_mname = $mons_list_name->{$tmp_mname_id};
        my $tmp_map = { map{ my $x = $_; ( $x => { map { ($_ => '－' ) } (1 .. 7) } );  } ( A .. F ) };
        map { my $x = $_; map{ $tmp_map->{$x}->{$_} = '○'; } keys %{$monster_map->{$tmp_mname_id}->{$x}} } keys %{$monster_map->{$tmp_mname_id}};
    eval(
        "\$tmp_html .= <<_HERE_;
$body_temp_html
_HERE_"
    );
    }


    $base_temp_html =~ s/__TITLE__/$name/g;
    $base_temp_html =~ s/__PAGE_TITLE__/$name/g;
    $base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;

#    $base_temp_html =~ s/__SAVE_MESSAGE__/$_save_message/g;
}


sub view_index
{
    my $view_type = 4;
    my $name = <<_NAME_;
INDEX VIEW
_NAME_
    my $offset  = $c->param("offset") || 0;
    my $preview = $offset - $MAX_INDEX_SIZE >= 0 ? $offset - $MAX_INDEX_SIZE : undef;
    my $next    = $offset + $MAX_INDEX_SIZE;

    my $x = $c->param("x") || 'A';
    my $y = $c->param("y") || '1';
    my $strmap = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';

    load_save_data();



    my $tmp_html = "";
    my $cnt = 0;
    my $precnt = 0;
    foreach my $record ( @{$index_record})
    {
        last if ( $cnt >= $MAX_INDEX_SIZE );
        if ( $offset > $precnt++ )
        {
            next;
        }
#output_log("rec:", $record->[0]));
        $tmp_html .= sprintf("<a href=\"post_map.cgi?view_type=5&amp;view=1&amp;id=%s\">%04d</a>:%s<br/>", $record->{id},$record->{id}, scalar(localtime($record->{timestamp})));
        $cnt++
    }


    $tmp_html .= '<div style="text-align:center;">';
    if ( $offset != 0 )
    {
        $tmp_html .= <<_HERE_;
<a href="post_map.cgi?view_type=$view_type&amp;view=1&amp;x=$x&amp;y=$y&amp;map=$strmap&amp;offset=$preview">前へ</a>
_HERE_
    }
    else
    {
         $tmp_html .= <<_HERE_;
前へ
_HERE_
    }

    if ( $cnt < $MAX_INDEX_SIZE )
    {
        $tmp_html .= <<_HERE_;
|次へ
_HERE_
    }
    else
    {
        $tmp_html .= <<_HERE_;
|<a href="post_map.cgi?view_type=$view_type&amp;view=1&amp;x=$x&amp;y=$y&amp;map=$strmap&amp;offset=$next">次へ</a>
_HERE_
    }

    $tmp_html .= '</div><br />';


    $base_temp_html =~ s/__TITLE__/$name/g;
    $base_temp_html =~ s/__PAGE_TITLE__/$name/g;
    $base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;
}


sub view_by_monster
{
    my $map = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';
    my $name = <<_NAME_;
$map VIEW
_NAME_
    my $mid = $c->param("mname") || 0;

    load_monster();
    our $map_monster = { map{ my $x = $_; ( $x => { map { ($_ => {} ) } (1 .. 7) } );  } ( A .. F ) };
    load_mapdata_by_monster($map, $mid);
# page
    open(BODY, $view_body_template) || ( printError("Can't open template 2") && die );
    my $body_temp_html = join("",<BODY>);
    close(BODY);

    my $tmp_html = "";

    my $tmp_mname_id = $mid;
    my $tmp_mname = $mons_list_name->{$tmp_mname_id};
    my $tmp_map = { map{ my $x = $_; ( $x => { map { ($_ => '－' ) } (1 .. 7) } );  } ( A .. F ) };
    map {
        my $x = $_;
        map {
            my $y = $_;
            $tmp_map->{$x}->{$y} = sprintf(
                '<span style="color:#%s">■</span>',
                $color_map->{
                    int(
                        int(
                            ( ( $monster_map->{$tmp_mname_id}->{$x}->{$y} < 20 ? $monster_map->{$tmp_mname_id}->{$x}->{$y} : 20 ) / 2 )
                        )
                    )
                }
                );
        } keys %{$monster_map->{$tmp_mname_id}->{$x}}
    } keys %{$monster_map->{$tmp_mname_id}};
    eval(
        "\$tmp_html .= <<_HERE_;
$body_temp_html
_HERE_"
    );


    $base_temp_html =~ s/__TITLE__/$name/g;
    $base_temp_html =~ s/__PAGE_TITLE__/$name/g;
    $base_temp_html =~ s/__MESSAGE_BODY__/$tmp_html/g;

#    $base_temp_html =~ s/__SAVE_MESSAGE__/$_save_message/g;
}

sub select_target
{
    my $name = <<_NAME_;
選んでね
_NAME_

    my $map = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';
    my $x = $c->param("x") || 'A';
    my $y = $c->param("y") || '1';
    load_monster();
    our $map_monster = { map{ my $x = $_; ( $x => { map { ($_ => {} ) } (1 .. 7) } );  } ( A .. F ) };
#    load_mapdata_by_monster($map);
# page


    my %_t = (
        x => getOptionTag( $x, [A .. F] ),
        y => getOptionTag( $y, [1 .. 7] ),
    );

    open(BODY, $select_body_template) || ( printError("Can't open template 2") && die );
    my $body_temp_html = join("",<BODY>);
    close(BODY);

    my $tmp_html = "";

    my $_monster_list = sprintf('<option value="0">--選んでね--</option>');
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

#    $base_temp_html =~ s/__SAVE_MESSAGE__/$_save_message/g;
}



sub post_map
{
    my @save_rec;

    my $name = <<_NAME_;
MAP DATABASE
_NAME_

    my $id   = $c->param("id")   || undef ;
    if ( $id eq "" )
    {
        $id = undef;
    }

    my $map = $c->param("map") || 'ｼｱﾌｨｰﾙ平原';
    push(@save_rec, sprintf("ＭＡＰ：&nbsp;%s", $map));
    my $x = $c->param("x") || 'A';
    my $y = $c->param("y") || '1';
    push(@save_rec, sprintf("座標&nbsp;&nbsp;：&nbsp;%s-%s", $x, $y ));

    my %_t = (
        'map' => getOptionTag( $map, $map_map ),
        x => getOptionTag( $x, [A .. F] ),
        y => getOptionTag( $y, [1 .. 7] ),
    );




    my $ero = $c->param("ero") || "";
    strOptimize(\$ero);
    push(@save_rec, sprintf("侵食率:&nbsp;%s", $ero));

    my $st1 = $c->param("st1") || "";
    my $st2 = $c->param("st2") || "";
    my $st3 = $c->param("st3") || "";
    my $st4 = $c->param("st4") || "";
    my $st5 = $c->param("st5") || "";

    strOptimize(\$st1);
    push(@save_rec, sprintf("ｽﾃｯﾌﾟ1：&nbsp;%s", $st1));
    strOptimize(\$st2);
    push(@save_rec, sprintf("ｽﾃｯﾌﾟ2：&nbsp;%s", $st2));
    strOptimize(\$st3);
    push(@save_rec, sprintf("ｽﾃｯﾌﾟ3：&nbsp;%s", $st3));
    strOptimize(\$st4);
    push(@save_rec, sprintf("ｽﾃｯﾌﾟ4：&nbsp;%s", $st4));
    strOptimize(\$st5);
    push(@save_rec, sprintf("ｽﾃｯﾌﾟ5：&nbsp;%s", $st5));


    my $st  = {
        1 => $st1,
        2 => $st2,
        3 => $st3,
        4 => $st4,
        5 => $st5,
    };

    my $drop = $c->param("drop") || "";
    my $gets = $c->param("gets") || "";

    strOptimize(\$drop);
    push(@save_rec, sprintf("ﾄﾞﾛｯﾌﾟ：&nbsp;%s", $drop));
    strOptimize(\$gets);
    push(@save_rec, sprintf("採取掘：&nbsp;%s", $gets));

#my $type = { map { ( $_ => ( $c->param($_) || 0 ) ) } (1 .. 14)  };



# Load Monster
    load_monster();


    my $cd = {};
    my $_save_message = "";

    if ($c->param("saved") )
    {
# monster index.
        foreach my $i  ( 1 .. 5 )
        {
            if ( $st->{$i} ne "" )
            {
                my @ml = split( ",", $st->{$i} );
                warn join("/",@ml);
                my @replace;
                foreach my $m ( @ml )
                {
                    if ( not exists $mons_list->{$m} )
                    {
                        my $mid = auto_increment($li_mons);
                        if ( $mid <= 0 )
                        {
                            printError("Can't get next monster id!") && die;
                        }

                        if ( $mid > 0)
                        {
                            open(SAVEMONS, ">>$mons_index") || ( printError("Can't write Monster Indexfile") && die);
                            printf SAVEMONS "%s\n", join("\t", ($mid,$m ) );
                            close(SAVEMONS);
                            $mons_list->{$m} = $mid;
                        }
                    }
                    push(@replace, $mons_list->{$m});
                }
                $cd->{$i} = join(",",@replace);
            }
            else
            {
                warn '$st->{$i} is ""'
            }
        }



        if ( not defined $id  )
        {
            # New Id
            $id = auto_increment($last_index);
            if ( $id <= 0 )
            {
                printError("Can't get next id!") && die;
            }
        }

# save

        if ( $id > 0)
        {
            open(SAVE, ">>$map_data") || ( printError("Can't write template") && die);
            printf SAVE "%s\n", join("\t", ($id,time(),$map, $x,$y,$ero,$cd->{1},$cd->{2},$cd->{3},$cd->{4},$cd->{5},$drop,$gets ) );
            close(SAVE);
        }

        unshift(@save_rec,"以下のﾃﾞｰﾀを保存しますた" );
        $_save_message = join("<br/>\r\n", @save_rec);
    }



# page
    open(TEMP, $base_template) || ( printError("Can't open template 1") && die);
    $base_temp_html = join("",<TEMP>);
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

    $base_temp_html =~ s/__SAVE_MESSAGE__/$_save_message/g;



}


sub load_mapdata_by_id
{
    my $id = shift;
    open MAP, "$map_data";
    while(<MAP>)
    {
        my @line = split(/\t/);
        my $record = {};
        if ($line[0] eq $id )
        {
            $record = {
                "map"=> $line[2],
                x    => $line[3],
                y    => $line[4],
                ero  => $line[5],
                st1  => $line[6],
                st2  => $line[7],
                st3  => $line[8],
                st4  => $line[9],
                st5  => $line[10],
                drop => $line[11],
                gets => $line[12]
            };
            push(@{$grid_element}, $record);
        }

    }
    close MAP;
}

sub load_mapdata_by_grid
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $offset = shift;
    my $cnt = 0;
    my $precnt = 0;
    open MAP, "$map_data";
    if ( $x && $y )
    {
        while(<MAP>)
        {
            last if ( $cnt >= $MAX_PAGE_SIZE );
            my @line = split(/\t/);
            my $record = {};
            if ($line[2] eq $map && $line[3] eq $x && $line[4] eq $y )
            {
                if ( $offset > $precnt++ )
                {
                    next;
                }
                $record = {
                    ero  => $line[5],
                    st1  => $line[6],
                    st2  => $line[7],
                    st3  => $line[8],
                    st4  => $line[9],
                    st5  => $line[10],
                    drop => $line[11],
                    gets => $line[12]
                };
#                map{ $lm->{$_}++ } (split(/,/,$line[6]),split(/,/,$line[7]),split(/,/,$line[8]),split(/,/,$line[9]),split(/,/,$line[10]));
                push(@{$grid_element}, $record);
                $cnt++;
            }

        }
    }
    close MAP;
}

sub load_mapdata_by_monster
{
    my $map = shift;
    my $target_id = shift;
    open MAP, "$map_data";
    if ( $target_id )
    {
        while(<MAP>)
        {
            my @line = split(/\t/);
            my $lm = {};
            if ($line[2] eq $map)
            {
                map{ $lm->{$_}++ } (split(/,/,$line[6]),split(/,/,$line[7]),split(/,/,$line[8]));
            }

            next if (not exists $lm->{ $target_id });
            map {
                $map_monster->{$line[3]}->{$line[4]}->{$_} += $lm->{$_};
                $monster_map->{$_}->{$line[3]}->{$line[4]} += $lm->{$_};
                $monster_map->{$_}->{ALL} += $lm->{$_};
            } keys %{$lm};
        }
    }
    else
    {
        while(<MAP>)
        {
            my @line = split(/\t/);
            my $lm = {};
            if ($line[2] eq $map)
            {
                map{ $lm->{$_}++ } (split(/,/,$line[6]),split(/,/,$line[7]),split(/,/,$line[8]),split(/,/,$line[9]),split(/,/,$line[10]));
#                map{ $lm->{$_}++ } (split(/,/,$line[6]),split(/,/,$line[7]),split(/,/,$line[8]));
            }
            map {
                $map_monster->{$line[3]}->{$line[4]}->{$_} += $lm->{$_};
                $monster_map->{$_}->{$line[3]}->{$line[4]} += $lm->{$_};
                $monster_map->{$_}->{ALL} += $lm->{$_};
            } keys %{$lm};
        }
    }
    close MAP;
}

sub load_save_data
{
    open MAP, "$map_data";
    while(<MAP>)
    {
        my @line = split(/\t/);
        unshift(@{$index_record}, {id => $line[0], timestamp => $line[1] } );
    }
    close MAP;
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

sub load_monster
{
    open MONS, "$mons_index";
#    $mons_list = { map{chomp;my( $idx, $mname ) = (split(/\t/,$_));($mname => $idx)} (<MONS>) };
    while(<MONS>)
    {
        chomp;
        my( $idx, $mname ) = (split(/\t/,$_));
        $mons_list->{$mname} = $idx;
        $mons_list_name->{$idx} = $mname 
    }
    close MONS;
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
    $$str =~ s/(、|､|｡)/,/g;
}

sub url_encode($)
{
    my $str = shift;
    $str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
    $str =~ tr/ /+/;
    return $str;
}
