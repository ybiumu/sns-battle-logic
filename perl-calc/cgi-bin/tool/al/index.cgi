#!/usr/local/bin/perl
use CGI;

my $log_dir  = "../../../.htlog";
my $log_list = [
    { label => "calc"    , file => "calc.log" },
    { label => "gn"      , file => "gn_post_map.log" },
    { label => "howmany" , file => "howmany_loop.log" },
    { label => "overlap" , file => "overlap_effect.log" },
];

my $lines = 0;
my $line_num = 500;
my $c = new CGI();

my $target_line = $c->param("ln") or 0;
my $target_log  = $c->param("tl") or 0;
my $buffer = "";
my @store_lines;
my $rf = 0;

#my $system_log = "../../../.htlog/calc.log";
my $system_log = sprintf("%s/%s", $log_dir,$log_list->[$target_log]->{file} );

open(FILE, $system_log) or die "Can't open $system_log: $!";
while( <FILE> )
{
    if ( $lines == $target_line )
    {
        $rf = 1;
    }

    if ( $lines >= ( $target_line + $line_num ))
    {
        $rf = 0;
    }

    if ( $rf )
    {
        chomp;
        push( @store_lines, $_ );
    }

    $lines++;
}

#while (sysread FILE, $buffer, 4096)
#{
#    $pre_buffer = $buffer;
#    $lines += ($buffer =~ tr/\n//);
#    if ( $lines == $target_line )
#    {
#    }
#    elsif ()
#    {
#    }
#}
#
close(FILE);



print <<_HEADER_;
Content-type: text/html;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">

<html>
<head><title>systool - al - label: $log_list->[$target_log]->{label}</title></head>
<body style="color:#000000;background-color:#FFEFB2;font-size:x-small;">
_HEADER_

printf "line: %s<br />\n", $lines;
printf "label: %s<br />\n",$log_list->[$target_log]->{label};

foreach my $line ( @store_lines )
{
    printf "%s<br />\n", $line;
}

print <<_FOOTER_
</body>
</html>
_FOOTER_
