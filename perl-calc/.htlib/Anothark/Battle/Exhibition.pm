package Anothark::Battle::Exhibition;
$|=1;
use strict;

use Anothark::Battle;
use Anothark::Character;
use Anothark::Skill;
use Anothark::SkillLoader;

sub doExhibitionMatch
{
    my $battle   = shift;
    my $me       = shift;
    my $node_id  = shift;
    my $force_node = shift;
    my $db       = $battle->getAt()->getDbHandler();
    $me->setSide("p");
    $battle->appendCharacter( $me );
    my $sl = new Anothark::SkillLoader($db);

    my $npc1 = new Anothark::Character();
    $npc1->setId("hagis1");
    $npc1->setName("ímÊ·Ş½");
    $npc1->getHp()->setBothValue(50);
    $npc1->getAtack()->setBothValue(10);
    $npc1->gDef()->setBothValue(10);
    $npc1->setCmd([
        [],
        $sl->loadSkill(10),
        $sl->loadSkill(10),
        $sl->loadSkill(10),
        $sl->loadSkill(10),
        $sl->loadSkill(10),
    ]);
    $npc1->setSide("p");
    $npc1->getPosition()->setBothValue("f");
    $battle->appendCharacter( $npc1 );

    my $npc2 = new Anothark::Character();
    $npc2->setId("hagis2");
    $npc2->setName("‰°•aÊ·Ş½");
    $npc2->getHp()->setBothValue(25);
    $npc2->gDef()->setBothValue(5);
    $npc2->setCmd([
        [],
        $sl->loadSkill(9),
        $sl->loadSkill(9),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '¾ÙÌ¸¯·İ¸Ş' ,{ skill_rate => 10,length_type => 1, range_type => 1,target_type => 2, effect_type => 1 } ),
        $sl->loadSkill(9),
        $sl->loadSkill(9),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
    ]);

    $npc2->setSide("p");
    $npc2->getPosition()->setBothValue("b");
    $battle->appendCharacter( $npc2 );


#    my $encounts = {
#        0 => sub { gemStone(@_) },
#        1 => sub { gemStone(@_) },
#        2 => sub { gemStone(@_) },
#        3 => sub { hagis(@_) },
#        4 => sub { hagis(@_) },
#        5 => sub { hagis(@_) },
#        6 => sub { hagis(@_) },
#        7 => sub { golem(@_) },
#        8 => sub { golem(@_) },
#        9 => sub { zwei(@_) },
#    };


    my $base_encounts = [
        sub { hagis(@_) },
        sub { hagis(@_) },
        sub { hagis(@_) },
    ];


    my $node_append = {
       2 => [ sub { zwei(@_) } ],
       4 => [ sub { golem(@_) } ],
       6 => [ sub { gemStone(@_) } ],
    };


    my $encounts = [
        @{$base_encounts}
    ];

    if ( exists $node_append->{$node_id} )
    {
        if ( $force_node eq $node_id )
        {
            $encounts = $node_append->{$node_id};
        }
        else
        {
            push(@{$encounts},  @{$node_append->{$node_id}});
        }
    }

    my $rnd = int(rand(scalar(@{$encounts})));
    &{$encounts->[$rnd]}( $battle );

    $battle->doBattle();

    return $battle->getBattleText();

}



