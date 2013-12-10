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
use Anothark::SkillLoader();

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";

my $loader = new Anothark::SkillLoader( $db );

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

##############
### depend ###
##############
$at->setBase("adm_template.html");
$at->setBody("body_any2.html");
$at->setPageName("管理 - ｽｷﾙ編集");
my $version = "0.1a20130415";



############
### Main ###
############


my $skill_list = $loader->getSkillList();

my @oddeven = ( "odd", "even" );

$out->{RESULT_TITLE} = "管理 - ｽｷﾙ編集";
my $lines = 0;

if ( scalar((keys%{$skill_list})) > 0 )
{
    $out->{RESULT} = "<form name=\"skill\" method=\"get\" action=\"edit_skill.cgi\">\n";
    $out->{RESULT} .= "<input type=\"hidden\" name=\"guid\" value=\"ON\"/>";
    foreach my $row ( map { $skill_list->{$_} } sort { $a <=> $b } keys %{$skill_list} )
    {
        $lines++;
        $out->{RESULT} .= sprintf("<div class=\"item_%s\"><input type=\"radio\" name=\"skill_id\" value=\"%s\" />&nbsp;%s</div>\n",$oddeven[$lines%2], $row->{skill_id}, $row->{skill_name})
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


