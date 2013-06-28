#!/usr/bin/perl

#use lib qw( .htlib ../.htlib );
use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );
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
my @wday_part = ( 'pSun', 'pMon', 'pTue', 'pWed', 'pThu', 'pFri', 'pSat');
my $drop_part_sql_format = "ALTER TABLE t_result_log DROP PARTITION %s";
my $add_part_sql_format  = "ALTER TABLE t_result_log ADD PARTITION (PARTITION %s VALUES IN (%s) ENGINE = MyISAM)";
my $target_wday = (localtime(time + (86400 * $interval)))[6];

my $drop_part_sql = sprintf( $drop_part_sql_format, $wday_part[$target_wday] );
my $add_part_sql = sprintf( $add_part_sql_format, $wday_part[$target_wday],$target_wday );

my $part_sth = $db->prepare( $drop_part_sql );
$pu->output_log( $part_sth->execute() );
$part_sth->finish();


my $part_sth2 = $db->prepare( $add_part_sql );
$pu->output_log( $part_sth2->execute() );
$part_sth2->finish();


$db->disconnect();

$pu->output_log("End batch.");
printf "[%s] end batch\n", scalar(localtime());





exit;

