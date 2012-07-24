package AaTemplate;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );


my $base = undef;
my $body = undef;
my $base_html = undef;
my $body_html = undef;
my $page_util = undef;
my $out = {};

my $ad_str = undef;
my $page_name = "No Name";


sub init
{
    my $class = shift;
    $class->setPageName($page_name);
}


sub setAdStr
{
    my $class = shift;
    return $class->setAttribute( 'ad_str', shift );
}

sub getAdStr
{
    return $_[0]->getAttribute( 'ad_str' );
}


sub setPageName
{
    my $class = shift;
    return $class->setAttribute( 'page_name', shift );
}

sub getPageName
{
    return $_[0]->getAttribute( 'page_name' );
}


sub setOut
{
    my $class = shift;
    return $class->setAttribute( 'out', shift );
}

sub getOut
{
    return $_[0]->getAttribute( 'out' );
}

sub setPageUtil
{
    my $class = shift;
    return $class->setAttribute( 'page_util', shift );
}

sub getPageUtil
{
    return $_[0]->getAttribute( 'page_util' );
}

sub setBodyHtml
{
    my $class = shift;
    return $class->setAttribute( 'body_html', shift );
}

sub getBodyHtml
{
    return $_[0]->getAttribute( 'body_html' );
}

sub setBaseHtml
{
    my $class = shift;
    return $class->setAttribute( 'base_html', shift );
}

sub getBaseHtml
{
    return $_[0]->getAttribute( 'base_html' );
}

sub setBody
{
    my $class = shift;
    return $class->setAttribute( 'body', shift );
}

sub getBody
{
    return $_[0]->getAttribute( 'body' );
}

sub setBase
{
    my $class = shift;
    return $class->setAttribute( 'base', shift );
}

sub getBase
{
    return $_[0]->getAttribute( 'base' );
}


sub setup
{
    my $class = shift;
    $class->loadBaseHtml();
    $class->loadBodyHtml();


    my $out = $class->getOut();

    my $tmp_html;
eval(
    "\$tmp_html = <<_HERE_;
$class->{body_html}
_HERE_"
);
    my $page_name = $class->getPageName();
    my $ad_str    = $class->getAdStr();

    $class->{base_html} =~ s/__TITLE__/$page_name/g;
    $class->{base_html} =~ s/__PAGE_TITLE__/$page_name/g;
    $class->{base_html} =~ s/__MESSAGE_BODY__/$tmp_html/g;
    $class->{base_html} =~ s/__ADD_SPACE__/$ad_str/g;
}

sub output
{
    my $class = shift;
    my $ct = $class->getPageUtil()->getContentType();
    print <<_HEADER_;
Content-type: $ct;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_

    print $class->getBaseHtml();
}

sub loadBaseHtml
{
    my $class = shift;
    open(TEMP, $class->getBase()) || ( $class->getPageUtil()->printError("Can't open template 1") && exit);
    $class->setBaseHtml( join("",<TEMP>) );
    close(TEMP);
}

sub loadBodyHtml
{
    my $class = shift;

    open(BODY, $class->getBody()) || ( $class->getPageUtil()->printError("Can't open template 2") && exit );
    $class->setBodyHtml( join("",<BODY>) );
    close(BODY);


}


1;
