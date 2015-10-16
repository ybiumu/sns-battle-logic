#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use LocalConfig;
use LoggingObjMethod;


my $db = DbUtil::getDbHandler();
my $log = new LoggingObjMethod();
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




$session->param(-name=>'user_id', -value=>"sb000001");
$session->param(-name=>'pattern', -value=>"sandbox");

my $cookie = CGI::Cookie->new(-name => 'CGISESSID',
                             -value => $session->id(),
                             -expires => '+6h',
                             -path => '/sp'
                             );

$log->warning("[callback.cgi] redirect $LocalConfig::BASE_URL/sp/mypage.cgi");
$log->warning("[callback.cgi] set cookie $cookie");
print $cgi->header(
  -cookie=>$cookie,
  -location => $LocalConfig::BASE_URL . "/sp/mypage.cgi"
);


$db->disconnect();
exit;

