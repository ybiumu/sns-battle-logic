package Anothark::Battle;
#
# 愛
#
$|=1;
use strict;

use Encode;

use LoggingObjMethod;
use base qw( LoggingObjMethod );

use Anothark::Skill;
use Anothark::Battle::DamageExec;
use Anothark::Character::Virtual;

use constant DEBUG => 1;

use constant BEFORE_START_TURN => "before_start_turn";
use constant BEFORE_CMD        => "before_cmd";
use constant AFTER_CMD         => "after_cmd";
use constant AFTER_TARGET      => "after_target";
use constant DAMAGED           => "damaged";


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
my $bgid = undef;
my $egid = undef;

my $stat_template = '<span style="color:%s">%s%s&nbsp;[%s]&nbsp;</span>%s<br />HP:%s/%s<br />';
my $debug_stat_template = '<span style="color:%s">%s%s&nbsp;[%s]&nbsp;</span>%s<br />HP:%s/%s(RT:%s/AT:%s/DF:%s[EXP:%s])<br />';
my $act_template = '<div style="text-align:%s;color:%s;">%s%s</div>';
my $delay_template = '<div style="text-align:center;color:#2faf2f;">%s%s</div>';
my $chain_template = '<div style="text-align:%s;color:#af2f2f;">-*&nbsp;%s連携&nbsp;*-</div>';
my $cmd_template = '<div style="text-align:%s;color:%s;" class="act_%s" >%s%s!</div>';
my $target_template = '<div style="text-align:%s">⇒%s</div>';
my $effect_template = '<div style="text-align:%s">%s</div>';
my $dmg_str_template = '[%s]%s!';
my $effect_str_template = '%s!';

my $debug_template = '<div style="text-align:center;border: solid black 1px;background-color:#afafaf">%s(%s/%s)</div>';

my $party_level = undef;

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
    n => {
        head      => "■",
        head_nml  => "",
        head_pri  => "▼",
        head_cut  => "▲",
        head_pas  => "∵",
        align => "center",
        color => "#2faf2f",
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
    2 => {1 => "減少",       0 => "増加"},
    3 => {0 => "罠を仕掛けた" , 1 => "罠を仕掛けた"},
    4 => {0 => "呪詛を仕掛けた" , 1 => "呪詛を仕掛けた"},
    5 => {0 => "", 1 => ""},
    6 => {0 => "", 1 => ""} 
};

my $iv_map = {
    0 => "raw_data",
    1 => "atack",
    2 => "magic",
    3 => "hp",
    4 => "agility",
    5 => "chikaku",
};



