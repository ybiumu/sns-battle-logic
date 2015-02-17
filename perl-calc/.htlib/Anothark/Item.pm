package Anothark::Item;
#
# ˆ¤
#
$|=1;
use strict;

use Anothark::ItemUsable;

use LoggingObjMethod;
use base qw( LoggingObjMethod );
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
            $self->debug( "$key : $options->{$key}");
            $self->{$key} = $options->{$key};
        }
    }

    $self->postInit();


    return $self;
}



# Fri Feb 14 12:32:50 JST 2014
# desc t_item_master;
# +--------------------+-------------+------+-----+---------+----------------+
# | Field              | Type        | Null | Key | Default | Extra          |
# +--------------------+-------------+------+-----+---------+----------------+
# | item_master_id     | int(11)     | NO   | PRI | NULL    | auto_increment |
# | item_label         | varchar(32) | NO   | UNI | NULL    |                |
# | item_descr         | tinytext    | YES  |     | NULL    |                |
# | item_type_id       | int(11)     | NO   |     | NULL    |                |
# | item_sub_type_id   | int(11)     | NO   |     | 0       |                |
# | merge_number       | smallint(6) | NO   |     | 1       |                |
# | item_selling_price | int(11)     | NO   |     | 0       |                |
# | item_broken_range  | smallint(6) | NO   |     | 0       |                |
# | item_broken_rate   | smallint(6) | NO   |     | 0       |                |
# | use_effect_value   | int(11)     | NO   |     | 0       |                |
# | use_effect_target  | smallint(6) | NO   |     | 0       |                |
# | use_effect_range   | smallint(6) | NO   |     | 0       |                |
# | is_external_exec   | tinyint(4)  | NO   |     | 0       |                |
# | external_function  | varchar(45) | YES  |     | NULL    |                |
# | max_hp             | smallint(6) | NO   |     | 0       |                |
# | hp                 | smallint(6) | NO   |     | 0       |                |
# | mp                 | smallint(6) | NO   |     | 0       |                |
# | agl                | smallint(6) | NO   |     | 0       |                |
# | kikyou             | smallint(6) | NO   |     | 0       |                |
# | atack              | smallint(6) | NO   |     | 0       |                |
# | def                | smallint(6) | NO   |     | 0       |                |
# | chrm               | smallint(6) | NO   |     | 0       |                |
# | chikaku            | smallint(6) | NO   |     | 0       |                |
# | luck               | smallint(6) | NO   |     | 0       |                |
# | kehai              | smallint(6) | NO   |     | 0       |                |
# | rp                 | smallint(6) | NO   |     | 0       |                |
# | stamina            | smallint(6) | NO   |     | 0       |                |
# +--------------------+-------------+------+-----+---------+----------------+





my $item_master_id = undef;
my $item_label = undef;
my $item_descr = undef;
my $item_type_id = undef;
my $item_sub_type_id = undef;
my $merge_number = undef;
my $item_selling_price = undef;
my $item_broken_range = undef;
my $item_broken_rate = undef;
my $use_effect_value = undef;
my $use_effect_target = undef;
my $use_effect_range = undef;


my $is_external_exec = undef;
my $external_function = undef;
my $max_hp = undef;
my $hp = undef;
my $mp = undef;
my $agl = undef;
my $kikyou = undef;
my $atack = undef;
my $def = undef;
my $chrm = undef;
my $chikaku = undef;
my $luck = undef;
my $kehai = undef;
my $rp = undef;
my $stamina = undef;


sub postInit
{
    my $class = shift;
    $class->SUPER::init();

    if ( defined Anothark::ItemUsable::USABLE->{$class->getItemSubTypeId()} )
    {
        $class->setAttribute( 'to_use', Anothark::ItemUsable::CALLBACK->{ $class->getItemSubTypeId() }  );
    }
    else
    {
        $class->setAttribute( 'to_use', undef );
    }
}


sub setIsExternalExec
{
    my $class = shift;
    return $class->setAttribute( 'is_external_exec', shift );
}

sub getIsExternalExec
{
    return $_[0]->getAttribute( 'is_external_exec' );
}

sub setExternalFunction
{
    my $class = shift;
    return $class->setAttribute( 'external_function', shift );
}

sub getExternalFunction
{
    return $_[0]->getAttribute( 'external_function' );
}

sub setMaxHp
{
    my $class = shift;
    return $class->setAttribute( 'max_hp', shift );
}

sub getMaxHp
{
    return $_[0]->getAttribute( 'max_hp' );
}

sub setHp
{
    my $class = shift;
    return $class->setAttribute( 'hp', shift );
}

sub getHp
{
    return $_[0]->getAttribute( 'hp' );
}

sub setMp
{
    my $class = shift;
    return $class->setAttribute( 'mp', shift );
}

sub getMp
{
    return $_[0]->getAttribute( 'mp' );
}