sub gemStone
{
#    warn "Call gemStone";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $enemy = new Anothark::Character();
    $battle->setPartyName("“¹’[‚Ì•óÎ");
    $battle->setPartyImg("load_king");
    $enemy->setId("load_king");
    $enemy->setName("Û°ÄŞ¥µ³Ş¥¼ŞªÑ½Ä°İ");
    $enemy->getHp()->setBothValue(150);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(30);
    $enemy->getMagic()->setBothValue(50);
    $enemy->setCmd([
        [],
        $sl->loadSkill(3),
        $sl->loadSkill(4),
        $sl->loadSkill(5),
        $sl->loadSkill(6),
        $sl->loadSkill(7),
#        new Anothark::Skill( 'Ñ°İ½Ä°İ×²Ä'     , {skill_rate => 7  ,length_type => 3 } ),
#        new Anothark::Skill( '¼ŞªÀŞ²Ä½Ìß×¯¼­' , {skill_rate => 5  ,length_type => 2, range_type => 2 } ),
#        new Anothark::Skill( 'ÙËŞ°½Íß¸ÄÙ'     , {skill_rate => 10 ,length_type => 3 }),
#        new Anothark::Skill( 'ÀŞ²ÔÓİÄŞ¸×¯¼­'  , {skill_rate => 20 ,length_type => 1 } ),
#        new Anothark::Skill( 'ÒÃµÆ¯¸¥¼ŞªÑ½Ä°Ñ', {skill_rate => 15 ,length_type => 3, range_type => 3 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $battle->appendCharacter( $enemy );
}

sub zwei
{
#    warn "Call zwei";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    $battle->setPartyName("ŒJ‚è•Ô‚·ˆ«–²");
    $battle->setPartyImg("endless_nightmare");

    my $enemy1 = new Anothark::Character();
    $enemy1->setId("zwei");
    $enemy1->setName("Â³Ş§²");
    $enemy1->getHp()->setBothValue(666);
    $enemy1->setCmd([
        [],
        $sl->loadSkill(11),
        $sl->loadSkill(12),
        $sl->loadSkill(13),
        $sl->loadSkill(14),
        $sl->loadSkill(15),
#        new Anothark::Skill( 'ÌŞ¯¸½Ï¯¼­'    , {skill_rate => 7 ,length_type => 1 }),
#        new Anothark::Skill( '²İ»°ÄÏ°¶°'    , {skill_rate => 7 ,length_type => 1, base_element => 0 }),
#        new Anothark::Skill( 'ÌŞ¯¸Ø¯Ëßİ¸Ş'  , {skill_rate => 7 ,length_type => 3, range_type => 2, base_element => 1 }),
#        new Anothark::Skill( '±ÊŞ×İ½²İÀÌ¨±' , {skill_rate => 40,length_type => 3, range_type => 3, base_element => 4 }),
#        new Anothark::Skill( 'ÌŞ¯¸´İÄŞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy1->setSide("e");
    $enemy1->getPosition->setBothValue("f");


    my $enemy2 = new Anothark::Character();
    $enemy2->setId("ein");
    $enemy2->setName("±²İ");
    $enemy2->getHp()->setBothValue(666);
    $enemy2->setCmd([
        [],
        $sl->loadSkill(16),
        $sl->loadSkill(17),
        $sl->loadSkill(16),
        $sl->loadSkill(17),
        $sl->loadSkill(15),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄŞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄŞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'ÌŞ¯¸´İÄŞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy2->setSide("e");
    $enemy2->getPosition()->setBothValue("b");


    my $enemy3 = new Anothark::Character();
    $enemy3->setId("drei");
    $enemy3->setName("ÄŞ×²");
    $enemy3->getHp()->setBothValue(666);
    $enemy3->setCmd([
        [],
        $sl->loadSkill(17),
        $sl->loadSkill(16),
        $sl->loadSkill(17),
        $sl->loadSkill(16),
        $sl->loadSkill(15),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄŞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄŞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'ÌŞ¯¸´İÄŞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy3->setSide("e");
    $enemy3->getPosition()->setBothValue("b");

    $battle->appendCharacter( $enemy1 );
    $battle->appendCharacter( $enemy2 );
    $battle->appendCharacter( $enemy3 );
}

sub hagis
{
#    warn "Call hhagis";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $enemy = new Anothark::Character();
    $battle->setPartyName("’‡ŠÔ‚ğ’T‚µ‚Ä");
    $battle->setPartyImg("hagis");
    $enemy->setId("e_hagis");
    $enemy->setName("•ú˜QÊ·Ş½");
    $enemy->getHp()->setBothValue(90);
    $enemy->gDef()->setBothValue(5);
    $enemy->setCmd([
        [],
        $sl->loadSkill(9),
        $sl->loadSkill(9),
        $sl->loadSkill(9),
        $sl->loadSkill(9),
        $sl->loadSkill(9),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $battle->appendCharacter( $enemy );
}


sub golem
{
#    warn "Call golem";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $enemy = new Anothark::Character();
    $battle->setPartyName("œfœr‚¤“ylŒ`");
    $battle->setPartyImg("golem");
    $enemy->setId("e_golem");
    $enemy->setName("±İÀÚ½ƒÀ");
    $enemy->getHp()->setBothValue(500);
    $enemy->getAgility()->setBothValue(20);
    $enemy->gDef()->setBothValue(5);
    $enemy->setCmd([
        [],
        $sl->loadSkill(18),
        $sl->loadSkill(18),
        $sl->loadSkill(18),
        $sl->loadSkill(18),
        $sl->loadSkill(19),
#        new Anothark::Skill( '’´‚ü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´‚ü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´‚ü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´‚ü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '¾ÙÌÃŞ½Ä×¸¼®İ' , { skill_rate => 450 ,length_type => 1, range_type => 1,target_type => 2, random_type => 0, base_element => 3 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $battle->appendCharacter( $enemy );
}

1;
