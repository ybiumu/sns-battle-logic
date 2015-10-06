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
use Anothark::ItemManager();

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setAdminUtil($mu);

my $ad_str = "";

my $im = new Anothark::ItemManager( $db );

my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();

my $v = $c->param("v") || 1;
my $o = $c->param("o") || 0;
my $p = $c->param("p") || 1;


##################
### init check ###
##################
my $result = $at->setupBaseData();
if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("../setup.cgi?guid=ON");    
    exit;
}




our $out = $at->getOut();
#unless ( $out->{GM} )
#{
#    print $c->header( -status=>"404 Not found" );
#    exit 1;
#}

##############
### depend ###
##############
$at->setBody("body_any2.html");
$at->setPageName("管理 - ｱｲﾃﾑ一覧");
my $version = "0.1a20130415";



############
### Main ###
############


my $item_list = $im->getItemList($o,$v);

my @oddeven = ( "odd", "even" );

$out->{RESULT_TITLE} = "管理 - ｱｲﾃﾑ一覧";
my $lines = 0;

if ( scalar((keys%{$item_list})) > 0 )
{

    if( $p > 1 )
    {
        $out->{RESULT} .= sprintf(
            qq[<a href="view_item_list.cgi?guid=ON&p=%s&o=%s&v=%s">&lt;&lt;*前へ</a>],
            $p-1, (sort { $a <=> $b } keys %{$item_list})[0] ,-1
        );
    }
    else
    {
        $out->{RESULT} .= sprintf( qq[&lt;&lt;*前へ] );
    }

    $out->{RESULT} .= "|";

    if ( $im->hasNext() )
    {
        $out->{RESULT} .= sprintf(
            qq[<a href="view_item_list.cgi?guid=ON&p=%s&o=%s&v=%s">#次へ&gt;&gt;</a>],
            $p+1, (sort { $b <=> $a } keys %{$item_list})[0] ,1
        );
    }
    else
    {
        $out->{RESULT} .= sprintf( qq[#次へ&gt;&gt;] );
    }

    $out->{RESULT} .= "<br />\n";

    $out->{RESULT} .= "<form name=\"item\" method=\"get\" action=\"edit_item.cgi\">\n";
    $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";
    foreach my $row ( map { $item_list->{$_} } sort { $a <=> $b } keys %{$item_list} )
    {
        $lines++;
        $out->{RESULT} .= sprintf("<div class=\"item_%s\"><input type=\"radio\" name=\"item_master_id\" value=\"%s\" />&nbsp;%s</div>\n",$oddeven[$lines%2], $row->{item_master_id}, $row->{item_label})
    }
    $out->{RESULT} .= <<_HERE_
<select name="act">
<option value="descr">詳しく見る</option>
<option value="edit">編集する</option>
<option value="new">新規作成</option>
</select><input type="submit" value="5.実行" accesskey="5" />
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


