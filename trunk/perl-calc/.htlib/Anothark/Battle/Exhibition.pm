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
    if ( defined  $p1 )
    {
        $p1->setSide("p");
        $p1->getAtack()->setBothValue(20);
        $battle->appendCharacter( $p1 );
    }

    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);

    $me->getCmd()->[1] = $sl->loadSkill(1020);
    $me->getAtack()->setBothValue(15);


#warn "Append hagis1.";
    my $npc1 = new Anothark::Character();
#warn "Append hagis1 done.";
    $npc1->setId("hagis1");
    $npc1->setName("戦士ﾊｷﾞｽ");
    $npc1->getHp()->setBothValue(50);
    $npc1->getAtack()->setBothValue(20);
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
    $npc2->setName("臆病ﾊｷﾞｽ");
    $npc2->getHp()->setBothValue(25);
    $npc2->getAtack()->setBothValue(10);
    $npc2->gDef()->setBothValue(5);
    $npc2->setCmd([
        [],
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
#        new Anothark::Skill( '超低周波' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '超低周波' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
        new Anothark::Skill( 'ｾﾙﾌｸｯｷﾝｸﾞ' ,{ skill_rate => 10,length_type => 1, range_type => 1,target_type => 2, effect_type => 1 } ),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
#        new Anothark::Skill( '超低周波' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
#        new Anothark::Skill( '超低周波' , { skill_rate => 6 ,length_type => 1, range_type => 2 } ),
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

    ##########
    ## TODO:to Databse data.
    ##########
    my $node_append = {
       2 => [ sub { zwei(@_) } ],
       4 => [ sub { golem(@_) }, sub { enemy001( @_ )} ],
       6 => [ sub { gemStone(@_) }, sub { enemy001( @_ )} ],
       10 => [
            (sub { enemy002(@_)}) x 10,
            (sub { enemy003(@_)}) x 5,
            (sub { enemy004(@_)}) x 3,
            (sub { enemy005(@_)}) x 2,
            (sub { enemy006(@_)} ) x 1,
       ],
    };


    my $encounts = [
        @{$base_encounts}
    ];

    if ( exists $node_append->{$node_id} )
    {
#        if ( $force_node eq $node_id )
#        {
            $encounts = $node_append->{$node_id};
#        }
#        else
#        {
#            push(@{$encounts},  @{$node_append->{$node_id}});
#        }
    }

    my $total_count = scalar(@{$encounts});
    my $rnd = int(rand( $total_count ));
    warn "total_count[$total_count] rnd[$rnd]";
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
    $battle->setPartyName("道端の宝石");
    $battle->setPartyImg("load_king");
    $battle->setPartyLevel(20);
    $enemy->setId("load_king");
    $enemy->setName("ﾛｰﾄﾞ･ｵｳﾞ･ｼﾞｪﾑｽﾄｰﾝ");
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
#        new Anothark::Skill( 'ﾑｰﾝｽﾄｰﾝﾗｲﾄ'     , {skill_rate => 7  ,length_type => 3 } ),
#        new Anothark::Skill( 'ｼﾞｪﾀﾞｲﾄｽﾌﾟﾗｯｼｭ' , {skill_rate => 5  ,length_type => 2, range_type => 2 } ),
#        new Anothark::Skill( 'ﾙﾋﾞｰｽﾍﾟｸﾄﾙ'     , {skill_rate => 10 ,length_type => 3 }),
#        new Anothark::Skill( 'ﾀﾞｲﾔﾓﾝﾄﾞｸﾗｯｼｭ'  , {skill_rate => 20 ,length_type => 1 } ),
#        new Anothark::Skill( 'ﾒﾃｵﾆｯｸ･ｼﾞｪﾑｽﾄｰﾑ', {skill_rate => 15 ,length_type => 3, range_type => 3 } ),
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
    $battle->setPartyName("繰り返す悪夢");
    $battle->setPartyImg("endless_nightmare");
    $battle->setPartyLevel(35);

    my $enemy1 = new Anothark::Character::Enemy();
    $enemy1->setId("zwei");
    $enemy1->setName("ﾂｳﾞｧｲ");
    $enemy1->getHp()->setBothValue(666);
    $enemy1->setCmd([
        [],
        $sl->loadSkill(1011),
        $sl->loadSkill(1012),
        $sl->loadSkill(1013),
        $sl->loadSkill(1014),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'ﾌﾞｯｸｽﾏｯｼｭ'    , {skill_rate => 7 ,length_type => 1 }),
#        new Anothark::Skill( 'ｲﾝｻｰﾄﾏｰｶｰ'    , {skill_rate => 7 ,length_type => 1, base_element => 0 }),
#        new Anothark::Skill( 'ﾌﾞｯｸﾘｯﾋﾟﾝｸﾞ'  , {skill_rate => 7 ,length_type => 3, range_type => 2, base_element => 1 }),
#        new Anothark::Skill( 'ｱﾊﾞﾗﾝｽｲﾝﾀﾌｨｱ' , {skill_rate => 40,length_type => 3, range_type => 3, base_element => 4 }),
#        new Anothark::Skill( 'ﾌﾞｯｸｴﾝﾄﾞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy1->setSide("e");
    $enemy1->getPosition->setBothValue("f");
    push(@{$enemy1->getDropItems()},
        ($il->loadItem( 11, 10),
        $il->loadItem( 11, 10),)
    );


    my $enemy2 = new Anothark::Character::Enemy();
    $enemy2->setId("ein");
    $enemy2->setName("ｱｲﾝ");
    $enemy2->getHp()->setBothValue(666);
    $enemy2->setCmd([
        [],
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'ﾃｨｰﾌﾗｯﾄﾞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'ﾊﾟｰﾌｪｸﾄｽﾏｲﾙ' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'ﾃｨｰﾌﾗｯﾄﾞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'ﾊﾟｰﾌｪｸﾄｽﾏｲﾙ' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'ﾌﾞｯｸｴﾝﾄﾞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy2->setSide("e");
    $enemy2->getPosition()->setBothValue("b");


    my $enemy3 = new Anothark::Character::Enemy();
    $enemy3->setId("drei");
    $enemy3->setName("ﾄﾞﾗｲ");
    $enemy3->getHp()->setBothValue(666);
    $enemy3->setCmd([
        [],
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'ﾊﾟｰﾌｪｸﾄｽﾏｲﾙ' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'ﾃｨｰﾌﾗｯﾄﾞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'ﾊﾟｰﾌｪｸﾄｽﾏｲﾙ' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'ﾃｨｰﾌﾗｯﾄﾞ'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( 'ﾌﾞｯｸｴﾝﾄﾞ'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
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
    $battle->setPartyName('仲間を探して');
    $battle->setPartyImg("hagis");
    $battle->setPartyLevel(5);
    $enemy->setId("e_hagis");
    $enemy->setName('放浪ﾊｷﾞｽ');
    $enemy->getHp()->setBothValue(80);
    $enemy->gDef()->setBothValue(5);
    $enemy->getAtack()->setBothValue(15);
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
    $battle->setPartyName('彷徨う土人形');
    $battle->setPartyImg("golem");
    $battle->setPartyLevel(15);
    $enemy->setId("e_golem");
    $enemy->setName('ｱﾝﾀﾚｽβ');
    $enemy->getHp()->setBothValue(500);
    $enemy->getAgility()->setBothValue(20);
    $enemy->gDef()->setBothValue(5);
    $enemy->getAtack()->setBothValue(50);
    $enemy->setCmd([
        [],
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1019),
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
    $battle->setPartyName('不可視な野良犬');
    $battle->setPartyImg("noimage");
    $battle->setPartyLevel(6);
    $enemy->setId("enemy001");
    $enemy->setName('ｲﾝﾋﾞｼﾞﾌﾞﾙﾊｳﾝﾄﾞ');
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
        new Anothark::Skill( '噛みつき' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( '噛みつき' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( '噛みつき' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( '噛みつき' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
        new Anothark::Skill( '噛みつき' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $battle->appendCharacter( $enemy );
    $sl->finish();
}


# 公爵 duke
# 侯爵 marquis
# 伯爵 earl
# 子爵 viscount
# 男爵 baron

sub enemy002
{
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    $battle->setPartyName('男爵');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(5);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy002_01");
    $enemy->setName('ﾊﾞﾛﾝ');
    $enemy->getHp()->setBothValue(40);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(10);
    push(@{$enemy->getDropItems()}, 
       (
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 30),
       )
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1024),
        $sl->loadSkill(1024),
        $sl->loadSkill(1024),
        $sl->loadSkill(1024),
        $sl->loadSkill(1024),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");

    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy003
{
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    $battle->setPartyName('子爵');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(8);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy003_01");
    $enemy->setName('ｳﾞｧｲｶｳﾝﾄ');
    $enemy->getHp()->setBothValue(60);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(15);
    push(@{$enemy->getDropItems()}, 
       (
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 5),
       )
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1024),
        $sl->loadSkill(1024),
        $sl->loadSkill(1025),
        $sl->loadSkill(1024),
        $sl->loadSkill(1024),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");

    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy004
{
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    $battle->setPartyName('伯爵');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(10);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy004_01");
    $enemy->setName('ｱｰﾙ');
    $enemy->getHp()->setBothValue(80);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(20);
    push(@{$enemy->getDropItems()}, 
       (
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 5),
            $il->loadItem( 14, 5),
       )
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1024),
        $sl->loadSkill(1025),
        $sl->loadSkill(1024),
        $sl->loadSkill(1025),
        $sl->loadSkill(1024),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");

    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy005
{
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    $battle->setPartyName('侯爵');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(10);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy004_01");
    $enemy->setName('ﾏｰｸｳｨｽ');
    $enemy->getHp()->setBothValue(100);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(25);
    push(@{$enemy->getDropItems()}, 
       (
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 5),
            $il->loadItem( 14, 5),
       )
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1024),
        $sl->loadSkill(1025),
        $sl->loadSkill(1026),
        $sl->loadSkill(1024),
        $sl->loadSkill(1025),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");

    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy006
{
    my $battle = shift;
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $il = new Anothark::ItemLoader($db);
    $battle->setPartyName('公爵');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(12);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy006_01");
    $enemy->setName('ﾃﾞｭｰｸ');
    $enemy->getHp()->setBothValue(120);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(40);
    push(@{$enemy->getDropItems()}, 
       (
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 100),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 30),
            $il->loadItem( 14, 5),
       )
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1026),
        $sl->loadSkill(1025),
        $sl->loadSkill(1025),
        $sl->loadSkill(1025),
        $sl->loadSkill(1025),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");

    $battle->appendCharacter( $enemy );
    $sl->finish();
}


1;

