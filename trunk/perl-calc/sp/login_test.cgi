#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use YAML::Tiny;
use Net::Twitter::Lite;
use CGI;
use LocalConfig;


#my $db = DbUtil::getDbHandler();
#use CGI::Session;

my $cgi = new CGI;

############
### Main ###
############
use strict;
use warnings;
use Encode;

#my $yaml = (YAML::Tiny->read('/home/users/2/ciao.jp-anothark/web/.htlib/twconf.yml'));
my $config = ( YAML::Tiny->read('/home/users/2/ciao.jp-anothark/web/.htcron/twconf.yml') )->[0];
#my $config = ( YAML::Tiny->read('twconf.yml') )->[0];
#my $config = $yaml->[0];
#my $twit = Net::Twitter::Lite->new(
my $twit = Net::Twitter::Lite->new(
    consumer_key    => $config->{'cs_key'},
    consumer_secret => $config->{'cs_secret'},
    legacy_lists_api => 1,
    # For twitter api v1.1
    apiurl                => 'http://api.twitter.com/1.1',
    search_trends_api_url => 'http://api.twitter.com/1.1',
    lists_api_url         => 'http://api.twitter.com/1.1'
);

#2#my $auth_url = $twit->get_authorization_url( callback => $LocalConfig::BASE_URL . '/sp/callback.cgi' );



my $auth_url = "";
eval {
    $twit->{oauth_urls}->{request_token_url}  = "https://api.twitter.com/oauth/request_token";
    $twit->{oauth_urls}->{authentication_url} = "https://api.twitter.com/oauth/authenticate";
    $twit->{oauth_urls}->{authorization_url}  = "https://api.twitter.com/oauth/authorize";
    $twit->{oauth_urls}->{access_token_url}   = "https://api.twitter.com/oauth/access_token";
    $twit->{oauth_urls}->{xauth_url}          = "https://api.twitter.com/oauth/access_token";
    $auth_url = $twit->get_authorization_url( callback => $LocalConfig::BASE_URL . '/sp/callback.cgi' );
};

my $err_msg = "";

if ($@)
{
    $err_msg = $@;
}


printf "Set-Cookie: %s\n", $cgi->cookie( -name => 'token', -value => $twit->request_token, -path => '/sp') ;
printf "Set-Cookie: %s\n", $cgi->cookie( -name => 'token_secret', -value => $twit->request_token_secret, -path => '/sp') ;
print $cgi->redirect(-uri => $auth_url);

#printf "Content-Type: text/html\n\n";
#printf "error: %s\n", $err_msg;

exit;

