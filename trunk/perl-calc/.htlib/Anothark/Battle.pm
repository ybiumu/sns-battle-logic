package Anothark::Battle;
#
# 愛
#
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

use Anothark::Battle::BaseValue;
use Anothark::Battle::TargetValue;
use Anothark::Battle::StatusValue;

our $base   = new Anothark::Battle::BaseValue();
our $status = new Anothark::Battle::StatusValue();
our $target_value = new Anothark::Battle::TargetValue();

my $battle_end = undef;
my $logger = undef;
my $order = undef;
my $turn_text = undef;
my $living_order = undef;
my $party_name = undef;
my $party_img = undef;
my $current_turn = undef;
my $current_actor = undef;
my $beat_flag = undef;

my $stat_template = '<span style="color:%s">%s%s&nbsp;[%s]&nbsp;</span>%s<br />HP:%s/%s<br />';
my $act_template = '<div style="text-align:%s;color:%s;">%s%s</div>';
my $cmd_template = '<div style="text-align:%s;color:%s;" class="act_%s" >%s%s!</div>';
my $target_template = '<div style="text-align:%s">⇒%s</div>';
my $effect_template = '<div style="text-align:%s">%s</div>';
my $dmg_str_template = '[%s]%s!';
my $effect_str_template = '%s!';

my $symbol = {
    e => {
        head      => "■",
        head_nml  => "",
        head_pri  => "▼",
        head_cut  => "▲",
        head_pas  => "∵",
        align => "right",
        color => "#00004f",
    },
    p => {
        head      => "□",
        head_nml  => "",
        head_pri  => "▽",
        head_cut  => "△",
        head_pas  => "∵",
        align => "left",
        color => "#ff0000",
    },
};
my $side_value = {
    e => 1,
    p => 2,
};
my $target_map = {
    e => { e => "p", p => "e" },   
    p => { e => "e", p => "p" },   
};

my $effect_str = {
    0 => {0 => "ﾀﾞﾒｰｼﾞ", 1 => "回復"},
    1 => {0 => "回復",   1 => "ﾀﾞﾒｰｼﾞ"},
    2 => {0 => "",       1 => ""},
    3 => {0 => "罠を仕掛けた" , 1 => "罠を仕掛けた"},
    4 => {0 => "呪詛を仕掛けた" , 1 => "呪詛を仕掛けた"},
    5 => {0 => "", 1 => ""},
    6 => {0 => "", 1 => ""} 
};

sub new
{
    my $class = shift;
    my $logger = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

    $self->init();
    $self->setLogger($logger);
    return $self;
}

sub init
{
    my $class = shift;
    $class->setBattleEnd(0);
    $class->setCharacter({});
    $class->setTurnText([]);
    $class->setBeatFlag( { p => 0, e => 0 } );
    $class->setPartyName("ななし");
    $class->setPartyImg("load_king");
    $class->setCurrentTurn(0);
    $class->initCurrentActor();
#    $class->setPs(0);
#    $class->setSr(0);
#    $class->setMainExpr(0);
#    $class->setSubExpr(0);
#    $class->setExprType(0);
#    $class->setRange(1.0);
#    $class->setRand(0);
}

sub setCharacter
{
    my $class = shift;
    return $class->setAttribute( 'character', shift );
}

sub getCharacter
{
    return $_[0]->getAttribute( 'character' );
}


sub setCurrentTurn
{
    my $class = shift;
    return $class->setAttribute( 'current_turn', shift );
}

sub getCurrentTurn
{
    return $_[0]->getAttribute( 'current_turn' );
}


sub initCurrentActor
{
    my $class = shift;
    return $class->setAttribute( 'current_actor', [] );
}

sub setCurrentActor
{
    my $class = shift;
    return push(@{$class->getAttribute( 'current_actor')}, shift );
}

sub getCurrentActor
{
    return @{$_[0]->getAttribute( 'current_actor' )}[-1];
}

sub popCurrentActor
{
    pop(@{$_[0]->getAttribute( 'current_actor' )})
}

sub appendCharacter
{
    my $class = shift;
    my $char = $class->getCharacter();
    my $obj = shift;
    if ( ref $obj eq "Anothark::Character" )
    {
        $char->{$obj->getId()} = $obj;
    }
    else
    {
        $class->logger()->output_log("Not a Anothark::Character object.");
    }

}



