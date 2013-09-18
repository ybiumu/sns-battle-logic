package Anothark::Battle::Exhibition;
$|=1;
use strict;

use Anothark::Battle;
use Anothark::Character;
use Anothark::Character::Enemy;
use Anothark::Skill;
use Anothark::SkillLoader;
use Anothark::ItemLoader;

sub doExhibitionMatch
{
    my $battle   = shift;
    my $me       = shift;
    my $node_id  = shift;
    my $force_node = shift;
    my $db       = $battle->getAt()->getDbHandler();
    $me->setSide("p");
#warn "Append user.";
    $battle->appendCharacter( $me );

    my $p1 = $battle->getAt()->getPlayerByUserId(2);
    $p1->setSide("p");
    $battle->appendCharacter( $p1 );

    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);

    $me->getCmd()->[1] = $sl->loadSkill(1020);


#warn "Append hagis1.";
    my $npc1 = new Anothark::Character();
#warn "Append hagis1 done.";
    $npc1->setId("hagis1");
    $npc1->setName("íŽmÊ·Þ½");
    $npc1->getHp()->setBothValue(50);
    $npc1->getAtack()->setBothValue(10);
    $npc1->gDef()->setBothValue(10);
    $npc1->setCmd([
        [],
        $sl->loadSkill(1010),
        $sl->loadSkill(1010),
        $sl->loadSkill(1010),
        $sl->loadSkill(1010),
        $sl->loadSkill(1010),
    ]);
    $npc1->setSide("p");
    $npc1->getPosition()->setBothValue("f");
    $battle->appendCharacter( $npc1 );

#warn "Append hagis2.";
    my $npc2 = new Anothark::Character();
