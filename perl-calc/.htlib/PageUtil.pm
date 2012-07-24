package PageUtil;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

my $BASE_DIR = "/home/users/2/ciao.jp-anothark/web";
my $LOG_DIR = $BASE_DIR . "/.htlog";
my $access_log = $LOG_DIR . "/access_log";
my $system_log = $LOG_DIR . "/system_log";
my $content_type = "text/html";
my $selected_str = 'selected="true"';

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

    $self->init();
    return $self;

}

sub init
{
    my $class = shift;
    $class->setAccessLog($access_log);
    $class->setSystemLog($system_log);
    $class->setContentType($content_type);
    $class->setSelectedStr($selected_str);

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

sub setSystemLog
{
    my $class = shift;
    return $class->setAttribute( 'system_log', shift );
}

sub getSystemLog
{
    return $_[0]->getAttribute( 'system_log' );
}

sub setAccessLog
{
    my $class = shift;
    return $class->setAttribute( 'access_log', shift );
}

sub getAccessLog
{
    return $_[0]->getAttribute( 'access_log' );
}


sub output_access_log
{
    my $class = shift;
    open LOG, ">>", $class->getAccessLog()  || ( printError("Can't open log 1") && exit );
    printf LOG "[%s] %s\r\n", scalar(localtime()), join(" ",@_);
    close LOG;
}

sub output_log
{
    my $class = shift;
    open LOG, ">>", $class->getSystemLog || ( printError("Can't open log 2") && exit );
    printf LOG "[%s] %s\r\n", scalar(localtime()), join("",@_);
    close LOG;
}

sub notice
{
    my $class = shift;
    $class->output_log(sprintf("[NOTICE] %s", join("",@_) ));
}

sub error
{
    my $class = shift;
    $class->output_log(sprintf("[ERROR] %s", join("",@_) ));
}

sub warning
{
    my $class = shift;
    $class->output_log(sprintf("[WARNING] %s", join("",@_) ));
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
