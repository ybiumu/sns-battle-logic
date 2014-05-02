#!/usr/bin/perl
############
### LOAD ###
############
use lib qw( .htlib ../../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::NodeLoader();

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

my $ad_str = "";

my $loader = new Anothark::NodeLoader( $db );

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




our $out = $at->getOut();
#unless ( $out->{GM} )
#{
#    print $c->header( -status=>"404 Not found" );
#    exit 1;
#}

my $offset = $c->param("p") || 0;

##############
### depend ###
##############
$at->setBody("body_any2.html");
$at->setPageName("管理 - ﾉｰﾄﾞ");
my $version = "0.1a20130415";



############
### Main ###
############


my $node_list = $loader->getNodeList();

my @oddeven = ( "odd", "even" );

$out->{RESULT_TITLE} = "管理 - ﾉｰﾄﾞ編集";
my $lines = 0;

if ( scalar((keys%{$node_list})) > 0 )
{
    $out->{RESULT} = "<form name=\"node\" method=\"get\" action=\"edit_node.cgi\">\n";
    $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";
    foreach my $row ( map { $node_list->{$_} } sort { $a <=> $b } keys %{$node_list} )
    {
        $lines++;
        $out->{RESULT} .= sprintf("<div class=\"item_%s\"><input type=\"radio\" name=\"node_id\" value=\"%s\" />&nbsp;%s</div>\n",$oddeven[$lines%2], $row->{node_id}, $row->{node_name})
    }


    # Paging or Can't read more.
    if ( $loader->getMaxRow() )
    {


        $out->{RESULT} .= "<br /><center>";

        if ( $offset > 0 )
        {
            $out->{RESULT} .= sprintf
                '<a href="view_node_list.cgi?guid=ON&p=%s">前へ</a>',
                ,$offset - 1;
        }

        if( $loader->getMaxRow() <= ( 20 * ( $offset + 1) ))
        {
            $out->{RESULT} .= 'これ以上ありません';
        }
        else
        {
            $out->{RESULT} .= sprintf
                '|<a href="view_node_list.cgi?guid=ON&p=%s">次へ</a>',
                ,$offset + 1;
        }
        $out->{RESULT} .= "</center>";

    }

    $out->{RESULT} .= <<_HERE_
<select name="act">
<option value="descr">詳しく見る</option>
<option value="edit">編集する</option>
</select><input type="submit" name="do"  value="5.実行" accesskey="5" />
<br />
<input type="submit" name="new" value="新規作成" />
</form>

_HERE_
}

#$sth->finish();

##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



$db->disconnect();
$at->setup();
$at->output();





exit;


