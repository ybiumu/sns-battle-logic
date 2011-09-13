#!/usr/local/bin/perl
use CGI;


my $system_log = "../../../.htlog/calc.log";

my $lines = 0;
my $line_num = 500;
my $c = new CGI();

my $target_line = $c->param("ln") or 0;
my $buffer = "";
my @store_lines;
my $rf = 0;

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
<head><title>systool - al</title></head>
<body>
_HEADER_

printf "line: %s<br />\n", $lines;

foreach my $line ( @store_lines )
{
    printf "%s<br />\n", $line;
}

print <<_FOOTER_
</body>
</html>
_FOOTER_