sub setOrder
{
    my $class = shift;
    return $class->setAttribute( 'order', shift );
}

sub getOrder
{
    return $_[0]->getAttribute( 'order' );
}


sub execActOrder
{
    my $class = shift;
    my $turn  = shift;
    my $char = $class->getCharacter();
#    $class->setOrder( [ map { $char->{$_} } sort { $char->{$a}->getTotalAgility($turn) <=> $char->{$b}->getTotalAgility($turn) } keys %{$char} ] );
    $class->setOrder( [ map { $char->{$_} } sort { $char->{$a}->getTotalAgility($turn) <=> $char->{$b}->getTotalAgility($turn) } @{$class->getLiving()} ] );

}


sub setLivingOrder
{
    my $class = shift;
    return $class->setAttribute( 'living_order', shift );
}

sub getLivingOrder
{
    return $_[0]->getAttribute( 'living_order' );
}

sub getLiving
{
    my $class = shift;
    my $char = $class->getCharacter();
    $class->setLivingOrder([ sort { $side_value->{$char->{$b}->getSide()} <=> $side_value->{$char->{$a}->getSide()} } grep { $char->{$_}->isLiving() } keys %{$char} ]);
}


sub getLivingTargets
{
    my $class = shift;
    my $side  = shift;
    my $char = $class->getCharacter();
    $class->setLivingOrder([ grep { $char->{$_}->getSide() eq $side } grep { $char->{$_}->getHp()->current() > 0 } keys %{$char} ]);
}

sub getLivingTargetsWithState
{
    my $class  = shift;
    my $from   = shift;
    my $skill  = shift;
    my $char = $class->getCharacter();
    $class->setLivingOrder([ grep{ ( isReach( $from, $char->{$_}, $skill->getLengthType() , $class) ) } grep {
        ($skill->getTargetType() == 3 ? 1 : ( $skill->getTargetType() == 1 ?
            $char->{$_}->getSide() eq $from->getReverseSide() : $char->{$_}->getSide() eq $from->getSide())
        )
    } grep { $char->{$_}->getHp()->current() > 0 } keys %{$char} ]);
}



sub getLivingPlayers
{
    my $class  = shift;
    my $char = $class->getCharacter();
    $class->setLivingOrder([ grep { $char->{$_}->getSide() eq "p" } grep { $char->{$_}->isLiving() } keys %{$char} ]);
}


sub getLivingFrontPlayers
{
    my $class  = shift;
    my $char = $class->getCharacter();
    $class->setLivingOrder([ map { $char->{$_}->getPosition()->cv() eq "f" } @{$class->getLivingPlayers()} ]);
}



sub getLivingCharactersBySide
{
    my $class  = shift;
    my $side   = shift;
    my $char   = $class->getCharacter();
    $class->setLivingOrder([ grep { $char->{$_}->getSide() eq $side } grep { $char->{$_}->isLiving() } keys %{$char} ]);
}


sub getLivingFrontCharactersBySide
{
    my $class  = shift;
    my $side   = shift;
    my $char   = $class->getCharacter();
    $class->setLivingOrder([ map { $char->{$_}->getPosition()->cv() eq "f" } @{$class->getLivingCharactersBySide($side)} ]);
}


sub resolveDamages
{
    my $class  = shift;
    my $target = shift;
    my $turn   = $class->getCurrentTurn();
    my $char   = $class->getCurrentActor();
    my $skill  = $char->getCmd()->[$turn];
    # Target
    $class->getTurnText()->[$turn] .= sprintf($target_template, $symbol->{$char->getSide()}->{align},$target->getName());


    # Interlapt Check
    # Interlapt cmd


    return if $class->battleEnd();
    ##  Do Damages ##
    # Search effect range.
    # Dmg
    my $dmg = $class->damageExec($char, $target );
    if ( $dmg == 0 )
    {
        $class->getTurnText()->[$turn] .= sprintf(
                                                $effect_template,
                                                $symbol->{$char->getSide()}->{align},
                                                sprintf($effect_str_template, "効果なし")
                                          );
    }
    else
    {
        $class->getTurnText()->[$turn] .= sprintf(
                                                $effect_template,
                                                $symbol->{$char->getSide()}->{align},
                                                sprintf($dmg_str_template, $skill->getBaseElementName(), ( $dmg . $effect_str->{$skill->getEffectType()}->{ $dmg > 0 ? 0 : 1 } ))
                                          );
    }
    $target->Damage( $dmg * ($skill->getEffectType() eq 1 ? -1 : 1) );
    if( not $target->isLiving() )
    {
        $class->getTurnText()->[$turn] .= sprintf(
                                            $effect_template,
                                            $symbol->{$char->getSide()}->{align}, "　⇒⇒倒れた")
    }
}


