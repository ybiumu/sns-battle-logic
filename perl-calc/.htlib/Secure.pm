package Secure;
$|=1;

sub sanitize($)
{
    my ( $str ) = shift;
    $str =~ tr/0-9\-\.//dc;
    return $str
};
1;
