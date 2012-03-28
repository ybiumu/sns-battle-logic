#!/usr/bin/perl

use lib qw( .htlib ../../.htlib );
use Ellark::Battle::BaseValue;
use Ellark::Battle::TargetValue;
use Ellark::Battle::StatusValue;
use CGI;
use CGISecure;


my $c_def = new CGI();
my $c  = new CGISecure( $c_def );

my $dp  = "../../data/pcht";
my $udp = "$dp/ud";
my $lp = "../../.htlog";
our $bd = "$dp/bt.dat";
our $ed = "$dp/et.dat";
our $last_index = "$dp/last_index.txt";



my $system_log = "$lp/pcht.log";

my $version = "0.1a20110512";
#my $debug_strings = "";


my $content_type = "text/html";
my $browser = "P";
my $uid = "";

if( $ENV{HTTP_USER_AGENT} =~ /^DoCoMo\/(1|2)/)
{
    $browser = "D";
    $uid = $ENV{HTTP_X_DCMGUID};
    $content_type = "application/xhtml+xml";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /UP\.Browser\// )
{
    $browser = "A";
    $uid = $ENV{HTTP_X_UP_SUBNO};
    $content_type = "application/xhtml+xml";
}
elsif( $ENV{HTTP_USER_AGENT} =~ /^(J-PHONE|Vodafone|MOT-|SoftBank)/ )
{
    $browser = "S";
    $uid = $ENV{HTTP_X_JPHONE_UID};
    $content_type = "application/xhtml+xml";
}
notice("Carrier is : $browser");
notice("uid is : $uid");
map { notice(sprintf "%s: %s", $_, $ENV{$_}) } keys %ENV ;


our $et_map = {};
our $et_rmap = {};
our $log_record = [];

my $require_init = 0;

if (not defined $uid )
{
    notice("uid is UNDEF");
    $require_init = 1;
}
if( $uid eq "")
{
    notice("uid is WHITESPACE");
    $require_init = 1;
}

my $msg  = "";
my $logs = "";
my $name = "";

print <<_HEADER_;
Content-type: $content_type;

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
_HEADER_

print "<html><head><title>test</title></head><body>";



if ( $require_init )
{
   $msg .= "<H1>Can't get your data.</H1>";
   $msg .= "<form method='post' action='pcht.cgi?guid=ON'><input type='hidden' name='guid' value='ON'><input type='submit' value='login'></form>";
}
else
{
    notice("load entry.");
    load_entry();
    notice("load entry done.");
    map { notice("KEY: $_") } keys %{$et_rmap};
    if ( not exists $et_rmap->{$uid} )
    {
        notice("entry[$uid].");
        entry($uid);
        notice("entry done.");
    }
    notice("reload entry.");
    load_entry();
    notice("reload entrydone.");
    $name = load_user($et_rmap->{$uid});

    my $tid = $c->param_def("tid",0);
    notice("[tid]: $tid");
    my $atk = $c->param_def("attack",0);
    notice("[atk]: $atk");
#    my $skill = $c->param_def("skill","何もしない");
    my $skill = $c_def->param("skill");
    notice("[skl]: $skill");
    my $target = "適当";

    if ( $tid != 0 )
    {
        $target = load_user($tid);
    }

    if ( $atk != 0 )
    {
        notice("[ATTACK]");
        write_log($et_rmap->{$uid},$tid,$skill);
        notice("[ATTACK] done.");
    }
    $msg = <<_HERE_
<!--uid is: $uid-->
<form method="post" action="pcht.cgi?guid=ON">
なまえ:<input type="text" name="name" value="$name" /><br />
スキル:<input type="text" name="skill" value="" /><br />
ﾀｰｹﾞｯﾄ:$target<input type="hidden" name="tid" value="$tid" /><br />
<input type="submit" name="attack" value="action!" />
</form>
_HERE_

}

printf <<_HERE_;
$msg
<hr />
_HERE_

load_battle_data();

map { printf "%s<hr />\n", $_ } @{$log_record};

printf "</body></html>";

sub write_log
{
    my $from_id  = shift;
    my $target   = shift;
    my $skill    = shift;
    my $from_name   = load_user($from_id);
    my $target_name = load_user($target);
    my $log_data = sprintf(
        "■%s(<a href='pcht.cgi?tid=%s'>&lt;&lt;</a>)<br />%s!<br />　⇒%s<br />0のﾀﾞﾒｰｼﾞ!", 
        $from_name, $from_id, $skill, $target_name
    );
    open WR, ">>$bd";
    printf WR $log_data;
    close WR;
}

sub load_entry
{
    open OP, $ed;
    while(<OP>)
    {
        chomp();
        my ($uuid, $uid) = split(",",$_,2);
        notice("[Record] uuid: $uuid, uid: $uid");
        $et_map->{$uuid} = $uid;
        $et_rmap->{$uid} = $uuid;

    }
    close(OP);
}

sub entry
{
    my $uid = shift;
    my $name = shift || 'ごんべ';
    notice("Load entry");
    my $id = auto_increment($last_index);
    notice("  id is : $id");
    open(WR, ">>$ed");
    printf WR "%s,%s\n", $id, $uid;
    close(WR); 
    modify_entry($id,$name);
    notice("Load entry done");
}

sub modify_entry
{
    my $id   = shift;
    my $name = shift;
    open(WR2, ">$udp/$id");
    printf WR2 "%s\n", $name;
    close(WR2); 
}



sub load_user
{
    my $id   = shift;
    open(OP, "$udp/$id");
    my $et = <OP>;
    chomp;
    close(OP);
    return $et;
}

sub auto_increment
{
    my $datafile = shift;
    my $line = -1;
    if ( -f $datafile )
    {
        open(OUT, "+< $datafile");
        seek(OUT, 0, 0);
        chomp($line = <OUT>);
        seek(OUT, 0, 0);
        printf OUT "%s\n",$line+1;
        truncate(OUT, tell(OUT));
        close(OUT);
        if ($@ =~ /time out/) {
            return -1
        }
        elsif ($@) { die }
    }
    return $line;
}

sub load_battle_data
{
    open MAP, "$bd";
    while(<MAP>)
    {
        chomp;
        unshift(@{$log_record}, $_ );
    }
    close MAP;
}

sub output_log
{
    open LOG, ">>$system_log" or die;
    printf LOG "[%s] %s\n", scalar(localtime()), join(" ", @_);
    close LOG;
}

sub notice
{
    output_log(sprintf("[NOTICE] %s", join(" ", @_) ));
}

sub error
{
    output_log(sprintf("[ERROR] %s", join(" ", @_) ));
}

sub warning
{
    output_log(sprintf("[WARNING] %s", join(" ", @_) ));
}
