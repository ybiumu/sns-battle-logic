#!/usr/local/bin/perl

#use lib qw( .htlib ../.htlib );
use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );
use YAML::Tiny;
use Net::Twitter::Lite;
use DbUtil;
use MobileUtil;
use PageUtil;
use AaTemplate;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


# Init check





$pu->output_log("Start batch.");
printf "[%s] start batch\n", scalar(localtime());


my $interval = 2;



############
### Main ###
############
use strict;
use warnings;
use Encode;

#my $yaml = (YAML::Tiny->read('/home/users/2/ciao.jp-anothark/web/.htlib/twconf.yml'));
my $config = ( YAML::Tiny->read('twconf.yml') )->[0];
#my $config = $yaml->[0];
my $twit = Net::Twitter::Lite->new( consumer_key => $config->{'cs_key'}, consumer_secret => $config->{'cs_secret'}, legacy_lists_api => 1 );
$twit->access_token( $config->{'ac_token'} );
$twit->access_token_secret( $config->{'ac_secret'} );

my $format = "現在のﾃｽﾄ参加者数は%s人ﾆｬ";
my $select_sql = "SELECT COUNT(*) AS c FROM t_user";
my $part_sth = $db->prepare( $select_sql );
my $query_result = $part_sth->execute();
#warn "[QR] query_result";
my $r = $part_sth->fetchrow_hashref();
my $string = sprintf($format, $r->{c});
$part_sth->finish();

#warn "$string";

my $result = $twit->update( { status => decode( 'utf8', $string ) } );


$db->disconnect();

$pu->output_log("End batch.");
printf "[%s] end batch\n", scalar(localtime());





exit;