sub getSameRangeTargets
{
    my $class  = shift;
    my $target = shift;
    my $char   = $class->getCharacter();
    $class->setLivingOrder([ grep { $char->{$_}->getPoint() == $target->getPoint() } @{$class->getLiving()} ]);
}

#sub getSameRangeTargets
#{
#    my $class = shift;
#    my $char  = shift;
#
#    my $side  = $char->getSide(); # ﾀｰｹﾞｯﾄが所属するSide
#    my $target_type = shift; #1 enemy ,2 self,3 all # ﾀｰｹﾞｯﾄから見た相対的
#    # 1 の時(enemy)
#    #   1. side -> e
#    #    e is true
#    #    p is false
#    #   2. side -> p
#    #    e is false
#    #    p is true
#    #
#    # 2 の時(self)
#    #   1. side -> e
#    #    e is false
#    #    p is true
#    #   2. side -> p
#    #    e is false
#    #    p is true
#    #
#    my $range = shift; # 1 single, 2 same, 3, all
#
#    my $char  = $class->getCharacter();
#}

sub having_bit
{
    my $k = shift;
    my $s = shift;
    return ($s == (hex($k) & $s) ? 1 : 0 ) 
}

sub doBattle
{
    my $class = shift;

    my $chars = $class->getCharacter();
    my $enemy_party = $class->getPartyName();
    my $enemy_img = $class->getPartyImg();

    $class->getTurnText()->[0] = sprintf(
        "<div class=\"contents_e1\">%s</div><img src=\"img/%s.jpg\" />",
        $enemy_party,
        $enemy_img
    );
    foreach my $turn  ( 1 .. 5 )
    {

        #doTurn
        $class->doTurn($turn);
#{
#        $class->setCurrentTurn($turn);
#        $class->getTurnText()->[$turn] .= "<hr /><div style=\"text-align:center;color:#ff0000;\">Turn $turn</div>";
#        warn "[$turn]";
#        foreach my $cs ( @{$class->getLiving()} )
#        {
#            # status
#            $class->getTurnText()->[$turn] .= sprintf(
#                $stat_template,
#                $symbol->{$chars->{$cs}->getSide()}->{color},
#                $symbol->{$chars->{$cs}->getSide()}->{head},
#                $chars->{$cs}->getName(), $chars->{$cs}->getPointStr(), "",
#                $chars->{$cs}->getHp()->current(),
#                $chars->{$cs}->getHp()->max(),
#            )
#        }
#
#        my $order = $class->execActOrder($turn);
#        foreach my $char ( @{$order}  )
#        {
#            # Name
#            next if ( not $char->isLiving() );
#            $class->getTurnText()->[$turn] .= sprintf(
#                $act_template,
#                $symbol->{$char->getSide()}->{align},
#                $symbol->{$char->getSide()}->{head},
#                $char->getName(),
#            );
#warn "Name: [".$char->getName()."] の ﾀｰｹﾞｯﾃｨﾝｸﾞ";
## cmd start
#            # Cmd
#            $class->getTurnText()->[$turn] .= sprintf(
#                $cmd_template,
#                $symbol->{$char->getSide()}->{align},
#                $symbol->{$char->getSide()}->{head_nml},
#                $char->getCmd()->[$turn]->getName(),
#            );
#if ($char->getCmd()->[$turn]->getRangeTypw() eq "3" )
#{
#}
#else
#{
#            # Targeting
#
#            my @target_order = (
#                sort {
#                    $chars->{$b}->getTargetingValue(
#                        getRealDamage($char->getCmd()->[$turn]->getSkillRate(), $chars->{$b}->gDef()->cv()), $char->gCkk()->cv(), $char->gKky()->cv()
#                    )
#                    <=>
#                    $chars->{$a}->getTargetingValue(
#                        getRealDamage($char->getCmd()->[$turn]->getSkillRate(), $chars->{$a}->gDef()->cv() ) , $char->gCkk()->cv(), $char->gKky()->cv()
#                    )
#                    or $chars->{$a}->getId() <=> $chars->{$b}->getId()
#                } @{$class->getLivingTargetsWithState( $char,$char->getCmd()->[$turn] )}
#            );
#
#
#            if (scalar(@target_order))
#            {
#                my $target = $chars->{$target_order[0]};
#                # Target
#                $class->getTurnText()->[$turn] .= sprintf($target_template, $symbol->{$char->getSide()}->{align},$target->getName());
#
#
#                # Interlapt Check
#                # Interlapt cmd
#
#
#                ##  Do Damages ##
#                # Search effect range.
#                # Dmg
#                my $dmg = getRealDamage($char->getCmd()->[$turn]->getSkillRate(), $target->gDef()->cv() );
#                $class->getTurnText()->[$turn] .= sprintf(
#                                                        $effect_template,
#                                                        $symbol->{$char->getSide()}->{align},
#                                                        sprintf($effect_str_template, $char->getCmd()->[$turn]->getBaseElementName(), ( $dmg . "ﾀﾞﾒｰｼﾞ"))
#                                                  );
#                $target->Damage( $dmg );
#                if( not $target->isLiving() )
#                {
#                    $class->getTurnText()->[$turn] .= sprintf(
#                                                        $effect_template,
#                                                        $symbol->{$char->getSide()}->{align}, "　⇒⇒倒れた")
#                }
#
#            }
#            else
#            {
#                $class->getTurnText()->[$turn] .= sprintf($effect_template, $symbol->{$char->getSide()}->{align},sprintf( $effect_str_template, "届かない"));
#            }
#
#}
#            # Post Effect Check
#            # Post Effect cmd
#
#            # Win Lose check
#            # last if end;
#
#
#            foreach my $side ( sort{ $side_value->{$b} <=> $side_value->{$a} } keys %{$side_value} )
#            {
#                # Point Check
#                if ( not scalar($class->getLivingCharactersBySide($side)) )
#                {
#                    map { $chars->{$_}->setPosition("f") } $class->getLivingFrontCharactersBySide($side);
#                }
#            }
##            if( $char->getSide() eq "p" )
##            {
##                # Point Check
##                if ( not scalar($class->getLivingFrontPlayers()) )
##                {
##                    map { $chars->{$_}->setPosition("f") } $class->getLivingPlayers();
##                }
##            }
#
## cmd end
#
#
#        }
#}
        last if $class->battleEnd();
    }

    $class->resultCheck();

}


