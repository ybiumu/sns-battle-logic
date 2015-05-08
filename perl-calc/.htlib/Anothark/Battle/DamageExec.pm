package Anothark::Battle::DamageExec;
#
# 愛
#
$|=1;
use strict;

use LoggingObjMethod;
use base qw( LoggingObjMethod );

use Anothark::Battle::BaseValue;
use Anothark::Battle::TargetValue;
use Anothark::Battle::StatusValue;

our $base   = new Anothark::Battle::BaseValue();
our $status = new Anothark::Battle::StatusValue();
our $target_value = new Anothark::Battle::TargetValue();

sub new
{
    my $class = shift;
    my $from  = shift;
    my $to    = shift;
    my $skill = shift;

    my $self = $class->SUPER::new();
    bless $self, $class;

#    $self->init();
    $self->setFrom($from);
    $self->setTo($to);
    $self->setSkill($skill);
    return $self;
}



my $from = undef;
sub setFrom
{
    my $class = shift;
    return $class->setAttribute( 'from', shift );
}

sub getFrom
{
    return $_[0]->getAttribute( 'from' );
}

my $to = undef;
sub setTo
{
    my $class = shift;
    return $class->setAttribute( 'to', shift );
}

sub getTo
{
    return $_[0]->getAttribute( 'to' );
}

my $skill = undef;
sub setSkill
{
    my $class = shift;
    return $class->setAttribute( 'skill', shift );
}

sub getSkill
{
    return $_[0]->getAttribute( 'skill' );
}



sub damageExec
{
    my $class = shift;

    my $from  = $class->getFrom();
    my $to    = $class->getTo();
    my $skill = $class->getSkill();

    return $class->damageExecBase( $from, $to, $skill );
}

sub damageExecBase
{
    # 後解決の呪詛なども検討しないといけない
    # シリーズも
    my $class = shift;

    my $from  = shift;
    my $to    = shift;
    my $skill = shift;

{
    $class->warning( sprintf("
    [Char]     : %s
    [SkillName]: %s
    [PSname]   : %s
    [Value]    : %s
    [rate]     : %s
    [Id]       : %s/%s
    [RT]       : %s
    [ELEM]     : %s/%s
    [TYPE]     : %s/%s
    ",
     $from->getName(),
     $skill->getSkillName(),
     $skill->getPowerSourceByKey(),
     $from->getAttribute($skill->getPowerSourceByKey())->cv(),
     $skill->getSkillRate(),
     $skill->getSkillId(), $skill->getParentSkillId(),
     $from->getConcentration()->cv(),
     $skill->getBaseElement(),$skill->getSubBaseElement(),
     $skill->getTypeId(),$skill->getSubTypeId()
    ));
}
    $base->setPs( $from->getAttribute($skill->getPowerSourceByKey())->cv() );
    $base->setSr( $skill->getSkillRate() );
#    $base->setSubExpr(0);
#    $base->setMainExpr(0);
#    $base->setMainExpr( $from->getTypeExperiment( $skill->getBaseElement() ) );
#    $base->setSubExpr( $from->getTypeExperiment( $skill->getSubBaseElement() ) );
    ## 攻撃属性ではなく熟練の話
    $base->setMainExpr( $from->getTypeExperiment( $skill->getTypeId() ) );
    $base->setSubExpr( $from->getTypeExperiment( $skill->getSubTypeId() ) );
    $base->setExprType(1);
    if ( $skill->getEffectType() == 1 )
    {
        $base->setRange( $base->RANGE_MAP->{$skill->getRangeTypeStr()} );
    }
    else
    {
        $base->setRange( 1.0 );
    }
    $base->setRand($skill->getRandomAlias());


{
    $class->warning( sprintf("
    ** REGIST **
    [ELEM]     : %s/%s
    [REGIST]   : %s/%s
    [REG_TYPE] : %s
    [SEEDTYPE] : %s
    ",
     $skill->getBaseElement(),$skill->getSubBaseElement(),
    $to->getRegistById( $skill->getBaseElement() )->cv(),
    $to->getRegistById( $skill->getSubBaseElement() )->cv(),
    $skill->getRegistType(),
    $skill->checkSeedRate( $to ),
    ));
}


    $status->setMainRegist( $to->getRegistById( $skill->getBaseElement() )->cv() );
    $status->setSubRegist( $to->getRegistById( $skill->getSubBaseElement() )->cv() );
    $status->setRegistType( $skill->getRegistType() );
    $status->setSeedRateType( $skill->checkSeedRate( $to ) );
    $status->setStatMatchNum(0);
    $status->setStone(0);
    $status->setSleep(0);
    $status->setSerialRegist(0);

    $target_value->setConcent( $from->getConcentration()->cv());
    $target_value->setPlaceVal(0);
    $target_value->setPlaceVector(1);
#    $target_value->setChain(1);
    $target_value->setChain(1 + $to->getChainStack() );

    my $tmp_value = $base->calc() * $status->calc() * $target_value->calc();
    $class->warning( sprintf "Damage [%s/%s/%s]",$base->calc(), $status->calc(), $target_value->calc());

    return $class->getRealDamage( $tmp_value, ( $skill->getEffectTargetType() == 3 ? $to->gDef()->cv()  : 0 ), 1 );
#    return getRealDamage( $skill->getSkillRate(), $to->gDef()->cv(), 0 ); 耐性は仮の値
}

sub getRealDamage
{
#    return getRealDamageSimple(@_);
    my $class = shift;
    return $class->calcDeffence(@_);
}

sub getRealDamageSimple
{
    my $dmg = shift;
    my $df  = shift;

    my $r   = $dmg - ( $df / 2 );
    return $r > 0 ? $r : 0;
}


sub calcDeffence
{
    my $class = shift;
    my $tmp_value  = shift;
    my $ap         = shift;
    my $tmp_regist = shift;
    return 0 if ( $tmp_regist == 0 );
    my $value = sprintf "%d", ($tmp_value - ( ( abs($tmp_value) < abs($ap/2) ? $tmp_value : ($ap/2)) * ( $tmp_regist / abs( $tmp_regist) ) ) );
    $class->warning( "   [CalResult] : $value");
    return $value;
}
1;
