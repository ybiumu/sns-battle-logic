package MobileUtil;
$|=1;
use strict;


use CGI;
use CGI::Session;
use LoggingObjMethod;
use base qw( LoggingObjMethod );


my $browser = undef;
my $carrier_id = undef;
my $content_type = undef;
my $is_batch = undef;

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
    $class->setBrowser("P");
    $class->setCarrierId(0);
    $class->setContentType("text/html");
    $class->parseUserAgent();
}



sub parseUserAgent
{
    my $class = shift;
    $class->debug("parseUserAgent");
    if( $ENV{HTTP_USER_AGENT} =~ /^DoCoMo\/(1|2)/)
    {
        $class->setBrowser("D");
        $class->setCarrierId(1);
        $class->setContentType("application/xhtml+xml");
    }
    elsif( $ENV{HTTP_USER_AGENT} =~ /UP\.Browser\// )
    {
        $class->setBrowser("A");
        $class->setCarrierId(2);
        $class->setContentType("application/xhtml+xml");
    }
    elsif( $ENV{HTTP_USER_AGENT} =~ /^(J-PHONE|Vodafone|MOT-|SoftBank)/ )
    {
        $class->setBrowser("S");
        $class->setCarrierId(3);
        $class->setContentType("application/xhtml+xml");
    }
    elsif( $class->getIsBatch() eq "1" )
    {
        $class->debug("Run as batch");
    }
    else
    {
        my $cgi = CGI->new;
        my $sid = $cgi->cookie('CGISESSID')||undef;
        if ( $sid )
        {
            my $session = new CGI::Session(undef, $sid, {Directory=>'/home/users/2/ciao.jp-anothark/web/.htsession'});
            $class->debug("Session check");
            if ( $sid eq $session->id)
            {
                # Updage available time.
                $session->expire("+2h");

                if ( $session->param('pattern') eq "twauth" )
                {
                    $class->debug(" Session is 'twauth'");
                    $class->setBrowser("P");
                    $class->setCarrierId(11);
                    $class->debug(" Session user_id is `" . $session->param('user_id'). "'");
                    $class->setUid( sprintf("%s:%s", $session->param('pattern'), $session->param('user_id')));
                }
                else
                {
                    $class->debug(" Session is 'unknown' type");
                }
            }
            else
            {
                $class->notice(" Session is Expired[$sid]. ");
                $session->close();
                $session->delete();
                print $cgi->redirect( -uri => "/sp/logout.html" );
                exit;
            }
        }
        else
        {
            $class->debug("No sid");
            print $cgi->redirect( -uri => "/sp/logout.html" );
            exit;
        }
    }
}



sub get_muid {
    my $class = shift;

    my $muid ;
    if( $class->getBrowser() ne "P" )
    {
        $muid = $ENV{"HTTP_X_DCMGUID"};
        if ($muid) {
          return $muid;
        }
        $muid = $ENV{"HTTP_X_UP_SUBNO"};
        if ($muid) {
          return $muid;
        }
        $muid = $ENV{"HTTP_X_JPHONE_UID"};
        if ($muid) {
          return $muid;
        }
        $muid = $ENV{"HTTP_X_EM_UID"};
        if ($muid) {
          return $muid;
        }
    }

    $muid = $class->getUid();
    $class->debug("get_muid muid is '$muid'");
    if($muid)
    {
        return $muid;
    }
}


sub setUid
{
    my $class = shift;
    $class->debug("Call setUid '" . $_[0] . "'");
    return $class->setAttribute( 'uid', shift );
}

sub getUid
{
    return $_[0]->getAttribute( 'uid' );
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


sub setCarrierId
{
    my $class = shift;
    return $class->setAttribute( 'carrier_id', shift );
}

sub getCarrierId
{
    return $_[0]->getAttribute( 'carrier_id' );
}

sub setBrowser
{
    my $class = shift;
    return $class->setAttribute( 'browser', shift );
}

sub getBrowser
{
    return $_[0]->getAttribute( 'browser' );
}


sub setIsBatch
{
    my $class = shift;
    return $class->setAttribute( 'is_batch', shift );
}

sub getIsBatch
{
    return $_[0]->getAttribute( 'is_batch' );
}



1;