sub resultCheck
{
    my $class = shift;
    my $result_str = "--DRAW--";
    if ( $class->getBeatFlag()->{"e"} eq "1" && $class->getBeatFlag()->{"p"})
    {
        #DRAW
        $class->draw();
    }
    elsif( $class->getBeatFlag()->{"e"} eq "1" )
    {
        #WIN
        $class->win();
    }
    elsif( $class->getBeatFlag()->{"p"} eq "1" )
    {
        #LOSE
        $class->lose();
    }
    else
    {
        #DRAW
        $class->draw();
    }
}



sub draw
{
    return $_[0]->setResultFlag(-1);
}

sub lose
{
    return $_[0]->setResultFlag(0);
}

sub win
{
    return $_[0]->setResultFlag(1);
}

sub isWin
{
    return ( $_[0]->getResultFlag() == 1 ? 1 : 0 );
}

sub isDraw
{
    return ( $_[0]->getResultFlag() == -1 ? 1 : 0 );
}

my $result_flag = undef;
sub setResultFlag
{
    my $class = shift;
    return $class->setAttribute( 'result_flag', shift );
}

sub getResultFlag
{
    return $_[0]->getAttribute( 'result_flag' );
}




sub doTurn
{
    my $class = shift;
    my $fin  = 0;
    my $turn = shift;
    my $chars = $class->getCharacter();
    $class->setCurrentTurn($turn);
    $class->getTurnText()->[$turn] .= "<hr /><div style=\"text-align:center;color:#ff0000;\">Turn $turn</div>";
#    warn "[$turn]";

    foreach my $cs ( @{$class->getLiving()} )
    {
        # status
        $class->getTurnText()->[$turn] .= sprintf(
            $stat_template,
            $symbol->{$chars->{$cs}->getSide()}->{color},
            $symbol->{$chars->{$cs}->getSide()}->{head},
            $chars->{$cs}->getName(), $chars->{$cs}->getPointStr(), "",
            $chars->{$cs}->getHp()->current(),
            $chars->{$cs}->getHp()->max(),
        )
    }

    my $order = $class->execActOrder($turn);
    foreach my $char ( @{$order}  )
    {
        # Name
        next if ( not $char->isLiving() );
        $class->setCurrentActor($char);
        $class->doTurnCmd();

        last if $class->battleEnd()
    }
}