sub setAgl
{
    my $class = shift;
    return $class->setAttribute( 'agl', shift );
}

sub getAgl
{
    return $_[0]->getAttribute( 'agl' );
}

sub setKikyou
{
    my $class = shift;
    return $class->setAttribute( 'kikyou', shift );
}

sub getKikyou
{
    return $_[0]->getAttribute( 'kikyou' );
}

sub setAtack
{
    my $class = shift;
    return $class->setAttribute( 'atack', shift );
}

sub getAtack
{
    return $_[0]->getAttribute( 'atack' );
}

sub setDef
{
    my $class = shift;
    return $class->setAttribute( 'def', shift );
}

sub getDef
{
    return $_[0]->getAttribute( 'def' );
}

sub setChrm
{
    my $class = shift;
    return $class->setAttribute( 'chrm', shift );
}

sub getChrm
{
    return $_[0]->getAttribute( 'chrm' );
}

sub setChikaku
{
    my $class = shift;
    return $class->setAttribute( 'chikaku', shift );
}

sub getChikaku
{
    return $_[0]->getAttribute( 'chikaku' );
}

sub setLuck
{
    my $class = shift;
    return $class->setAttribute( 'luck', shift );
}

sub getLuck
{
    return $_[0]->getAttribute( 'luck' );
}

sub setKehai
{
    my $class = shift;
    return $class->setAttribute( 'kehai', shift );
}

sub getKehai
{
    return $_[0]->getAttribute( 'kehai' );
}

sub setRp
{
    my $class = shift;
    return $class->setAttribute( 'rp', shift );
}

sub getRp
{
    return $_[0]->getAttribute( 'rp' );
}

sub setStamina
{
    my $class = shift;
    return $class->setAttribute( 'stamina', shift );
}

sub getStamina
{
    return $_[0]->getAttribute( 'stamina' );
}




my $field_names = undef;

sub setFieldNames
{
    my $class = shift;
    return $class->setAttribute( 'field_names', shift );
}

sub getFieldNames
{
    return $_[0]->getAttribute( 'field_names' );
}

sub setItemMasterId
{
    my $class = shift;
    return $class->setAttribute( 'item_master_id', shift );
}

sub getItemMasterId
{
    return $_[0]->getAttribute( 'item_master_id' );
}

sub setItemLabel
{
    my $class = shift;
    return $class->setAttribute( 'item_label', shift );
}

sub getItemLabel
{
    return $_[0]->getAttribute( 'item_label' );
}

sub setItemDescr
{
    my $class = shift;
    return $class->setAttribute( 'item_descr', shift );
}

sub getItemDescr
{
    return $_[0]->getAttribute( 'item_descr' );
}

sub setItemTypeId
{
    my $class = shift;
    return $class->setAttribute( 'item_type_id', shift );
}

sub getItemTypeId
{
    return $_[0]->getAttribute( 'item_type_id' );
}

sub setItemSubTypeId
{
    my $class = shift;
    return $class->setAttribute( 'item_sub_type_id', shift );
}

sub getItemSubTypeId
{
    return $_[0]->getAttribute( 'item_sub_type_id' );
}

sub setMergeNumber
{
    my $class = shift;
    return $class->setAttribute( 'merge_number', shift );
}

sub getMergeNumber
{
    return $_[0]->getAttribute( 'merge_number' );
}

sub setItemSellingPrice
{
    my $class = shift;
    return $class->setAttribute( 'item_selling_price', shift );
}

sub getItemSellingPrice
{
    return $_[0]->getAttribute( 'item_selling_price' );
}

sub setItemBrokenRange
{
    my $class = shift;
    return $class->setAttribute( 'item_broken_range', shift );
}

sub getItemBrokenRange
{
    return $_[0]->getAttribute( 'item_broken_range' );
}

sub setItemBrokenRate
{
    my $class = shift;
    return $class->setAttribute( 'item_broken_rate', shift );
}

sub getItemBrokenRate
{
    return $_[0]->getAttribute( 'item_broken_rate' );
}

sub setUseEffectValue
{
    my $class = shift;
    return $class->setAttribute( 'use_effect_value', shift );
}

sub getUseEffectValue
{
    return $_[0]->getAttribute( 'use_effect_value' );
}

sub setUseEffectTarget
{
    my $class = shift;
    return $class->setAttribute( 'use_effect_target', shift );
}

sub getUseEffectTarget
{
    return $_[0]->getAttribute( 'use_effect_target' );
}

sub setUseEffectRange
{
    my $class = shift;
    return $class->setAttribute( 'use_effect_range', shift );
}

sub getUseEffectRange
{
    return $_[0]->getAttribute( 'use_effect_range' );
}


sub toUse
{
    # g‚¦‚È‚¢
#    return undef;
    return $_[0]->getAttribute( 'to_use' );
}

sub toBattleUse
{
    # g‚¦‚È‚¢
    return undef;
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
