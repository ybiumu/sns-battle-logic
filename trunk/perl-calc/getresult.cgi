#!/usr/local/bin/perl

use lib qw( .. );
use CGI;

my $c = new CGI();

my $lv = $c->param("lv");
my $nm = $c->param("nm");

print $c->header( -charset=>"Shift_JIS" );

print $c->start_html(
    -title => "Results"
);

print
    "Name: $nm",
    $c->br(),
    "Lv: $lv",
    ;


print $c->end_html();