sub doTurnCmd
{
    my $class = shift;
    my $turn  = $class->getCurrentTurn();
    my $char  = $class->getCurrentActor();
    $class->getTurnText()->[$turn] .= sprintf(
        $act_template,
        $symbol->{$char->getSide()}->{align},
        $symbol->{$char->getSide()}->{color},
        $symbol->{$char->getSide()}->{head},
        $char->getName(),
    );

    $class->doCmd( $char );


    my $chars = $class->getCharacter();

    # Living forward check
    foreach my $side ( sort{ $side_value->{$b} <=> $side_value->{$a} } keys %{$side_value} )
    {
        # Point Check
        if ( not scalar($class->getLivingCharactersBySide($side)) )
        {
            map { $chars->{$_}->setPosition("f") } $class->getLivingFrontCharactersBySide($side);
        }
    }
}

sub doPrepareCmd
{
    my $class = shift;
    $class->doCmd();
}

sub doCmd
{
    my $class = shift;
    my $char  = shift;
    my $turn  = $class->getCurrentTurn();
    my $chars = $class->getCharacter();
#    warn "Name: [".$char->getName()."] の ﾀｰｹﾞｯﾃｨﾝｸﾞ";
# cmd start
    # Cmd
    $class->getTurnText()->[$turn] .= sprintf(
        $cmd_template,
        $symbol->{$char->getSide()}->{align},
        $symbol->{$char->getSide()}->{color},
        $symbol->{$char->getSide()}->{head_nml},
        $char->getCmd()->[$turn]->getName(),
    );

    if ($char->getCmd()->[$turn]->getRangeType() eq "3" )
    {
        map { $class->resolveDamages($chars->{ $_ }); } @{$class->getLivingTargetsWithState( $char,$char->getCmd()->[$turn] )};
    }
    else
    {
        # Targeting

        my @target_order = (
            sort {
                $chars->{$b}->getTargetingValue(
                    $class->damageExec( $char, $chars->{$b} ), $char->gCkk()->cv(), $char->gKky()->cv()
#                    getRealDamage($char->getCmd()->[$turn]->getSkillRate(), $chars->{$b}->gDef()->cv()), $char->gCkk()->cv(), $char->gKky()->cv()
                )
                <=>
                $chars->{$a}->getTargetingValue(
                    $class->damageExec( $char, $chars->{$a} ) , $char->gCkk()->cv(), $char->gKky()->cv()
#                    getRealDamage($char->getCmd()->[$turn]->getSkillRate(), $chars->{$a}->gDef()->cv() ) , $char->gCkk()->cv(), $char->gKky()->cv()
                )
                or $chars->{$a}->getId() <=> $chars->{$b}->getId()
            } @{$class->getLivingTargetsWithState( $char,$char->getCmd()->[$turn] )}
        );


        if (scalar(@target_order))
        {
            # each targets
            if ( $char->getCmd()->[$turn]->getRangeType() eq "1" )
            {
#                warn "range type 1";
                my $target = $chars->{$target_order[0]};
                $class->resolveDamages($target);
                # Target
            }
            elsif( $char->getCmd()->[$turn]->getRangeType() eq "2" )
            {
#                warn "range type 2";
                my $target = $chars->{$target_order[0]};
                map { $class->resolveDamages($chars->{ $_ }); } @{$class->getSameRangeTargets($target)};
                
            }
            else
            {
                $class->getTurnText()->[$turn] .= sprintf("なんかエラー");
            }

        }
        else
        {
            $class->getTurnText()->[$turn] .= sprintf($effect_template, $symbol->{$char->getSide()}->{align},sprintf( $effect_str_template, "届かない"));
        }

    }
    # Post Effect Check
    # Post Effect cmd

    # Win Lose check
    # last if end;
    my $livings = $class->getLivingCharactersBySide($char->getReverseSide());
    if ( not scalar(@{$livings}))
    {
        $class->setBattleEnd(1);
        $class->getBeatFlag()->{$char->getReverseSide()} = 1;
    }

    $livings = $class->getLivingCharactersBySide($char->getSide());
    if ( not scalar(@{$livings}))
    {
        $class->setBattleEnd(1);
        $class->getBeatFlag()->{$char->getSide()} = 1;
    }


# cmd end
}




