package Anothark::Battle;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );


my $logger = undef;
my $order = undef;
my $turn_text = undef;
my $living_order = undef;

my $stat_template = '<span style="color:%s">%s%s</span>%s<br />HP:%s/%s<br />';
my $act_template = '<div style="text-align:%s">%s%s</div>';
my $cmd_template = '<div style="text-align:%s" class="act_%s" >%s%s!</div>';

my $symbol = {
    e => {
        head      => "¡",
        head_nml  => "",
        head_pri  => "¥",
        head_cut  => "£",
        head_pas  => "æ",
        align => "right",
        color => "#000000",
    },
    p => {
        head      => " ",
        head_nml  => "",
        head_pri  => "¤",
        head_cut  => "¢",
        head_pas  => "æ",
        align => "left",
        color => "#ff0000",
    },
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
    $class->setCharacter({});
    $class->setTurnText([]);
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
    $class->setLivingOrder([ sort { $char->{$b}->setSide() <=> $char->{$a}->getSide() } grep { $char->{$_}->getHp()->current() > 0 } keys %{$char} ]);
}

sub doBattle
{
    my $class = shift;

    my $chars = $class->getCharacter();
    my $enemy_party = "•óÎ‚Ì‰¤";
    my $enemy_img = "load_king";;

    $class->getTurnText()->[0] = sprintf(
        "<div class=\"contents_e1\">%s</div><img src=\"img/%s.jpg\" />",
        $enemy_party,
        $enemy_img
    );
    foreach my $turn  ( 1 .. 5 )
    {
        $class->getTurnText()->[$turn] .= "<hr /><div style=\"text-align:center;color:#ff0000;\">Turn $turn</div>";
        foreach my $cs ( @{$class->getLiving()} )
        {
            # status
            $class->getTurnText()->[$turn] .= sprintf(
                $stat_template,
                $symbol->{$chars->{$cs}->getSide()}->{color},
                $symbol->{$chars->{$cs}->getSide()}->{head},
                $chars->{$cs}->getName(),"",
                $chars->{$cs}->getHp()->current(),
                $chars->{$cs}->getHp()->max(),
            )
        }

        my $order = $class->execActOrder($turn);
        foreach my $char ( @{$order}  )
        {
            # Name
            $class->getTurnText()->[$turn] .= sprintf(
                $act_template,
                $symbol->{$char->getSide()}->{align},
                $symbol->{$char->getSide()}->{head},
                $char->getName(),
            );

            # Cmd
            $class->getTurnText()->[$turn] .= sprintf(
                $cmd_template,
                $symbol->{$char->getSide()}->{align},
                $symbol->{$char->getSide()}->{head_nml},
                $char->getCmd()->[$turn]->getName(),
            );
        }
    }

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


sub getBattleText
{
    my $class = shift;
    return join("\n",@{$class->getTurnText()});
#    return "<div class=\"contents_e1\">•óÎ‚Ì‰¤</div><img src=\"img/load_king.jpg\" /><div class=\"contents_e2\"><center>************</center></div><br />";
}

sub getResultText
{
    my $class = shift;
    return "<center>YouWin!</center><br /><center>************</center><br />";
}

