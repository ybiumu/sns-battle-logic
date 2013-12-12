package ObjMethod;
$|=1;
$VERSION = "1.1";

sub new
{
    my $class = shift;
    my $default = shift || undef;
    my $self  = {};
    if ( $default && ref($default) eq "HASH")
    {
        $self = $default;
    }
    bless $self, $class;
    $self->init();
    return $self;
}

sub init
{
    my $class = shift;
}

sub setAttribute
{
    my $class = shift;
    my $name  = shift;
    my $value = shift;
    $class->{$name} = $value;
    return $class->{$name};
}

sub appendAttribute
{
    my $class = shift;
    my $name  = shift;
    my $value = shift;
    if ( exists $class->{$name} )
    {
        $class->{$name} .= $value;
    }
    else
    {
        $class->setAttribute( $name, $value );
    }
    return $class->{$name};
}

sub getAttribute
{
    my $class = shift;
    my $name  = shift;
    if ( exists $class->{$name} )
    {
        return $class->{$name};
    }
    else
    {
        return undef;
    }
}




sub delAttribute
{
    my $class = shift;
    my $name  = shift;
    if ( exists $class->{$name} )
    {
        return delete $class->{$name};
    }
    else
    {
        return undef;
    }
}

1;
