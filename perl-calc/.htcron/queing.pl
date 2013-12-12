#!/usr/bin/perl

#use lib qw( .htlib ../.htlib );
use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use PageUtil;
use AaTemplate;
#use Anothark::Battle;
#use Anothark::Battle::Exhibition;
#use Anothark::Character;
#use Anothark::Skill;

use Anothark::QueingBase;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);

$pu->setBoth(1);

my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil({ is_batch => "1"});

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



my $hour = sprintf "%02s", (localtime())[2];
if ( scalar(@ARGV) && $ARGV[0] =~ /^([01][0-9]|2[0-3])$/  )
{
    $hour = sprintf "%02s", $ARGV[0]
}

$pu->notice("Start que at `$hour'.");




############
### Main ###
############

# ¡‚ÌŽžŠÔ‚Éˆ—‚·‚éƒ†[ƒU[‚ÌŒŸõ
my $select_users = "SELECT user_id FROM t_selection_que JOIN t_user USING(user_id) WHERE queing_hour = ? AND qued = 0 AND delete_flag = 0";
my $su_sth = $db->prepare( $select_users );
$pu->notice( "query status is " . $su_sth->execute(( $hour )) );

my $rs_row  = $su_sth->fetchall_arrayref();
if ( ! $su_sth->rows() > 0 )
{
    $su_sth->finish();
    $db->disconnect();
    $pu->notice(" QUEING: No target exists.");
    exit;
}
else
{
    $pu->notice(" QUEING: ". $su_sth->rows() ." targets exists.");
}

$su_sth->finish();


my $qb = new Anothark::QueingBase($at);

$qb->openMainSth();
my $queing_status = $qb->doQueing($rs_row);
$qb->finishMainSth();


$db->disconnect();

exit;

