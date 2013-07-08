package Anothark::Item;
#
# ˆ¤
#
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );
sub new
{
    my $class   = shift;
    my $options = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;


    if( ref( $options ) eq "HASH" )
    {
        foreach my $key ( keys %{$options})
        {
            $self->{$key} = $options->{$key};
        }
    }


    return $self;
}


sub FigmentParts
{
    my $at = shift;
    my $result = 0;
    my $sql = "UPDATE t_user_money SET rel = rel + 1 WHERE user_id = ?";
    my $sth = $at->getDbHandler()->prepare($sql);
    my $stat = $sth->execute($at->{out}->{USER_ID});
    if ( $stat && $stat ne "0E0" )
    {
        $result = 1;
    }

    return $result;
}

1;
