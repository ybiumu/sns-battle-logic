package PageUtil;
#
# à§
#
$|=1;
use strict;


use LoggingObjMethod;
use LocalConfig;
use base qw( LoggingObjMethod );

#my $BASE_DIR = "/home/users/2/ciao.jp-anothark/web";
#my $LOG_DIR = $BASE_DIR . "/.htlog";
#my $access_log = $LOG_DIR . "/access_log";
#my $system_log = $LOG_DIR . "/system_log";
#my $access_log = "aa_access_log";
#my $system_log = "aa_system.log";
my $content_type = "text/html";
my $selected_str = 'selected="true"';
#my $both = 0;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

#    $self->init();
    return $self;

}

sub init
{
    my $class = shift;
    $class->SUPER::init();
#    $class->setAccessLog($access_log);
#    $class->setSystemLog($system_log);
    $class->setContentType($content_type);
    $class->setSelectedStr($selected_str);
#    $class->setBoth($both);

}



sub setContentType
{
    my $class = shift;
    return $class->setAttribute( 'content_type', shift );
}

sub getContentType
{
    return $_[0]->getAttribute( 'content_type' );
}


sub setSelectedStr
{
    my $class = shift;
    return $class->setAttribute( 'selected_str', shift );
}

sub getSelectedStr
{
    return $_[0]->getAttribute( 'selected_str' );
}


sub printError
{
    my $class = shift;
    my $error_str = join("",@_);
    $class->error($error_str);
print <<_HEADER_;
Content-type: $class->{"content_type"};

<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN"
 "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
<html>
<head>
<title>ERROR!</title>
</head>
<body>
Having error!
<br />
$error_str
</body>
</html>
_HEADER_
    exit;
}


sub getOptionTag
{
    my $class = shift;
    my $v = shift;
    my $selected = [ "","", $class->getSelectedStr(), "", "" ];

    my $opt = sprintf '<option value="0"%s>--</option><option value="1"%s>Åõ</option><option value="2"%s>Å~</option>', (@{$selected})[2-$v,3-$v,4-$v];
    return $opt;
}



1;
