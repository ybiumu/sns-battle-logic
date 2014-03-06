package UniversalAnalytics;
#
# ˆ¤
#
#
#use URI::Escape;
use Encode;
use LWP::UserAgent;

use constant TID => "UA-48583017-1";

sub gen_uuid
{
    return sprintf(
                "%04x%04x-%04x-%04x-%04x-%04x%04x%04x", 
                rand(0xffff),rand(0xffff),
                rand(0xffff),
                rand(0x0fff) | 0x4000,
                rand(0x3fff ) | 0x8000,
                rand(0xffff),rand(0xffff),rand(0xffff)
           );
}

sub report
{
    my $at = shift;
    my $data = { # This is an associative array that will contain all the parameters that we'll send to Google Analytics
        'v'   => 1, # The version of the measurement protocol
        'tid' => TID, # Google Analytics account ID (UA-98765432-1)
#        'cid' => gen_uuid(), # The UUID
        'cid' => $at->{out}->{UUID} || gen_uuid(), # The UUID
        't'   => 'pageview' # Hit Type
    };

    $data->{'dh'} = "ciao.jp"; # The domain of the site that is associated with the Google Analytics ID
    #$data->{'dl'} = ($c->param('path') ? $c->param('path') : ""); # The landing page
#    $data->{'dr'} = uri_escape($ENV{'HTTP_REFERER'}); # The URL of the site that is sending the visit. Format: http%3A%2F%2Fexample.com
#    $data->{'dp'} = uri_escape($ENV{'REQUEST_URI'}); # The page that will receive the pageview
#    $data->{'dt'} = uri_escape($at->getPageName()); # The title of the page that receives the pageview. In my case, this is a "virtual" page. So, I'm passing the title through the URL.
#    $data->{'dr'} = urlenc($ENV{'HTTP_REFERER'}); # The URL of the site that is sending the visit. Format: http%3A%2F%2Fexample.com
#    $data->{'dp'} = urlenc($ENV{'REQUEST_URI'}); # The page that will receive the pageview
#    $data->{'dt'} = urlenc($at->getPageName()); # The title of the page that receives the pageview. In my case, this is a "virtual" page. So, I'm passing the title through the URL.


    $data->{'dr'} = $ENV{'HTTP_REFERER'}; # The URL of the site that is sending the visit. Format: http%3A%2F%2Fexample.com
    $data->{'dp'} = $ENV{'REQUEST_URI'}; # The page that will receive the pageview
    $data->{'dt'} = $at->getPageName(); # The title of the page that receives the pageview. In my case, this is a "virtual" page. So, I'm passing the title through the URL.
    Encode::from_to($data->{'dt'} ,"shiftjis","utf8"); # The title of the page that receives the pageview. In my case, this is a "virtual" page. So, I'm passing the title through the URL.

    #$data->{'cs'} = ($c->param('utm_source') ? $c->param('utm_source') : ""); # The source of the visit (e.g. google)
    #$data->{'cm'} = ($c->param('utm_medium') ? $c->param('utm_medium') : ""); # The medium (e.g. cpc)
    #$data->{'cn'} = ($c->param('utm_campaign') ? $c->param('utm_campaign') : ""); # The name of the campaign
    #$data->{'ck'} = ($c->param('utm_term') ? $c->param('utm_term') : ""); # The keyword that the user searched for
    #$data->{'cc'} = ($c->param('utm_content') ? $c->param('utm_content') : ""); # Used to differentiate ads or links that point to the same URL.



    my $url = 'http://www.google-analytics.com/collect'; # This is the URL to which we'll be sending the post request.
    $user_agent = $ENV{'HTTP_USER_AGENT'}; # Throwing in a user agent just for good measure.


#    $at->debug(sprintf("[UALOG] %s", join( "&",map { sprintf "%s=%s", $_, $data->{$_} } keys %{$data})));
    map { $at->debug(sprintf("[UALOG] %s=%s", $_, $data->{$_} ) ); } keys %{$data};

    my $google_ua = LWP::UserAgent->new( agent => $user_agent );
    my $google_ua_output = $google_ua->post($url, $data);
    $at->debug("[UALOG] post done [%s]", $google_ua_output );

}

sub urlenc
{
    my $str = shift;
    $str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
    $str =~ tr/ /+/;
    return $str;
}
1;