sub new
{
    my $class = shift;
    my $at = shift;
    my $logger = $at->getPageUtil();
    my $self = $class->SUPER::new();
    bless $self, $class;

#    $self->init();
    $self->setLogger($logger);
    $self->setAt($at);
    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setBattleEnd(0);
    $class->setCharacter({});
    $class->setTurnText([]);
    $class->setBeatFlag( { p => 0, e => 0 } );
    $class->setPartyName("ななし");
    $class->setPartyImg("load_king");
    $class->setPartyLevel("3");
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



my $at = undef;
sub setAt
{
    my $class = shift;
    return $class->setAttribute( 'at', shift );
}

sub getAt
{
    return $_[0]->getAttribute( 'at' );
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
    return pop(@{$_[0]->getAttribute( 'current_actor' )})
}



sub appendCharacter
{
    my $class = shift;
    my $char = $class->getCharacter();
    my $obj = shift;
    my $ref = ref $obj;
    if ( $ref =~ /^Anothark::Character(|::.+)$/ )
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


=pod
 execActOrder
 行動順決定ロジック
=cut
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

sub getDamaged
{
    my $class = shift;
    my $char = $class->getCharacter();
    return (
        map
        {
            $char->{$_}
        }
#        sort {
#            $side_value->{$char->{$b}->getSide()} <=> $side_value->{$char->{$a}->getSide()}
#        }
        grep {
            $char->{$_}->damaged()
        }
        keys %{$char}
    );
}

sub getTrapStacked
{
    my $class = shift;
    my $char = $class->getCharacter();
    return (
        map
        {
            $char->{$_}
        }
        grep {
            $char->{$_}->traped()
        }
        keys %{$char}
    );
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
    $class->setLivingOrder(
        [
            grep { # Can reach filter
                ( isReach( $from, $char->{$_}, $skill->getLengthType() , $class) )
            }
            grep { # Side filter
                ($skill->getTargetType() == 3 ?
                    1 : ( $skill->getTargetType() == 1 ?
                        $char->{$_}->getSide() eq $from->getReverseSide() : $char->{$_}->getSide() eq $from->getSide()
                    ) # 1(敵攻撃)の場合:逆サイドである事,2(見方攻撃の場合):同サイドである事
                )
            }
            grep { # Living Target filter
                $char->{$_}->getHp()->current() > 0
            }
            keys %{$char}
        ]
    );
}



sub getPlayers
{
    my $class  = shift;
    my $char = $class->getCharacter();
    return [ map {$char->{$_} } grep { $char->{$_}->isPlayer() } keys %{$char} ];
}
sub getPartyMember
{
    return $_[0]->getPlayers();
}


sub getLivingCharactersBySide
{
    my $class  = shift;
    my $side   = shift;
    my $char   = $class->getCharacter();
    $class->setLivingOrder([ grep { $char->{$_}->getSide() eq $side } grep { $char->{$_}->isLiving() } keys %{$char} ]);
}


sub getBeatCharactersBySide
{
    my $class  = shift;
    my $side   = shift;
    my $char   = $class->getCharacter();
    return [ grep { $char->{$_}->getSide() eq $side } grep { ! $char->{$_}->isLiving() } keys %{$char} ];
}


sub getLivingFrontCharactersBySide
{
    my $class  = shift;
    my $side   = shift;
    my $char   = $class->getCharacter();
    $class->setLivingOrder([ map { $char->{$_}->getPosition()->cv() eq "f" } @{$class->getLivingCharactersBySide($side)} ]);
}


sub resolveActions
{
    my $class  = shift;
    my $target = shift;
    my $skill  = shift;
    my $turn   = $class->getCurrentTurn();
#    my $char   = $class->getCurrentActor();
    my $char   = $class->getCurrentResolve();
#    my $skill  = $char->getCmd()->[$turn];

    # Target
    $class->getTurnText()->[$turn] .= sprintf($target_template, $symbol->{$char->getTextSide()}->{align},$target->getName());

    # Chain
    $class->getTurnText()->[$turn] .= sprintf($chain_template,  $symbol->{$char->getTextSide()}->{align},$target->getChainStack()+1) if ($target->getChainStack());


    # Interlapt Check
    # Interlapt cmd

    my $is_dmg = 0;

    return if $class->battleEnd();
    ##  Do Damages ##
    # Search effect range.
    # Dmg
    my $dmg_obj = new Anothark::Battle::DamageExec($char, $target, $skill );
    my $dmg = $dmg_obj->damageExec();
    if (! $skill->isSkill() )
    {
        if( $skill->getNoSkillType() == 4 ) # 移動
        {
            $class->getTurnText()->[$turn] .= sprintf(
                                                    $effect_template,
                                                    $symbol->{$char->getTextSide()}->{align},
                                                    sprintf($effect_str_template, "移動した")
                                              );
        }
        elsif ( $skill->getNoSkillType() == 3 ) # 集中
        {
            $class->getTurnText()->[$turn] .= sprintf(
                                                    $effect_template,
                                                    $symbol->{$char->getTextSide()}->{align},
                                                    sprintf($effect_str_template, "集中")
                                              );
        }
    }
    else
    {
        if ( $skill->getEffectType() eq "3" )
        {
            # Trapにスタック
            $class->getTurnText()->[$turn] .= sprintf(
                                                    $effect_template,
                                                    $symbol->{$char->getTextSide()}->{align},
                                                    sprintf($effect_str_template, "罠を仕掛けた")
                                              );
            $dmg_obj->setSkill( @{$skill->getChildren()}[0] );
            # この時点で詠唱者のステータスをコピー
            $dmg_obj->setFrom( new Anothark::Character::Virtual() );
            $dmg_obj->getFrom()->setBaseChar( $char );
            $dmg_obj->getFrom()->setSameCmd( $dmg_obj->getSkill() );
            $dmg_obj->getFrom()->setName( $skill->getName() );
            # 設置対象者のサイドを設定
            $dmg_obj->getFrom()->setSide( $target->getSide() );
            $dmg_obj->getFrom()->setTextSide( "n" );
            $target->getTrapStack()->stackOne($dmg_obj);
            $is_dmg = 1; # 熟練対象

            if ( DEBUG && $class->getAt()->{PLAYER}->getIsGm() )
            {
                $class->getTurnText()->[$turn]  .= sprintf(
                    $debug_template,
                    $dmg_obj->getFrom->getName(),
                    $dmg_obj->getSkill()->getPowerSourceByKey(),
                    $dmg_obj->getFrom()->getAttribute($dmg_obj->getSkill()->getPowerSourceByKey())->cv(),
                );
            }
        }
        elsif ( $skill->getEffectType() eq "4" )
        {
            # Curseになんかしらスタック
            $class->getTurnText()->[$turn] .= sprintf(
                                                    $effect_template,
                                                    $symbol->{$char->getTextSide()}->{align},
                                                    sprintf($effect_str_template, "呪詛を仕掛けた")
                                              );
            $dmg_obj->setSkill( @{$skill->getChildren()}[0] );
            # この時点で詠唱者のステータスをコピー
            $dmg_obj->setFrom( new Anothark::Character::Virtual() );
            $dmg_obj->getFrom()->setBaseChar( $char );
            $dmg_obj->getFrom()->setSameCmd( $dmg_obj->getSkill() );
            $dmg_obj->getFrom()->setName( $skill->getName() );
            # 設置対象者のサイドを設定
            $dmg_obj->getFrom()->setSide( $target->getSide() );
            $dmg_obj->getFrom()->setTextSide( "n" );
            $target->getCurseStack()->stackOne($dmg_obj);
            $is_dmg = 1; # 熟練対象

            if ( DEBUG && $class->getAt()->{PLAYER}->getIsGm() )
            {
                $class->getTurnText()->[$turn]  .= sprintf(
                    $debug_template,
                    $dmg_obj->getFrom->getName(),
                    $dmg_obj->getSkill()->getPowerSourceByKey(),
                    $dmg_obj->getFrom()->getAttribute($dmg_obj->getSkill()->getPowerSourceByKey())->cv(),
                );
            }
        }
        elsif ( $dmg == 0 )
        {
            $class->getTurnText()->[$turn] .= sprintf(
                                                    $effect_template,
                                                    $symbol->{$char->getTextSide()}->{align},
                                                    sprintf($effect_str_template, "効果なし")
                                              );
            $is_dmg = 1;
        }
        else
        {
            $class->getTurnText()->[$turn] .= sprintf(
                                                    $effect_template,
                                                    $symbol->{$char->getTextSide()}->{align},
                                                    sprintf(
                                                        $dmg_str_template,
                                                        $skill->getBaseElementName(),
                                                        ( ( ( $skill->getEffectType() == 0 && $skill->getEffectTargetType() == 3 ) ? "" : $skill->getEffectTargetLabel() ) . $dmg . $effect_str->{$skill->getEffectType()}->{ $dmg > 0 ? 0 : 1 } )
                                                        )
                                              );
            $is_dmg = 1;
        }
    }
#    $target->Damage( $dmg * ($skill->getEffectType() eq 1 ? -1 : 1) );
    $target->Damage( $skill,$dmg , $char );


    if( not $target->isLiving() )
    {
        $class->getTurnText()->[$turn] .= sprintf(
                                            $effect_template,
                                            $symbol->{$char->getTextSide()}->{align}, "　⇒⇒倒れた");
        $target->Die();
    }
    else
    {
        if ( $dmg > 0 )
        {
#            # ここで発動はしない。ダメージのフラグを載せるだけ
# フラグもやんない
            $class->chkScene(DAMAGED,{ char => $char });
        }
    }

    return $is_dmg;
}


# 連携の継続判定
sub continueChain
{
    my $class = shift;
    my $cmd   = shift;
    my @targets = @_;
    my $char   = $class->getCharacter();
    if ( $cmd->getEffectType() eq "3" || $cmd->getEffectType() eq "4" )
    {
        @targets = ();
    }

    my $targets = { map { $_ => 1 } @targets };
    map {
        if ( not exists $targets->{$char->{$_}->getId()} )
        {
            $char->{$_}->setResolveChainStack(0);
        }
        elsif( $char->{$_}->getChainStack() eq $char->{$_}->getResolveChainStack() )
        {
            $char->{$_}->setResolveChainStack(0);
        }
        $char->{$_}->setChainStack( $char->{$_}->getResolveChainStack() );
    } @{$class->getLiving()};
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


my $resolve_stack = undef;
my $current_resolve = undef;

sub initResolveStack
{
    my $class = shift;
    return $class->setAttribute( 'resolve_stack', [] );
}
sub pushResolveStack
{
    my $class = shift;
    return push( @{$class->getAttribute( 'resolve_stack')}, shift );
}

sub popResolveStack
{
    return pop(@{$_[0]->getAttribute( 'resolve_stack' )});
}



sub setCurrentResolve
{
    my $class = shift;
    return $class->setAttribute( 'current_resolve', shift );
}

sub getCurrentResolve
{
    return $_[0]->getAttribute( 'current_resolve' );
}



sub chkScene
{
    my $class = shift;
    my $scene = shift;
    my $opt   = shift;
    $class->chkEffect($scene, $opt);
    $class->chkCmdStack($scene, $opt);
    $class->chkClear($scene, $opt);
}

#
# $actions = {
#   DAMAGED   => sub { return $class->setStackCmd(@_) },
#   AFTER_CMD => sub { return $class->resolveStackCmd(@_) },
#
#
# }
#



sub chkEffect
{
    my $class = shift;
    my $scene = shift;
    my $opt   = shift;
#    if ( $scene eq DAMAGED && exists $opt->{char} )
#    {
#        $opt->{char}->setDamaged(1);
#    }
}

sub chkClear
{
    my $class = shift;
    my $scene = shift;
}

sub chkCmdStack
{
    my $class = shift;
    my $scene = shift;
    my $opt   = shift;
    # Stacking

    $class->error("[chkCmdStack] start.[$scene]");

#    if ( $scene eq AFTER_CMD && exists $opt->{char} )
    if ( $scene eq AFTER_CMD )
    {
        $class->error("[AFTER_CMD] start.");

        my @damaged = $class->getDamaged();
        my @traped  = $class->getTrapStacked();
        # 罠の対象者のリストアップだけは移動しないといけない

        # 呪詛のスタック解決
        foreach my $char ( @damaged )
        {
#            my $stack = $char->getStacks()->filter("curse");
            $class->error("[DAMAGED] " . $char->getName() . " start.");
            my $stack = $char->getResolveCurseStack();
            while( $stack->isRemain() )
            {
                my $res = $stack->resolveOne();
                $class->pushResolveStack($res);
                $class->doDelaiedCmd()

            }
            $class->error("[DAMAGED] " . $char->getName() . " done.");
        }

        # 罠のスタック解決
        foreach my $char ( @traped )
        {
#            my $stack = $char->getStacks()->filter("curse");
            $class->error("[TRAPED] " . $char->getName() . " start.");
            my $stack = $char->getResolveTrapStack();
            if ( $stack->isRemain() )
            {
                my $res = $stack->resolveOne();
                $class->pushResolveStack($res);
                $class->doDelaiedCmd()

            }
            $class->error("[TRAPED] " . $char->getName() . " done.");
        }

    }
#    $class->getActions()->{$scene}
    # resolve stacks
}









my $actions = undef;
sub setActions
{
    my $class = shift;
    return $class->setAttribute( 'actions', shift );
}

sub getActions
{
    return $_[0]->getAttribute( 'actions' );
}


sub doBattle
{
    my $class = shift;

    my $chars = $class->getCharacter();
    my $enemy_party = $class->getPartyName();
    my $enemy_img = $class->getPartyImg();
    my $bgid = $class->getBgid();
    my $egid = $class->getEgid();

    $class->getTurnText()->[0] = sprintf(
        "<div class=\"contents_e1\">%s</div><img class=\"dispimg\" src=\"img/%s.jpg\" />",
        $enemy_party,
        $enemy_img
    );

#    $class->getTurnText()->[0] = sprintf(
#        '<div class="contents_e1">%s</div><img class="dispimg" src="http://dummyimage.com/230x160/bbb/000.jpg&text=bgid_%05s.egid_%05s" />',
#        $enemy_party,
#        $bgid, $egid
#    );

    foreach my $turn  ( 1 .. 5 )
    {

        #doTurn

        $class->doTurn($turn);
        last if $class->battleEnd();
    }

    $class->resultCheck();

}


sub checkDropItems
{
    my $class = shift;
    $class->warning( "[CHECK]");
    my $beats = $class->getBeatCharactersBySide("e");
    return [ grep { $_->isDroped() } ( map { @{$class->getCharacter()->{$_}->getDropItems()} } @{$beats} )];
#    my $drops = [];
#    foreach my $item ( map { @{$class->getCharacter()->{$_}->getDropItems()} } @{$beats} )
#    {
#        $class->warning( sprintf "[ITEMS] %s",$item->getItemLabel());
#        if ( $item->isDroped() )
#        {
#            $class->warning( sprintf "[DROP] %s",$item->getItemLabel());
#            push( @{$drops}, $item);
#        }
#    }
#    return $drops;
}

sub checkExperiment
{
    my $class = shift;
    my $chk_str = "";
    foreach my $c ( @{$class->getPlayers()} )
    {
        my $cnts = $c->getUseElementCount();
        my $exp_values = {};
        foreach my $type ( sort keys %{$cnts})
        {
            # value
            my $type_exp = ( ( $class->getPartyLevel() - $c->getTypeLevel($type) > 10 ? 10 : $class->getPartyLevel() - $c->getTypeLevel($type) ) / 2) * ( $cnts->{$type} / $c->getElementTotalCount() );
            if ( $type_exp > 0 )
            {
                $exp_values->{$type} = $type_exp;
                # Str 
                $chk_str .= sprintf '%sは%sの熟練が%.2f上がった<br />',
                                $c->getName(),
                                Anothark::Skill::typeId2typeName($type),
                                $type_exp;
            }
        }
        # Save
        $c->getStatusIo()->updateExp($exp_values);
    }
    return $chk_str;
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
    $class->warning( "TURN [$turn]");

    # 毒とか
    $class->chkScene( BEFORE_START_TURN ); 

    if ( DEBUG )
    {
        foreach my $cs ( @{$class->getLiving()} )
        {
            # status
            my $c = $chars->{$cs};
            my $cnts = $c->getUseElementCount();
            $class->getTurnText()->[$turn] .= sprintf(
                $debug_stat_template,
                $symbol->{$chars->{$cs}->getTextSide()}->{color},
                $symbol->{$chars->{$cs}->getTextSide()}->{head},
                $chars->{$cs}->getName(), $chars->{$cs}->getPointStr(), "",
                $chars->{$cs}->getHp()->current(),
                $chars->{$cs}->getHp()->max(),
                $chars->{$cs}->getConcentration->cv(),
                $chars->{$cs}->getAtack()->cv(),
                $chars->{$cs}->getDefence()->cv(),
                join(
                    "/",
                    map
                    {
                        sprintf "%s(%s)->%s",
                            Anothark::Skill::typeId2typeName($_),
                            $_,
                            $cnts->{$_}
                    } sort keys %{$cnts}
                )
            )
            # Turnly concent;
        }
    }
    else
    {
        foreach my $cs ( @{$class->getLiving()} )
        {
            # status
            $class->getTurnText()->[$turn] .= sprintf(
                $stat_template,
                $symbol->{$chars->{$cs}->getTextSide()}->{color},
                $symbol->{$chars->{$cs}->getTextSide()}->{head},
                $chars->{$cs}->getName(), $chars->{$cs}->getPointStr(), "",
                $chars->{$cs}->getHp()->current(),
                $chars->{$cs}->getHp()->max(),
            )
            # Turnly concent;
        }
    }

    my $order = $class->execActOrder($turn);
    foreach my $char ( @{$order}  )
    {
        # Name
        next if ( not $char->isLiving() );
        $class->setCurrentActor($char);
        # アクティブ毎に解決スタックを初期化
        $class->initResolveStack();
        $class->pushResolveStack($char);
        $class->doTurnCmd();

        last if $class->battleEnd()
    }

    # refresh
    foreach my $cs2 ( @{$class->getLiving()} )
    {
        # Turnly concent;
        $chars->{$cs2}->getConcentration()->addCurrent( 10 );
    }
}





sub doTurnCmd
{
    my $class = shift;
    my $turn  = $class->getCurrentTurn();
#    my $char  = $class->getCurrentActor();
    my $char  = $class->setCurrentResolve($class->popResolveStack());
    $class->getTurnText()->[$turn] .= sprintf(
        $act_template,
        $symbol->{$char->getTextSide()}->{align},
        $symbol->{$char->getTextSide()}->{color},
        $symbol->{$char->getTextSide()}->{head},
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
            map { $chars->{$_}->getPosition()->setCurrentValue("f") } $class->getLivingFrontCharactersBySide($side);
        }
    }
}

sub doPrepareCmd
{
    my $class = shift;
    $class->doCmd();
}

# 罠とか呪詛とか遅発とか
sub doDelaiedCmd
{
    my $class    = shift;
    my $turn     = $class->getCurrentTurn();
    my $dmg_obj  = $class->popResolveStack();
    my $char     = $dmg_obj->getFrom();
    my $target   = $dmg_obj->getTo();
    $class->setCurrentResolve( $char );
    $class->error("[Delaied Char] " . ref $char );

    if ( $target->isLiving() )
    {
        $class->getTurnText()->[$turn] .= sprintf(
#        $delay_template, # TODO 呪詛用テンプレート作成
            $act_template, 
            $symbol->{$char->getTextSide()}->{align},
            $symbol->{$char->getTextSide()}->{color},
            $symbol->{$char->getTextSide()}->{head_pas},
            $char->getName(), #呪詛名と記号
        );

        $class->doCmd( $char, $target );


        my $chars = $class->getCharacter();

        # Living forward check
        foreach my $side ( sort{ $side_value->{$b} <=> $side_value->{$a} } keys %{$side_value} )
        {
            # Point Check
            if ( not scalar($class->getLivingCharactersBySide($side)) )
            {
                map { $chars->{$_}->getPosition()->setCurrentValue("f") } $class->getLivingFrontCharactersBySide($side);
            }
        }
    }
}

sub doCmd
{
    my $class = shift;
    my $char  = shift;
    my $force_target = shift || 0;
#    my $stacks = [];
    my $turn   = $class->getCurrentTurn();
    my $chars  = $class->getCharacter();



    my $text_pointer = \$class->getTurnText()->[$turn];
    my $cmd = $char->getCmd()->[$turn];

    # 連携継続とか、遅発とか
# ここか？ターゲッティング後じゃ？
    $class->chkScene( BEFORE_CMD, { cmd => $cmd } ); 

    if( $char->canMove() )
    {
        $class->doSkillUnitBase($char,$cmd,$text_pointer,$force_target );
    }
    else
    {
    }


    # Post Effect Check
    # Post Effect cmd

    # TODO
    # post effect

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


    # Exec after command;
#    # スタックとか乗せる前に
#    $class->popResolveStack();
    $class->chkScene( AFTER_CMD ); 

# cmd end
}


sub doPreTargeting
{
    my $class = shift;
    my $char  = shift;
    my $cmd   = shift;
    my $text_pointer = shift;
    my $force_target = shift || 0;
    my $chars  = $class->getCharacter();


    my @target_order = ();

#################
### TARGETING ###
#################

    # TODO
    #
    # 再帰的にターゲッティングをして、CUTを確定させないといけない
    #
    #

    # 全体攻撃
    if ($cmd->getRangeType() eq "3" )
    {
        # Do Not anything
    }
    # 自身攻撃
    elsif ($cmd->getRangeType() eq "4" )
    {
        # Do Not anything
    }
    # 単体・同列
    else
    {

        if ( $char->canTarget() )
        {
        }
        else
        {
#            $$text_pointer .= 'ﾌﾞﾗﾝｸで狙えない';
            return ;
        }

        my $dmg_obj = new Anothark::Battle::DamageExec();

        # 単体
        if ( $cmd->getRangeType() eq "1" )
        {
            if ( $force_target )
            {
                @target_order = ( $force_target->getId() );
            }
            else
            {
                # for single taggeting.
                @target_order = (
                    sort {
                        $chars->{$b}->getTargetingValue(
                            $dmg_obj->damageExecBase( $char, $chars->{$b} , $cmd), $char->gCkk()->cv(), $char->gKky()->cv()
                        )
                        <=>
                        $chars->{$a}->getTargetingValue(
                            $dmg_obj->damageExecBase( $char, $chars->{$a}, $cmd ) , $char->gCkk()->cv(), $char->gKky()->cv()
                        )
                        or $chars->{$a}->getId() <=> $chars->{$b}->getId()
                    } @{$class->getLivingTargetsWithState( $char,$cmd )}
                );
            }
        }
        # 同列
        elsif( $cmd->getRangeType() eq "2" )
        {
            if ( $force_target )
            {
                @target_order = (
                    grep {
#                        $class->error("$_/$force_target");
                        $chars->{$_}->getPoint()
                        eq
                        $chars->{$force_target->getId()}->getPoint()
                    }
                    @{$class->getLivingTargetsWithState( $char,$cmd )}
                );
            }
            else
            {
                my $td = { f => 0, b => 0};
                map {
                    $td->{$chars->{$_}->getPoint()} +=  $dmg_obj->damageExecBase( $char, $chars->{$_},$cmd ), $char->gCkk()->cv(), $char->gKky()->cv()
                } @{$class->getLivingTargetsWithState( $char,$cmd )};
                my $point = (sort { $td->{$b} <=> $td->{$a} } %{$td})[0];
                @target_order = (
                    grep {
                        $chars->{$_}->getPoint() eq $point
                    }
                    @{$class->getLivingTargetsWithState( $char,$cmd )}
                );
            }
        }

    }

    return @target_order;

}


sub doTargeting
{
    my $class = shift;
    my $char  = shift;
    my $cmd   = shift;
    my $text_pointer = shift;
    my $force_target = shift || 0;
    my $chars  = $class->getCharacter();


    my @target_order = ();

#################
### TARGETING ###
#################

    # TODO
    #
    # 再帰的にターゲッティングをして、CUTを確定させないといけない
    #
    #

    # 全体攻撃
    if ($cmd->getRangeType() eq "3" )
    {
        # Do Not anything
    }
    # 自身攻撃
    elsif ($cmd->getRangeType() eq "4" )
    {
        # Do Not anything
    }
    # 単体・同列
    else
    {

        if ( $char->canTarget() )
        {
        }
        else
        {
            $$text_pointer .= 'ﾌﾞﾗﾝｸで狙えない';
            return ;
        }

        my $dmg_obj = new Anothark::Battle::DamageExec();


        if ( $class->getAt()->{PLAYER}->getIsGm() )
        {
            $$text_pointer .= sprintf(
                $debug_template,
                $char->getName(),
                $cmd->getPowerSourceByKey(),
                $char->getAttribute($cmd->getPowerSourceByKey())->cv(),
            );
        }

        # 単体
        if ( $cmd->getRangeType() eq "1" )
        {
            if ( $force_target )
            {
                @target_order = ( $force_target->getId() );
            }
            else
            {
                # for single taggeting.
                @target_order = (
                    sort {
                        $chars->{$b}->getTargetingValue(
                            $dmg_obj->damageExecBase( $char, $chars->{$b} , $cmd), $char->gCkk()->cv(), $char->gKky()->cv()
                        )
                        <=>
                        $chars->{$a}->getTargetingValue(
                            $dmg_obj->damageExecBase( $char, $chars->{$a}, $cmd ) , $char->gCkk()->cv(), $char->gKky()->cv()
                        )
                        or $chars->{$a}->getId() <=> $chars->{$b}->getId()
                    } @{$class->getLivingTargetsWithState( $char,$cmd )}
                );
            }
        }
        # 同列
        elsif( $cmd->getRangeType() eq "2" )
        {
            if ( $force_target )
            {
                @target_order = (
                    grep {
#                        $class->error("$_/$force_target");
                        $chars->{$_}->getPoint()
                        eq
                        $chars->{$force_target->getId()}->getPoint()
                    }
                    @{$class->getLivingTargetsWithState( $char,$cmd )}
                );

                if ( $class->getAt()->{PLAYER}->getIsGm() )
                {
                    $$text_pointer .= sprintf(
                        $debug_template,
                        $char->getName(),
                        $force_target->getName(),
                        join(",", @{$class->getLivingTargetsWithState( $char,$cmd )}),
                    );
                }

            }
            else
            {
                my $td = { f => 0, b => 0};
                map {
                    $td->{$chars->{$_}->getPoint()} +=  $dmg_obj->damageExecBase( $char, $chars->{$_},$cmd ), $char->gCkk()->cv(), $char->gKky()->cv()
                } @{$class->getLivingTargetsWithState( $char,$cmd )};
                my $point = (sort { $td->{$b} <=> $td->{$a} } %{$td})[0];
                @target_order = (
                    grep {
                        $chars->{$_}->getPoint() eq $point
                    }
                    @{$class->getLivingTargetsWithState( $char,$cmd )}
                );
            }
        }

    }

    return @target_order;

}


sub doSkillUnitBase
{
    my $class = shift;
    my $char  = shift;
    my $cmd   = shift;
    my $text_pointer = shift;
    my $force_target = shift || 0;
    my $chars  = $class->getCharacter();

    #　　- ｽｷﾙ発動準備
    #　　　　- 仮効果算出
    #　　　　- 仮効果をもとにﾀｰｹﾞｯﾃｨﾝｸﾞ決定
    #　　　　- 仮効果をもとに割り込み処理
    #　　　　　　- ﾌﾟﾘﾍﾟｱｶｯﾄ
    #　　　　　　　　- [object:skill_flow]
    #　　　　- 遅発処理
    #　　　　　　[object:skill_flow]
    #　　　　- 
    #　　　　　　[object:skill_flow]
    #　　　　- phase in



    #　　- ｽｷﾙ発動
    #　　- ﾀｰｹﾞｯﾃｨﾝｸﾞ

    # Targeting

#    $$text_pointer .= sprintf(
#        $cmd_template,
#        $symbol->{$char->getTextSide()}->{align},
#        $symbol->{$char->getTextSide()}->{color},
#        $symbol->{$char->getTextSide()}->{head_nml},
#        $cmd->getName(),
#    );

    $class->warning( "Run Cmd id is [". $cmd->getSkillId() ."]");

#    my @target_order = ();
#
##################
#### TARGETING ###
##################
#
#    # 全体攻撃
#    if ($cmd->getRangeType() eq "3" )
#    {
#        # Do Not anything
#    }
#    # 自身攻撃
#    elsif ($cmd->getRangeType() eq "4" )
#    {
#        # Do Not anything
#    }
#    # 単体・同列
#    else
#    {
#
#        if ( $char->canTarget() )
#        {
#        }
#        else
#        {
#            $$text_pointer .= 'ﾌﾞﾗﾝｸで狙えない';
#            return ;
#        }
#
#        my $dmg_obj = new Anothark::Battle::DamageExec();
#
#        # 単体
#        if ( $cmd->getRangeType() eq "1" )
#        {
#            if ( $force_target )
#            {
#                @target_order = ( $force_target->getId() );
#            }
#            else
#            {
#                # for single taggeting.
#                @target_order = (
#                    sort {
#                        $chars->{$b}->getTargetingValue(
#                            $dmg_obj->damageExecBase( $char, $chars->{$b} , $cmd), $char->gCkk()->cv(), $char->gKky()->cv()
#                        )
#                        <=>
#                        $chars->{$a}->getTargetingValue(
#                            $dmg_obj->damageExecBase( $char, $chars->{$a}, $cmd ) , $char->gCkk()->cv(), $char->gKky()->cv()
#                        )
#                        or $chars->{$a}->getId() <=> $chars->{$b}->getId()
#                    } @{$class->getLivingTargetsWithState( $char,$cmd )}
#                );
#            }
#        }
#        # 同列
#        elsif( $cmd->getRangeType() eq "2" )
#        {
#            if ( $force_target )
#            {
#                @target_order = (
#                    grep {
##                        $class->error("$_/$force_target");
#                        $chars->{$_}->getPoint()
#                        eq
#                        $chars->{$force_target->getId()}->getPoint()
#                    }
#                    @{$class->getLivingTargetsWithState( $char,$cmd )}
#                );
#            }
#            else
#            {
#                my $td = { f => 0, b => 0};
#                map {
#                    $td->{$chars->{$_}->getPoint()} +=  $dmg_obj->damageExecBase( $char, $chars->{$_},$cmd ), $char->gCkk()->cv(), $char->gKky()->cv()
#                } @{$class->getLivingTargetsWithState( $char,$cmd )};
#                my $point = (sort { $td->{$b} <=> $td->{$a} } %{$td})[0];
#                @target_order = (
#                    grep {
#                        $chars->{$_}->getPoint() eq $point
#                    }
#                    @{$class->getLivingTargetsWithState( $char,$cmd )}
#                );
#            }
#        }
#
#    }



    my @target_order = $class->doPreTargeting( $char, $cmd, $text_pointer, $force_target);
    # 呪詛設置・罠設置以外は連携継続のチェック対象
    # TODO ここをもっと厚く
    $class->continueChain($cmd,@target_order);
    if ( $class->getAt()->{PLAYER}->getIsGm() )
    {
        map{
            $$text_pointer .= sprintf(
                $debug_template,
                $chars->{$_}->getName(),
                $chars->{$_}->getChainStack(),
                $chars->{$_}->getResolveChainStack(),
            );
        } @{$class->getLiving()};
    }
    # CUT 割り込み
    $class->chkScene( AFTER_TARGET, { cmd => $cmd } ); 
    $class->doSkillUnit( $char, $cmd, $text_pointer, $force_target);

}

sub doSkillUnit
{
    my $class = shift;
    my $char  = shift;
    my $cmd   = shift;
    my $text_pointer = shift;
    my $force_target = shift || 0;
    my $chars  = $class->getCharacter();

    #　　- ｽｷﾙ発動準備
    #　　　　- 仮効果算出
    #　　　　- 仮効果をもとにﾀｰｹﾞｯﾃｨﾝｸﾞ決定
    #　　　　- 仮効果をもとに割り込み処理
    #　　　　　　- ﾌﾟﾘﾍﾟｱｶｯﾄ
    #　　　　　　　　- [object:skill_flow]
    #　　　　- 遅発処理
    #　　　　　　[object:skill_flow]
    #　　　　- 
    #　　　　　　[object:skill_flow]
    #　　　　- phase in



    #　　- ｽｷﾙ発動
    #　　- ﾀｰｹﾞｯﾃｨﾝｸﾞ

    # Targeting

    $$text_pointer .= sprintf(
        $cmd_template,
        $symbol->{$char->getTextSide()}->{align},
        $symbol->{$char->getTextSide()}->{color},
        $symbol->{$char->getTextSide()}->{head_nml},
        $cmd->getName(),
    );

    $class->warning( "Run Cmd id is [". $cmd->getSkillId() ."]");



    my @target_order = $class->doTargeting( $char, $cmd, $text_pointer, $force_target);

#
#    # CUT 割り込み
#    $class->chkScene( AFTER_TARGET, { cmd => $cmd } ); 


########################
###  Resolve Damages ###
########################

#    $$text_pointer .= sprintf("[DEBUG]%s<br/>\n",$cmd->getEffectType());

    my $is_count = 0;

    # each effect 
    # 0:攻撃,1:回復,2:付与,3:罠,4:呪詛,5:シリーズ,6:ランダム
    # シリーズ
    if ( $cmd->getEffectType() eq "5" )
    {
        foreach my $child ( sort { $a->getSequenceId() <=> $b->getSequenceId() } @{ $cmd->getChildren()})
        {
            $is_count += $class->doSkillUnit($char,$child,$text_pointer);
        }
    }
    # ランダム
    elsif ( $cmd->getEffectType() eq "6" )
    {
        my $children = $cmd->getChildren();
        my $rnd = int( rand(scalar(@{$children})));
        $is_count += $class->doSkillUnit($char,$children->[$rnd],$text_pointer);
    }
#    # 呪詛
# XXX 呪詛もresolveActionsで受ける
#    elsif ( $cmd->getEffectType() eq "4" )
#    {
#        my $children = $cmd->getChildren();
#        # XXX set target
#    }
    # 罠
    elsif ( $cmd->getEffectType() eq "3" )
    {
        my $children = $cmd->getChildren();
        # XXX set target
    }
    # 他
    else
    {
        # 全体攻撃
        if ($cmd->getRangeType() eq "3" )
        {
            map {
                $is_count += $class->resolveActions($chars->{ $_ }, $cmd);
            } @{$class->getLivingTargetsWithState( $char,$cmd )};
        }
        # 自身攻撃
        elsif ($cmd->getRangeType() eq "4" )
        {
            $is_count += $class->resolveActions($char, $cmd);
        }
        # 単体・同列
        else
        {

            if (scalar(@target_order))
            {
                # each targets
                if ( $cmd->getRangeType() eq "1" )
                {
#                $class->warning( "range type 1");
                    my $target = $chars->{$target_order[0]};
                    $is_count += $class->resolveActions($target, $cmd);
                    # Target
                }
                elsif( $cmd->getRangeType() eq "2" )
                {
#                $class->warning( "range type 2");
                    my $target = $chars->{$target_order[0]};
                    map { $is_count += $class->resolveActions($chars->{ $_ }, $cmd); } @{$class->getSameRangeTargets($target)};
                    
                }
                else
                {
                    $$text_pointer .= sprintf("なんかエラー");
                }

            }
            else
            {
                $class->debug( "Not reached. 届かない! ");
                $class->debug( "XXX Stack dump XXX");
#                map { $class->debug($_); } @{$cmd->dump()};
                $$text_pointer .= sprintf($effect_template, $symbol->{$char->getTextSide()}->{align},sprintf( $effect_str_template, "届かない"));
            }
        }
    }




    my $raise_parent = 0;
    # 子供の処理
    if ( $cmd->getParentSkillId() ne "0" )
    {
        $raise_parent = $is_count;
        $is_count = 0;
        $class->warning( "No Count!");
    }

    # 最上位の処理
    if ( $cmd->getParentSkillId() eq "0" )
    {
        if ( $is_count )
        {
            $char->countupElementCount($cmd->getTypeId());
            $char->countupElementCount($cmd->getSubTypeId());
        }


    }

    return $raise_parent;

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



sub setPartyLevel
{
    my $class = shift;
    return $class->setAttribute( 'party_level', shift );
}

sub getPartyLevel
{
    return $_[0]->getAttribute( 'party_level' );
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



sub setBgid
{
    my $class = shift;
    return $class->setAttribute( 'bgid', shift );
}

sub getBgid
{
    return $_[0]->getAttribute( 'bgid' );
}


sub setEgid
{
    my $class = shift;
    return $class->setAttribute( 'egid', shift );
}

sub getEgid
{
    return $_[0]->getAttribute( 'egid' );
}

sub party
{
    my $class = shift;
    my $party = shift;
    map { $class->appendCharacter($_) } $party->getPartyCharacter();
}

sub encount
{
    my $class = shift;
    my $party = shift;
}

1;
