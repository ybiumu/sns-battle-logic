package LoggingObjMethod;
$|=1;

use ObjMethod;
use LocalConfig;
use base qw( ObjMethod );

our $access_log = $LocalConfig::ACCESS_LOG;
our $system_log = $LocalConfig::SYSTEM_LOG;
our $both = 0;


sub new
{
    my $class = shift;
    my $default = shift || {};
    my $self = $class->SUPER::new($default);
    bless $self, $class;

#    $self->init();
    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setAccessLog($access_log);
    $class->setSystemLog($system_log);
    $class->setBoth($both);

}

sub setBoth
{
    my $class = shift;
    return $class->setAttribute( 'both', shift );
}

sub getBoth
{
    return $_[0]->getAttribute( 'both' );
}


sub setSystemLog
{
    my $class = shift;
    return $class->setAttribute( 'system_log', getLogPath(shift) );
}

sub getSystemLog
{
    return $_[0]->getAttribute( 'system_log' );
}

sub setAccessLog
{
    my $class = shift;
    return $class->setAttribute( 'access_log', getLogPath(shift) );
}

sub getAccessLog
{
    return $_[0]->getAttribute( 'access_log' );
}

sub getLogPath
{
    return sprintf("%s/%s", $LocalConfig::LOG_DIR, shift );
}

sub output_access_log
{
    my $class = shift;
    open LOG, ">>", $class->getAccessLog()  || ( printError("Can't open log 1") && exit );
    printf LOG "[%s] %s\n", scalar(localtime()), join(" ",@_);
    close LOG;
}

sub output_log
{
    my $class = shift;
    open LOG, ">>", $class->getSystemLog() || die "Can't open log 2[" .$class->getSystemLog()  . "] msg:[".join("",@_)."]" ;
    my $log_str = sprintf( "[%s] %s\n", scalar(localtime()), join("",@_) );
    printf LOG $log_str;
    printf $log_str if $class->getBoth();
    $LocalConfig::LOCAL_DEBUG && warn $log_str; 
    close LOG;
}


sub debug
{
    my $class = shift;
    $class->output_log(sprintf("[D]%s", join("",( "[", ref($class) ,"] " ,@_)) ));
}

sub notice
{
    my $class = shift;
    $class->output_log(sprintf("[N]%s", join("",( "[", ref($class) ,"] " ,@_)) ));
}

sub error
{
    my $class = shift;
    $class->output_log(sprintf("[E]%s", join("",( "[", ref($class) ,"] " ,@_)) ));
}

sub warning
{
    my $class = shift;
    $class->output_log(sprintf("[W]%s", join("",( "[", ref($class) ,"] " ,@_)) ));
}


sub printError
{
    my $class = shift;
    my $error_str = join("",@_);
    $class->error($error_str);
print STDERR <<_HEADER_;
$error_str
_HEADER_
    exit;
}


1;
