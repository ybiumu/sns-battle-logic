package MobileUtil;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );


my $browser = undef;
my $carrier_id = undef;
my $content_type = undef;

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
    $class->setBrowser("P");
    $class->setCarrierId(0);
    $class->setContentType("text/html");

    $class->parseUserAgent();
}


sub parseUserAgent
{
    my $class = shift;
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
}



sub get_muid {
    my $class = shift;
    my $muid = $ENV{"HTTP_X_DCMGUID"};
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


1;