sub setBeatFlag
{
    my $class = shift;
    return $class->setAttribute( 'beat_flag', shift );
}

sub getBeatFlag
{
    return $_[0]->getAttribute( 'beat_flag' );
}


sub setBattleEnd
{
    my $class = shift;
    return $class->setAttribute( 'battle_end', shift );
}

sub getBattleEnd
{
    return $_[0]->getAttribute( 'battle_end' );
}

sub battleEnd
{
    return $_[0]->getBattleEnd();
}

sub setPartyImg
{
    my $class = shift;
    return $class->setAttribute( 'party_img', shift );
}

sub getPartyImg
{
    return $_[0]->getAttribute( 'party_img' );
}



sub setPartyName
{
    my $class = shift;
    return $class->setAttribute( 'party_name', shift );
}

sub getPartyName
{
    return $_[0]->getAttribute( 'party_name' );
}


sub setLogger
{
    my $class = shift;
    return $class->setAttribute( 'logger', shift );
}

sub getLogger
{
    return $_[0]->getAttribute( 'logger' );
}


sub logger
{
    return $_[0]->getLogger();
}


sub setTurnText
{
    my $class = shift;
    return $class->setAttribute( 'turn_text', shift );
}

sub getTurnText
{
    return $_[0]->getAttribute( 'turn_text' );
}

sub editTurnText
{
    my $class = shift;
    return $class->getTurnText()->[$class->getCurrentTurn()];
}

sub getBattleText
{
    my $class = shift;
    return join("\n",@{$class->getTurnText()});
}

sub getResultText
{
    my $class = shift;
    return "<center>YouWin!</center><br /><center>************</center><br />";
}

sub damageExec
{
    my $class = shift;
    my $from  = shift;
    my $to    = shift;

    my $turn  = $class->getCurrentTurn();
    my $skill = $from->getCmd()->[$turn];

    $base->setPs(1);
    $base->setSr( $skill->getSkillRate() );
    $base->setMainExpr(0);
    $base->setSubExpr(0);
    $base->setExprType(1);
    $base->setRange( $base->RANGE_MAP->{$skill->getRangeTypeStr()} );
    $base->setRand($skill->getRandomAlias());




    $status->setMainRegist(0);
    $status->setSubRegist(0);
    $status->setRegistType(0);
    $status->setSeedRateType(0);
    $status->setStatMatchNum(0);
    $status->setStone(0);
    $status->setSleep(0);
    $status->setSerialRegist(0);

    $target_value->setConcent(0);
    $target_value->setPlaceVal(0);
    $target_value->setPlaceVector(1);
    $target_value->setChain(1);

    my $tmp_value = $base->calc() * $status->calc() * $target_value->calc();
#    warn sprintf "Damage [%s/%s/%s]",$base->calc(), $status->calc(), $target_value->calc();

    return getRealDamage( $tmp_value, $to->gDef()->cv(), 1 );
#    return getRealDamage( $skill->getSkillRate(), $to->gDef()->cv(), 0 ); 耐性は仮の値
}

sub getRealDamage
{
#    return getRealDamageSimple(@_);
    return calcDeffence(@_);
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
    my $tmp_value  = shift;
    my $ap         = shift;
    my $tmp_regist = shift;
    return 0 if ( $tmp_regist == 0 );
    my $value = sprintf "%d", ($tmp_value - ( ( abs($tmp_value) < abs($ap/2) ? $tmp_value : ($ap/2)) * ( $tmp_regist / abs( $tmp_regist) ) ) );
#    warn " Result -> [$value]";
    return $value;
}

sub isReach
{
    my $from = shift;
    my $to   = shift;
    my $len  = shift;
    my $class = shift;
    my $result = ( sqrt(($from->getPoint() - $to->getPoint())**2) <= $len );
#    $class->getTurnText->[6] .= sprintf(
#        "from: %s, to: %s, len: %s, result: %s, fcv: %s, tcv: %s<br />\n",
#        $from->getName(), $to->getName(), $len, $result, $from->getPoint(), $to->getPoint()
#    );
    return $result;
}
1;
