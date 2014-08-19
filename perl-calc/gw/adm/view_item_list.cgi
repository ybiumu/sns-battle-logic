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
$at->setPageName("ŠÇ— - ±²ÃÑˆê——");
my $version = "0.1a20130415";



############
### Main ###
############


my $item_list = $im->getItemList();

my @oddeven = ( "odd", "even" );

$out->{RESULT_TITLE} = "ŠÇ— - ±²ÃÑˆê——";
my $lines = 0;

if ( scalar((keys%{$item_list})) > 0 )
{
    $out->{RESULT} = "<form name=\"item\" method=\"get\" action=\"edit_item.cgi\">\n";
    $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";
    foreach my $row ( map { $item_list->{$_} } sort { $a <=> $b } keys %{$item_list} )
    {
        $lines++;
        $out->{RESULT} .= sprintf("<div class=\"item_%s\"><input type=\"radio\" name=\"item_master_id\" value=\"%s\" />&nbsp;%s</div>\n",$oddeven[$lines%2], $row->{item_master_id}, $row->{item_label})
    }
    $out->{RESULT} .= <<_HERE_
<select name="act">
<option value="descr">Ú‚µ‚­Œ©‚é</option>
<option value="edit">•ÒW‚·‚é</option>
<option value="new">V‹Kì¬</option>
</select><input type="submit" value="5.Às" accesskey="5" />
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


