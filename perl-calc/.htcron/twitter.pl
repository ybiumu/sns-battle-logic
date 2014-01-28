#!/usr/bin/perl
##!/usr/local/bin/perl

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
my $mu = new MobileUtil({ is_batch => "1"});

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
$twit->access_token( $config->{'ac_token'} );
$twit->access_token_secret( $config->{'ac_secret'} );

my $random_info = {
    0 => {
        format => '登録ｽｷﾙ数は%sﾆｬ!',
        sql    => "SELECT COUNT(*) AS c2 FROM t_skill_master",
    },
    1 => {
        format => '登録ｱｲﾃﾑ数は%sﾆｬ!',
        sql    => "SELECT COUNT(*) AS c2 FROM t_item_master",
    },
    2 => {
        format => '登録ﾉｰﾄﾞ数は%sﾆｬ!',
        sql    => "SELECT COUNT(*) AS c2 FROM t_node_master",
    },
    3 => {
        format => '登録ﾘｻﾞﾙﾄ数は%sﾆｬ!',
        sql    => "SELECT COUNT(*) AS c2 FROM t_result_master",
    },
    4 => {
        format => '登録ﾓﾝｽﾀｰ数は%sﾆｬ!',
        sql    => "SELECT COUNT(*) AS c2 FROM t_monster_master",
    },
};

my $msg_map = {
    0  => '全然ﾀﾞﾒだﾆｬ…',
    1  => '無いよりﾏｼだﾆｬ。',
    5  => 'もう少し頑張って欲しいﾆｬ!',
    10 => '見れうようになってきたﾆｬ。',
    30 => '充実してきたﾆｬ!',
    70 => '十分楽しめるﾆｬ!',
 99999 => '全部お目にかかれるかﾆｬ?',
};

my $format = '%s現在のﾃｽﾄ参加者数は%s人ﾆｬ!%s%s';
my @dt     = localtime;
my $dtstr  = sprintf('%s年%s月%s日', $dt[5]+1900, $dt[4]+1, $dt[3]);
my $select_sql = "SELECT COUNT(*) AS c FROM t_user";
my $part_sth = $db->prepare( $select_sql );
my $query_result = $part_sth->execute();
#warn "[QR] query_result";
my $r = $part_sth->fetchrow_hashref();

my $rand = int(rand(5));
my $rand_sth = $db->prepare( $random_info->{$rand}->{sql} );
my $rand_result = $rand_sth->execute();
#warn "[QR] query_result";
my $r2 = $rand_sth->fetchrow_hashref();
my $string = sprintf(
    $format,
    $dtstr,
    $r->{c},
    sprintf($random_info->{$rand}->{format}, $r2->{c2}),
    $msg_map->{(sort { $b <=> $a } grep { $_ <= $r2->{c2}} ( keys %{$msg_map} ))[0]});
$part_sth->finish();
$rand_sth->finish();

#warn "$string";
$pu->output_log(sprintf( "%s", $string));

my $result = "";
eval {
    $result = $twit->update( { status => decode( 'utf8', $string ) } );
};

my $err_msg = "";

if ($@)
{
    $err_msg = $@;
    $pu->warning("[login.cgi] Auth failure.:$err_msg");
}


$db->disconnect();

$pu->output_log("End batch.");
printf "[%s] end batch\n", scalar(localtime());





exit;
