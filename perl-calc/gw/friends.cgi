#!/usr/bin/perl
#
# ˆ¤
#
############
### LOAD ###
############
use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::FollowingManager;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();


##################
### init check ###
##################
my $result = $at->setupBaseData();
if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


my @oddeven = ( "odd", "even" );

our $page_id  = $c->param("p") || 0;
our $last_user_id = $c->param("lui") || 0;

our $out = $at->getOut();

##############
### depend ###
##############
$at->setBody("body_friends.html");
$at->setPageName('—F’Bˆê——');
my $version = "0.1a20130415";
my $fm = new Anothark::FollowingManager( $db );



############
### Main ###
############

$out->{FRIENDS} = "";
my $my_user_id = $out->{USER_ID};
my $users = $fm->getFriendList( $my_user_id, $last_user_id );
my $lines = 0;
foreach my $u ( @{$users} )
{
    $out->{FRIENDS} .= sprintf(
        qq|<div class="item_%s">%s%s<br />[<a href='mypage.cgi?user_id=%s&guid=ON'>%s</a>]&nbsp;%s<br />&nbsp;%s</div><hr />\n|,
        $oddeven[$lines%2],
        Avatar::Hair::TYPE->{$u->{hair_type}},
        Avatar::Face::TYPE->{$u->{face_type}},
        $u->{user_id}, $u->{user_id},
        $u->{user_name},
        $u->{msg},
    );
    $lines++;
    $last_user_id = $u->{user_id} if ( $last_user_id < $u->{user_id} );
}

my $dest_page = "friends.cgi";
$out->{PAGER} = "<center>";
#if ( $page_id > 0 )
#{
#    $out->{PAGER} .= sprintf
#        '<a href="%s?guid=ON&lui=%s&p=%s">‘O‚Ö</a>',
#        $dest_page,
#        $prev_user_id,
#        ,$page_id - 1;
#}

if ( $lines >= 10 )
{
    $out->{RESULT} .= sprintf
        '|<a href="%s?guid=ON&lui=%s&p=%s">ŽŸ‚Ö</a>',
        $dest_page,
        $last_user_id,
        ,$page_id + 1;
}
$out->{PAGER} .= "</center>";


##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


