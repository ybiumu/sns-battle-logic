#!/usr/local/bin/perl


use lib qw( .. );
use CGI;

my $dp = "../../data";
my $p  = "$dp/copipe";
my $c  = new CGI();

my $self = "index.cgi";
my $nm = $c->param("nm");

print $c->header(
    -type => "text/html",
    -charset=>"Shift_JIS"
);
print <<_HTML_;
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=Shift_JIS">
    <title>コピペ</title>
  </head>
  <body>
_HTML_
if ( $nm =~ /^\d\d\d$/ )
{
    my $f = sprintf "%s.txt", $nm;
    open OP, "$p/$f";
    my $header = <OP>;
    chomp($header);
    printf "<textarea>\r\n";
    while(<OP>)
    {
        printf "%s", $_;
    }
    printf "</textarea>\r\n";
    close OP;

}
else
{
    opendir(DIR, $p);
    while( my $f = readdir(DIR) )
    {
        if ( -f "$p/$f")
        {
            open OP, "$p/$f";
            my $header = <OP>;
            chomp($header);
            close OP;
            my $on = ($f =~ /(\d\d\d)/)[0];
            printf( qq[<a href="%s?nm=%s">%s</a><br />\r\n], $self, $on, $header );
        }
    }
    closedir(DIR);
}



print $c->end_html();
