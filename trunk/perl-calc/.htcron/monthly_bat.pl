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
my $mu = new MobileUtil({ is_batch => "1"});

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


# Init check





$pu->output_log("Start monthly batch.");
printf "[%s] start monthly batch\n", scalar(localtime());


my $interval = 11;



############
### Main ###
############
#my $drop_part_sql_format = "ALTER TABLE t_boards DROP PARTITION %s";
my $add_part_sql_format  = "ALTER TABLE t_boards ADD PARTITION (PARTITION p%s VALUES IN (%s) ENGINE = MyISAM)";
my ($cy,$cm) = (localtime())[5,4];

$cy += 1900;
$cm += 1;

if ( ( $cm+=$interval ) > 12 )
{
    $cy++;
    $cm = $cm % 12;
}

my $append_ym = sprintf("%04s%02s", $cy, $cm);

#my $drop_part_sql = sprintf( $drop_part_sql_format, $wday_part[$target_wday] );
my $add_part_sql = sprintf( $add_part_sql_format, $append_ym, $append_ym );

#my $part_sth = $db->prepare( $drop_part_sql );
#$pu->output_log( $part_sth->execute() );
#$part_sth->finish();

#printf "%s\n", $add_part_sql;

my $part_sth2 = $db->prepare( $add_part_sql );
$pu->output_log( $part_sth2->execute() );
$part_sth2->finish();


$db->disconnect();

$pu->output_log("End monthly batch.");
printf "[%s] end monthly batch\n", scalar(localtime());





exit;

