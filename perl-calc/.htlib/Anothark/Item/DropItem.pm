package Anothark::Item::DropItem;
#
# ˆ¤
#
$|=1;
use strict;


use Anothark::Item;
use base qw( Anothark::Item );
sub new
{
    my $class    = shift;
    my $options  = shift;
    my $drop_rate = shift || 100;
    my $self = $class->SUPER::new($options);
    bless $self, $class;

    $self->setDropRate( $drop_rate );

#    if( ref( $options ) eq "HASH" )
#    {
#        foreach my $key ( keys %{$options})
#        {
#            $class->warning( "$key : $options->{$key}");
#            $self->{$key} = $options->{$key};
#        }
#    }


    return $self;
}

my $drop_rate = undef;
sub setDropRate
{
    my $class = shift;
    return $class->setAttribute( 'drop_rate', shift );
}

sub getDropRate
{
    return $_[0]->getAttribute( 'drop_rate' );
}


sub isDroped
{
    my $class = shift;
    return rand(100) < $class->getDropRate() ? 1 : 0;
}

#my $item_master_id = undef;
#my $item_label = undef;
#my $item_descr = undef;
#my $item_type_id = undef;
#my $item_sub_type_id = undef;
#my $merge_number = undef;
#my $item_selling_price = undef;
#my $item_broken_range = undef;
#my $item_broken_rate = undef;
#my $use_effect_value = undef;
#my $use_effect_target = undef;
#my $use_effect_range = undef;
#
#my $field_names = undef;
#
#sub setFieldNames
#{
#    my $class = shift;
#    return $class->setAttribute( 'field_names', shift );
#}
#
#sub getFieldNames
#{
#    return $_[0]->getAttribute( 'field_names' );
#}
#
#sub setItemMasterId
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_master_id', shift );
#}
#
#sub getItemMasterId
#{
#    return $_[0]->getAttribute( 'item_master_id' );
#}
#
#sub setItemLabel
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_label', shift );
#}
#
#sub getItemLabel
#{
#    return $_[0]->getAttribute( 'item_label' );
#}
#
#sub setItemDescr
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_descr', shift );
#}
#
#sub getItemDescr
#{
#    return $_[0]->getAttribute( 'item_descr' );
#}
#
#sub setItemTypeId
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_type_id', shift );
#}
#
#sub getItemTypeId
#{
#    return $_[0]->getAttribute( 'item_type_id' );
#}
#
#sub setItemSubTypeId
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_sub_type_id', shift );
#}
#
#sub getItemSubTypeId
#{
#    return $_[0]->getAttribute( 'item_sub_type_id' );
#}
#
#sub setMergeNumber
#{
#    my $class = shift;
#    return $class->setAttribute( 'merge_number', shift );
#}
#
#sub getMergeNumber
#{
#    return $_[0]->getAttribute( 'merge_number' );
#}
#
#sub setItemSellingPrice
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_selling_price', shift );
#}
#
#sub getItemSellingPrice
#{
#    return $_[0]->getAttribute( 'item_selling_price' );
#}
#
#sub setItemBrokenRange
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_broken_range', shift );
#}
#
#sub getItemBrokenRange
#{
#    return $_[0]->getAttribute( 'item_broken_range' );
#}
#
#sub setItemBrokenRate
#{
#    my $class = shift;
#    return $class->setAttribute( 'item_broken_rate', shift );
#}
#
#sub getItemBrokenRate
#{
#    return $_[0]->getAttribute( 'item_broken_rate' );
#}
#
#sub setUseEffectValue
#{
#    my $class = shift;
#    return $class->setAttribute( 'use_effect_value', shift );
#}
#
#sub getUseEffectValue
#{
#    return $_[0]->getAttribute( 'use_effect_value' );
#}
#
#sub setUseEffectTarget
#{
#    my $class = shift;
#    return $class->setAttribute( 'use_effect_target', shift );
#}
#
#sub getUseEffectTarget
#{
#    return $_[0]->getAttribute( 'use_effect_target' );
#}
#
#sub setUseEffectRange
#{
#    my $class = shift;
#    return $class->setAttribute( 'use_effect_range', shift );
#}
#
#sub getUseEffectRange
#{
#    return $_[0]->getAttribute( 'use_effect_range' );
#}
#
#
#
#
#sub FigmentParts
#{
#    my $at = shift;
#    my $result = 0;
#    my $sql = "UPDATE t_user_money SET rel = rel + 1 WHERE user_id = ?";
#    my $sth = $at->getDbHandler()->prepare($sql);
#    my $stat = $sth->execute($at->{out}->{USER_ID});
#    if ( $stat && $stat ne "0E0" )
#    {
#        $result = 1;
#    }
#
#    return $result;
#}

1;
