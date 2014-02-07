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

sub dump
{
    my $class = shift;
    my $result = [];
    stackDump($class,0,$result);
    return $result;
}

sub stackDump
{
    my $obj   = shift;
    my $depth = shift;
    my $result = shift;
    if( ref($obj) eq "HASH" )
    {
        foreach my $key ( sort keys %{$obj} )
        {
            if ( ref($obj->{$key}) )
            {
                push(@{$result}, sprintf "%s(KEY)[%s]->%s", "  " x $depth,$key,ref($obj->{$key}));
                stackDump($obj->{$key},$depth+1,$result);
            }
            else
            {
                push(@{$result}, sprintf "%s(KEY)[%s]->%s", "  " x $depth,$key,$obj->{$key});
            }
        }
    }
    elsif ( ref($obj) eq "ARRAY" )
    {
        foreach my $idx ( (0 .. (scalar(@{$obj}) - 1) ))
        {
            if ( ref($obj->[$idx]) )
            {
                push(@{$result}, sprintf "%s(IDX)[%s]->%s", "  " x $depth,$idx,ref($obj->[$idx]));
                stackDump($obj->[$idx],$depth+1,$result);
            }
            else
            {
                push(@{$result}, sprintf "%s(IDX)[%s]->%s", "  " x $depth,$idx,$obj->[$idx]);
            }
        }
    }
    elsif( ref($obj) eq "SCALAR" )
    {
        push(@{$result}, sprintf "%s(SCA)[%s]->%s", "  " x $depth,ref($obj),$$obj);
    }
    elsif( ref($obj) )
    {
        push(@{$result}, sprintf "%s(REF)[%s]->%s", "  " x $depth,ref($obj),$obj);
        foreach my $key ( sort keys %{$obj} )
        {
            if ( ref($obj->{$key}) )
            {
                push(@{$result}, sprintf "%s(KEY)[%s]->%s", "  " x $depth,$key,ref($obj->{$key}));
                stackDump($obj->{$key},$depth+1,$result);
            }
            else
            {
                push(@{$result}, sprintf "%s(KEY)[%s]->%s", "  " x $depth,$key,$obj->{$key});
            }
        }
    }
    else
    {
        push(@{$result}, sprintf "%s(NML)->%s", "  " x $depth,$obj);
    }
}

1;
