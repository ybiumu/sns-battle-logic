#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use YAML::Tiny;
use Net::Twitter::Lite;
use CGI;
use DbUtil;
use LocalConfig;


my $db = DbUtil::getDbHandler();
use CGI::Session;

my $cgi = new CGI;
my $session = new CGI::Session(undef, undef, {Directory=>'/home/users/2/ciao.jp-anothark/web/.htsession'});
$session->expire('+1h');

############
### Main ###
############
use strict;
use warnings;
use Encode;

my $oauth_verifier = $cgi->param('oauth_verifier');

#my $yaml = (YAML::Tiny->read('/home/users/2/ciao.jp-anothark/web/.htlib/twconf.yml'));
my $config = ( YAML::Tiny->read('/home/users/2/ciao.jp-anothark/web/.htcron/twconf.yml') )->[0];
#my $config = ( YAML::Tiny->read('twconf.yml') )->[0];
#my $config = $yaml->[0];
my $twit = Net::Twitter::Lite->new(
    consumer_key    => $config->{'cs_key'},
    consumer_secret => $config->{'cs_secret'},
    ssl => 1,
    legacy_lists_api => 1,
    # For twitter api v1.1
    apiurl                => 'http://api.twitter.com/1.1',
    search_trends_api_url => 'http://api.twitter.com/1.1',
    lists_api_url         => 'http://api.twitter.com/1.1'
);



$twit->request_token($cgi->cookie('token'));
$twit->request_token_secret($cgi->cookie('token_secret'));
my($access_token, $access_token_secret, $user_id, $screen_name) = $twit->request_access_token(verifier => $oauth_verifier);


$session->param(-name=>'access_token', -value=>$access_token);
$session->param(-name=>'access_token_secret', -value=>$access_token_secret);
$session->param(-name=>'user_id', -value=>$user_id);
$session->param(-name=>'screen_name', -value=>$screen_name);
$session->param(-name=>'pattern', -value=>"twauth");

my $cookie = CGI::Cookie->new(-name => 'CGISESSID',
                             -value => $session->id(),
                             -expires => '+1h',
                             -path => '/sp'
                             );

print $cgi->header(
  -cookie=>$cookie,
  -location => $LocalConfig::BASE_URL . "/sp/mypage.cgi"
);


$db->disconnect();
exit;

