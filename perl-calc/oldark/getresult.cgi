#!/usr/local/bin/perl

use lib qw( .. );
use CGI;

my $c = new CGI();

my $lv = $c->param("lv");
my $nm = $c->param("nm");

#print $c->header( -type=> "text/xml", -charset=>"Shift_JIS" );

my $doc_type = {
    d => {
            dt => q[<?xml version="1.0" encoding="Shift_JIS"?>\n<!DOCTYPE html PUBLIC "-//i-mode group (ja)//DTD XHTML i-XHTML(Locale/Ver.=ja/1.1) 1.0//EN" "i-xhtml_4ja_10.dtd">],
            ct => q[]
         },
    s => { dt => "", ct => "" },
    k => {
            dt => qq[<?xml version="1.0" encoding="Shift_JIS"?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">],
            ct => q[Content-type: application/xhtml+xml;],
         } ,
};


print <<_HEADER_;
Content-type: application/xhtml+xml;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
  <head><title>Results</title></head>
   <body>
_HEADER_


#print $c->start_html(
#    -title => "Results",
#    -lang => "ja"
#);

print
    "Name: $nm",
    $c->br(),
    "Lv: $lv",
    ;


print $c->end_html();
