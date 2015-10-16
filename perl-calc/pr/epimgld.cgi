#!/usr/bin/perl
#
# ˆ¤
#
############
### LOAD ###
############
use lib qw( .htlib ../.htlib );
use CGI;
#use DbUtil;
#use MobileUtil;
use PageUtil;
use AaTemplate;

use Image::Magick;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);


#my $db = DbUtil::getDbHandler();
#my $mu = new MobileUtil();

#$at->setDbHandler($db);
#$at->setMobileUtil($mu);

my $ad_str = "";



#my $browser      = $mu->getBrowser();
my $c = new CGI();


##################
### init check ###
##################
#my $result = $at->setupBaseData(1);
#if ( ! $result )
#{
#    $db->disconnect();
#    print $c->redirect("setup.cgi?guid=ON");    
#    exit;
#}




our $img_path = "img";
our $background_path = sprintf("%s/%s", $img_path, "bg"); 
our $background_prefix = "b";
our $background_suffix = ".jpg";

our $monster_base_path = sprintf("%s/%s", $img_path, "mb"); 
our $monster_prefix    = "s";
our $monster_suffix    = ".png";


our $out = $at->getOut();
our $image_id = $c->param("i") || 0;
our $bimage_id = $c->param("b") || 0;

my @images = map { /^(f|b)(\d+)$/; { position => $1, code => $2} } split(/,/,$image_id);

##############
### depend ###
##############
$at->setImg($image_id);
my $version = "0.1a20130415";

my $base = sprintf( "%s/%s%04s%s", $background_path, $background_prefix, $bimage_id, $background_suffix );

my $magick_handler = new Image::Magick();
$magick_handler->Read($base);


my $monster_handler_front = new Image::Magick();
my $monster_handler_back = new Image::Magick();

my $append = $monster_handler_back->Append(stack=>'false');

foreach my $i_obj ( grep { $_->{position} eq "b" } @images )
{
    my $img_str = sprintf( "%s/%s%04s%s", $monster_base_path, $monster_prefix,$i_obj->{code} ,$monster_suffix );
    if ( -f $img_str )
    {
        $monster_handler_back->Read($img_str);
        $append = $monster_handler_back->Append(stack=>'false');
        $monster_handler_back = $append;
    }
}

my ($width, $height) = $monster_handler_back->Get('width', 'height');
$width = int($width / 1.3);
$height = int($height / 1.3);
$monster_handler_back->Scale(width => $width, height => $height);


$append = $monster_handler_front->Append(stack=>'false');
foreach my $i_obj ( grep { $_->{position} eq "f" } @images )
{
    my $img_str = sprintf( "%s/%s%04s%s", $monster_base_path, $monster_prefix,$i_obj->{code} ,$monster_suffix );
    if ( -f $img_str )
    {
        $monster_handler_front->Read($img_str);
        $append = $monster_handler_front->Append(stack=>'false');
        $monster_handler_front = $append;
    }
}

$magick_handler->Composite( image => $monster_handler_back,  compose => 'over', gravity => 'Center', y => "+25" );
$magick_handler->Composite( image => $monster_handler_front, compose => 'over', gravity => 'Center', y => "+40" );

############
### Main ###
############
my $imgtype = "jpeg";

print "Content-type: image/$imgtype\n\n";
binmode(STDOUT);
$magick_handler->Write("jpeg:-");




##############
### output ###
##############
$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');



#$db->disconnect();
#$at->setup();
#$at->output();





exit;


