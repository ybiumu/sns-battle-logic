package Anothark::QueingUtil;
#
# ˆ¤
#
$|=1;
use strict;
use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use PageUtil;
use AaTemplate;
use Anothark::QueingBase;

sub hourlyQueing
{
    my $flag = shift || 0;
    my $pu = new PageUtil();
    my $at = new AaTemplate();
    $at->setPageUtil($pu);

    $pu->setBoth($flag);

    my $db = DbUtil::getDbHandler();
    my $mu = new MobileUtil();

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

# ¡‚ÌŠÔ‚Éˆ—‚·‚éƒ†[ƒU[‚ÌŒŸõ
    my $select_users = "SELECT user_id FROM t_selection_que WHERE queing_hour = ? AND qued = 0";
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

    return $at;
}

1;
