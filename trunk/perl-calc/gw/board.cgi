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
use Anothark::BoardManager;
use Anothark::TextFilter;

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

my $board = new Anothark::BoardManager($db);

my $board_type_id = $c->param("t") || 1;

our $out = $at->getOut();
my $user_id = $out->{USER_ID};
my $target_user_id = $c->param("oid") || $user_id;
my $thread_id      = $c->param("tid") || "";
my $board_write    = $c->param("bw")  || "";
my $page_id = $c->param("p") || 0;


##############
### depend ###
##############
$at->setBody("body_any.html");
$at->setPageName("bbs");
my $version = "0.1a20130415";

$out->{TARGET_USER_ID} = $target_user_id;
$out->{BOARD_TYPE_ID}  = $board_type_id;


############
### Main ###
############

my $board_id = $board->getOwnersBoard( $board_type_id, $user_id ,$target_user_id );
my $writeable = $board->getWritableBoard( $board_type_id, $user_id ,$target_user_id ); 
if ( ! $board_id )
{
    $at->Error();
    $at->warning(sprintf( "type_id: %s user_id:%s targe_id: %s",$board_type_id, $user_id ,$target_user_id ) );
    $out->{"RESULT"} = '‰{——Œ ŒÀ‚ª‚ ‚è‚Ü‚¹‚ñ';
}
elsif( $board_write && $writeable)
{
    $at->setBody("body_board_write.html");
    if ( $c->param("msg") )
    {
        my $filter   = new Anothark::TextFilter();
        my $message = $filter->optimize($c->param("msg"));
        $out->{CURRENT_TEXT} = $message;
    }
    elsif ( $c->param("tid") && $c->param("tid") =~ /^\d+$/ )
    {
        $out->{CURRENT_TEXT} = sprintf("&gt;&gt;%s", $c->param("tid"));
    }

    $at->setPageName('‘‚«ž‚Ý’†');
    $out->{CPAGE} = $page_id;

}
else
{
    $at->setBody("body_board.html");

    my $target_char;

    if ( grep { $board_type_id == $_ } (1,2) )
    {
        $target_char = $at->getCharacterByUserId( $target_user_id );
    }

    $at->setPageName(
        ( ( grep { $board_type_id == $_ } (1,2) ) ? sprintf('%s‚Ì', $target_char->getName()) : "" )
        .
        Anothark::BoardManager->BOARD_TYPE_NAME->{$board_type_id}
    );

    if ( $c->param("msg") )
    {
        $board->writeBoard( $board_id, $user_id, $c->param("msg"));
    }

    if ( $board->getErrMsg() )
    {
        $out->{PRE_RESULT} = sprintf("<hr /><span style='color:#ff0000'>%s</span><hr />", '‹ÖŽ~•¶Žš—ñ‚ªŠÜ‚Ü‚ê‚Ä‚¢‚Ü‚·');
    }

    if ( $board_write )
    {
        $out->{PRE_RESULT} .= sprintf("<hr /><span style='color:#ff0000'>%s</span><hr />", '‘‚«ž‚Ý‚Í‹ÖŽ~‚³‚ê‚Ä‚Ü‚·');
    }

    my $entries = $board->readBoard( $board_id, $page_id, $thread_id);

    foreach my $entry ( @{$entries} )
    {
        my $msg = $entry->{message};
        $msg =~ s/\n/<br \/>/g;
        $msg =~ s/ /&nbsp;/g;
        $msg =~ s/&gt;&gt;(\d+)/<a href="board.cgi?guid=ON&t=$board_type_id&oid=$target_user_id&tid=$1">&gt;&gt;$1<\/a>/g;
        $out->{RESULT} .= sprintf
            "<hr />\n[<a href='board.cgi?guid=ON&bw=1&t=%s&oid=%s&tid=%s'>%s</a>]<a href='mypage.cgi?user_id=%s&guid=ON'>%s</a><br />(%s)<br />%s",
            $board_type_id,
            $target_user_id,
            $entry->{thread_id},
            $entry->{thread_id},
            $entry->{user_id},
            $entry->{user_name},
            $entry->{last_update},
            $msg;
    }

    if ( ! $thread_id )
    {
        # Paging or Can't read more.
        if ( ! $board->getMaxRow() )
        {
            $out->{RESULT} = '‚Ü‚¾‘‚«ž‚Ý‚ª‚ ‚è‚Ü‚¹‚ñ';
        }
        else
        {


            $out->{RESULT} .= "<hr /><center>";

            if ( $page_id > 0 )
            {
                $out->{RESULT} .= sprintf
                    '<a href="board.cgi?guid=ON&t=%s&oid=%s&p=%s">‘O‚Ö</a>',
                    $board_type_id,
                    $target_user_id,
                    ,$page_id - 1;
            }

            if( $board->getMaxRow() <= ( 10 * ( $page_id + 1) ))
            {
                $out->{RESULT} .= '<br />‚±‚êˆÈã‘‚«ž‚Ý‚ª‚ ‚è‚Ü‚¹‚ñ';
            }
            else
            {
                $out->{RESULT} .= sprintf
                    '|<a href="board.cgi?guid=ON&t=%s&oid=%s&p=%s">ŽŸ‚Ö</a>',
                    $board_type_id,
                    $target_user_id,
                    ,$page_id + 1;
            }
            $out->{RESULT} .= "</center>";
        }
    }

    if ( $thread_id )
    {
        $out->{SRC_PAGE} = sprintf( "board.cgi?guid=ON&t=%s&p=%s&oid=%s", $board_type_id,$page_id, $target_user_id );
    }
    elsif ( grep { $board_type_id == $_ } (3,4))
    {
        $out->{SRC_PAGE} = sprintf( "chose.cgi?guid=ON" );
    }
    elsif ( $board_type_id == 2 )
    {
        $out->{SRC_PAGE} = sprintf( "party.cgi?guid=ON" );
    }
    else
    {
        $out->{SRC_PAGE} = sprintf( "mypage.cgi?guid=ON&user_id=%s",$target_user_id );
    }

}


##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