#warn "Append hagis2 done.";
    $npc2->setId("hagis2");
    $npc2->setName("‰°•aÊ·Þ½");
    $npc2->getHp()->setBothValue(25);
    $npc2->gDef()->setBothValue(5);
    $npc2->setCmd([
        [],
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( '¾ÙÌ¸¯·Ý¸Þ' ,{ skill_rate => 10,length_type => 1, range_type => 1,target_type => 2, effect_type => 1 } ),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
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
       4 => [ sub { golem(@_) }, sub { enemy001( @_ )} ],
       6 => [ sub { gemStone(@_) }, sub { enemy001( @_ )} ],
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
#warn "Do encount.";
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
    my $il = new Anothark::ItemLoader($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName("“¹’[‚Ì•óÎ");
    $battle->setPartyImg("load_king");
    $battle->setPartyLevel(20);
    $enemy->setId("load_king");
    $enemy->setName("Û°ÄÞ¥µ³Þ¥¼ÞªÑ½Ä°Ý");
    $enemy->getHp()->setBothValue(150);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(30);
    $enemy->getMagic()->setBothValue(50);
    $enemy->setCmd([
        [],
        $sl->loadSkill(1003),
        $sl->loadSkill(1004),
        $sl->loadSkill(1005),
        $sl->loadSkill(1006),
        $sl->loadSkill(1007),
#        new Anothark::Skill( 'Ñ°Ý½Ä°Ý×²Ä'     , {skill_rate => 7  ,length_type => 3 } ),
#        new Anothark::Skill( '¼ÞªÀÞ²Ä½Ìß×¯¼­' , {skill_rate => 5  ,length_type => 2, range_type => 2 } ),
#        new Anothark::Skill( 'ÙËÞ°½Íß¸ÄÙ'     , {skill_rate => 10 ,length_type => 3 }),
#        new Anothark::Skill( 'ÀÞ²ÔÓÝÄÞ¸×¯¼­'  , {skill_rate => 20 ,length_type => 1 } ),
#        new Anothark::Skill( 'ÒÃµÆ¯¸¥¼ÞªÑ½Ä°Ñ', {skill_rate => 15 ,length_type => 3, range_type => 3 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    push(
        @{$enemy->getDropItems()},
        ($il->loadItem( 10, 10), $il->loadItem( 10, 10),)
    );
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub zwei
{
#    warn "Call zwei";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    $battle->setPartyName("ŒJ‚è•Ô‚·ˆ«–²");
    $battle->setPartyImg("endless_nightmare");
    $battle->setPartyLevel(35);

    my $enemy1 = new Anothark::Character::Enemy();
    $enemy1->setId("zwei");
    $enemy1->setName("Â³Þ§²");
    $enemy1->getHp()->setBothValue(666);
    $enemy1->setCmd([
        [],
        $sl->loadSkill(1011),
        $sl->loadSkill(1012),
        $sl->loadSkill(1013),
        $sl->loadSkill(1014),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'ÌÞ¯¸½Ï¯¼­'    , {skill_rate => 7 ,length_type => 1 }),
#        new Anothark::Skill( '²Ý»°ÄÏ°¶°'    , {skill_rate => 7 ,length_type => 1, base_element => 0 }),
#        new Anothark::Skill( 'ÌÞ¯¸Ø¯ËßÝ¸Þ'  , {skill_rate => 7 ,length_type => 3, range_type => 2, base_element => 1 }),
#        new Anothark::Skill( '±ÊÞ×Ý½²ÝÀÌ¨±' , {skill_rate => 40,length_type => 3, range_type => 3, base_element => 4 }),
#        new Anothark::Skill( 'ÌÞ¯¸´ÝÄÞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy1->setSide("e");
    $enemy1->getPosition->setBothValue("f");
    push(@{$enemy1->getDropItems()},
        ($il->loadItem( 11, 10),
        $il->loadItem( 11, 10),)
    );


    my $enemy2 = new Anothark::Character::Enemy();
    $enemy2->setId("ein");
    $enemy2->setName("±²Ý");
    $enemy2->getHp()->setBothValue(666);
    $enemy2->setCmd([
        [],
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'ÌÞ¯¸´ÝÄÞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy2->setSide("e");
    $enemy2->getPosition()->setBothValue("b");


    my $enemy3 = new Anothark::Character::Enemy();
    $enemy3->setId("drei");
    $enemy3->setName("ÄÞ×²");
    $enemy3->getHp()->setBothValue(666);
    $enemy3->setCmd([
        [],
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'Êß°Ìª¸Ä½Ï²Ù' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'Ã¨°Ì×¯ÄÞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'ÌÞ¯¸´ÝÄÞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy3->setSide("e");
    $enemy3->getPosition()->setBothValue("b");

    $battle->appendCharacter( $enemy1 );
    $battle->appendCharacter( $enemy2 );
    $battle->appendCharacter( $enemy3 );
    $sl->finish();
}

sub hagis
{
#    warn "Call hhagis";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName('’‡ŠÔ‚ð’T‚µ‚Ä');
    $battle->setPartyImg("hagis");
    $battle->setPartyLevel(5);
    $enemy->setId("e_hagis");
    $enemy->setName('•ú˜QÊ·Þ½');
    $enemy->getHp()->setBothValue(90);
    $enemy->gDef()->setBothValue(5);
    push(@{$enemy->getDropItems()}, 
       ( $il->loadItem( 9, 20),
        $il->loadItem( 1, 80),)
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´’áŽü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $battle->appendCharacter( $enemy );
    $sl->finish();
}


sub golem
{
#    warn "Call golem";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName('œfœr‚¤“ylŒ`');
    $battle->setPartyImg("golem");
    $battle->setPartyLevel(15);
    $enemy->setId("e_golem");
    $enemy->setName('±ÝÀÚ½ƒÀ');
    $enemy->getHp()->setBothValue(500);
    $enemy->getAgility()->setBothValue(20);
    $enemy->gDef()->setBothValue(5);
    $enemy->setCmd([
        [],
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1019),
#        new Anothark::Skill( '’´‚Žü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´‚Žü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´‚Žü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '’´‚Žü”g' , { skill_rate => 10 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '¾ÙÌÃÞ½Ä×¸¼®Ý' , { skill_rate => 450 ,length_type => 1, range_type => 1,target_type => 2, random_type => 0, base_element => 3 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    push(
        @{$enemy->getDropItems()},
        ($il->loadItem( 12, 10), $il->loadItem( 12, 10),)
    );
    $battle->appendCharacter( $enemy );
    $sl->finish();
}



sub enemy001
{
#    warn "Call hhagis";
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName('•s‰ÂŽ‹‚È–ì—ÇŒ¢');
    $battle->setPartyImg("noimage");
    $battle->setPartyLevel(6);
    $enemy->setId("enemy001");
    $enemy->setName('²ÝËÞ¼ÞÌÞÙÊ³ÝÄÞ');
    $enemy->getHp()->setBothValue(80);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(10);
    push(@{$enemy->getDropItems()}, 
       ( $il->loadItem( 2, 5),
        $il->loadItem( 1, 30),)
    );
    $enemy->setCmd([
        [],
#        $sl->loadSkill(1009),
#        $sl->loadSkill(1009),
#        $sl->loadSkill(1009),
#        $sl->loadSkill(1009),
#        $sl->loadSkill(1009),
        new Anothark::Skill( 'Šš‚Ý‚Â‚«' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( 'Šš‚Ý‚Â‚«' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( 'Šš‚Ý‚Â‚«' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( 'Šš‚Ý‚Â‚«' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( 'Šš‚Ý‚Â‚«' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $battle->appendCharacter( $enemy );
    $sl->finish();
}
1;

