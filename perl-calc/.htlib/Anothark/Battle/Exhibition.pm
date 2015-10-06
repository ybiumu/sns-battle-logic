package Anothark::Battle::Exhibition;
$|=1;
use strict;

use Anothark::Battle;
use Anothark::Character;
use Anothark::Character::Enemy;
use Anothark::Character::Npc;
use Anothark::Skill;
use Anothark::SkillLoader;
use Anothark::ItemManager;
use Anothark::BattleSetting;
use Anothark::Party;
use Anothark::PartyLoader;

sub doExhibitionMatch
{
    my $battle   = shift;
    my $me       = shift;
    my $node_id  = shift;
    my $force_node = shift;
    my $db       = $battle->getAt()->getDbHandler();

    $battle->setBgid($node_id);

# XXX �������� LoadParty�̔��e
#    my $party = new Anothark::Party();
    my $pl = new Anothark::PartyLoader( $battle->getAt() );
# loadParty(Party);
#
# loadBattleParty(Party, Battle);
# $battle->party( $pl->loadBattlePartyByUser( $me ) );


$battle->error("################################################");

    if ( $battle->getPlayerPartyLoaded() == 0 )
    {
        my $party = $pl->loadBattlePartyByUser( $me, 'p' );
        $battle->party($party);
    }
$battle->error("################################################");
## XXX �����܂� LoadParty�̔��e


## XXX �������� �G���J�E���g����
    my $base_encounts = [
        sub { hagis(@_) },
        sub { hagis(@_) },
        sub { hagis(@_) },
        sub { hagis(@_) },
        sub { enemy011(@_) },
        sub { enemy011(@_) },
    ];

    ##########
    ## TODO:to Databse data.
    ##########
    my $node_append = {
       2 => [ sub { zwei(@_) } ],
#       4 => [ sub { golem(@_) }, sub { enemy001( @_ )} ],
       4 => [ sub { enemy001( @_ )} ],
#       4 => [ sub { zwei( @_ )} ],
       6 => [ sub { gemStone(@_) }, sub { enemy001( @_ )} ],
       10 => [
            (sub { enemy002(@_)}) x 10,
            (sub { enemy003(@_)}) x 5,
            (sub { enemy004(@_)}) x 3,
            (sub { enemy005(@_)}) x 2,
            (sub { enemy006(@_)}) x 1,
       ],
    };


    my $encounts = [
        @{$base_encounts}
    ];

    if ( exists $node_append->{$node_id} )
    {
        $encounts = $node_append->{$node_id};
    }

    my $total_count = scalar(@{$encounts});
    my $rnd = int(rand( $total_count ));
    $battle->warning( "total_count[$total_count] rnd[$rnd]");
#$battle->warning( "Do encount.");
    &{$encounts->[$rnd]}( $battle );

# $epid = execEncount();
# my $enemy_party = $pl->loadEnemtParty( $epid );
# $battle->encount( $enemy_party );
# ## onliner
# $battle->encount( $pl->loadEnemyParty( execEncount() ) );

## XXX �����܂ŃG���J�E���g����

    $battle->doBattle();

    return $battle->getBattleText();

}


sub enemy007
{
    gemStone(@_);
}


sub gemStone
{
    my $battle = shift;
    $battle->setEgid(7);
#    $battle->warning( "Call gemStone");
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName("���[�̕��");
    $battle->setPartyImg("load_king");
    $battle->setPartyLevel(18);
    $enemy->setId("load_king");
    $enemy->setName("۰�ޥ��ޥ�ުѽİ�");
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
#        new Anothark::Skill( 'Ѱݽİ�ײ�'     , {skill_rate => 7  ,length_type => 3 } ),
#        new Anothark::Skill( '�ު�޲Ľ��ׯ��' , {skill_rate => 5  ,length_type => 2, range_type => 2 } ),
#        new Anothark::Skill( '��ް��߸��'     , {skill_rate => 10 ,length_type => 3 }),
#        new Anothark::Skill( '�޲����޸ׯ��'  , {skill_rate => 20 ,length_type => 1 } ),
#        new Anothark::Skill( '�õƯ���ުѽİ�', {skill_rate => 15 ,length_type => 3, range_type => 3 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    push(
        @{$enemy->getDropItems()},
        ($im->loadItem( 10, 10), $im->loadItem( 10, 10),)
    );
    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy008
{
    zwei(@_);
}

sub zwei
{
    my $battle = shift;
    $battle->setEgid(8);
#    $battle->warning( "Call zwei");
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName("�J��Ԃ�����");
    $battle->setPartyImg("endless_nightmare");
    $battle->setPartyLevel(20);

    my $enemy1 = new Anothark::Character::Enemy();
    $enemy1->setId("zwei");
    $enemy1->setName("³ާ�");
    $enemy1->getHp()->setBothValue(666);
    $enemy1->setCmd([
        [],
        $sl->loadSkill(1011),
        $sl->loadSkill(1012),
        $sl->loadSkill(1013),
        $sl->loadSkill(1014),
        $sl->loadSkill(1073),
#        new Anothark::Skill( '�ޯ��ϯ��'    , {skill_rate => 7 ,length_type => 1 }),
#        new Anothark::Skill( '�ݻ��ϰ��'    , {skill_rate => 7 ,length_type => 1, base_element => 0 }),
#        new Anothark::Skill( '�ޯ�د��ݸ�'  , {skill_rate => 7 ,length_type => 3, range_type => 2, base_element => 1 }),
#        new Anothark::Skill( '����ݽ���̨�' , {skill_rate => 40,length_type => 3, range_type => 3, base_element => 4 }),
#        new Anothark::Skill( '�ޯ�����'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy1->setSide("e");
    $enemy1->getPosition->setBothValue("f");
    push(@{$enemy1->getDropItems()},
        ($im->loadItem( 11, 10),
        $im->loadItem( 11, 10),)
    );


    my $enemy2 = new Anothark::Character::Enemy();
    $enemy2->setId("ein");
    $enemy2->setName("���");
    $enemy2->getHp()->setBothValue(666);
    $enemy2->setCmd([
        [],
        $sl->loadSkill(1016),
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1073),
        $sl->loadSkill(1015),
#        new Anothark::Skill( 'è��ׯ��'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( '�̪߰�Ľϲ�' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'è��ׯ��'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( '�̪߰�Ľϲ�' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( '�ޯ�����'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy2->setSide("e");
    $enemy2->getPosition()->setBothValue("b");


    my $enemy3 = new Anothark::Character::Enemy();
    $enemy3->setId("drei");
    $enemy3->setName("��ײ");
    $enemy3->getHp()->setBothValue(666);
    $enemy3->setCmd([
        [],
        $sl->loadSkill(1017),
        $sl->loadSkill(1016),
        $sl->loadSkill(1073),
        $sl->loadSkill(1016),
        $sl->loadSkill(1015),
#        new Anothark::Skill( '�̪߰�Ľϲ�' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'è��ׯ��'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( '�̪߰�Ľϲ�' , {skill_rate => 10 ,length_type => 3, base_element => -1 }),
#        new Anothark::Skill( 'è��ׯ��'    , {skill_rate => 4  ,length_type => 2, range_type => 2, base_element => 12 }),
#        new Anothark::Skill( '�ޯ�����'     , {skill_rate => 99,length_type => 3, range_type => 3, base_element => 4 }),
    ]);
    $enemy3->setSide("e");
    $enemy3->getPosition()->setBothValue("b");
    $enemy1->fixInit();
    $enemy2->fixInit();
    $enemy3->fixInit();

    $battle->appendCharacter( $enemy1 );
    $battle->appendCharacter( $enemy2 );
    $battle->appendCharacter( $enemy3 );
    $sl->finish();
}

sub enemy009
{
    hagis(@_);
}

sub hagis
{
#    $battle->warning( "Call hhagis");
    my $battle = shift;
    $battle->setEgid(9);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName('���Ԃ�T����');
    $battle->setPartyImg("hagis");
    $battle->setPartyLevel(5);
    $enemy->setId("e_hagis");
    $enemy->setName('���Qʷ޽');
    $enemy->getHp()->setBothValue(80);
    $enemy->gDef()->setBothValue(5);
    $enemy->getAtack()->setBothValue(15);
    push(@{$enemy->getDropItems()}, 
       ( $im->loadItem( 9, 20),
        $im->loadItem( 1, 80),)
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
    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy011
{
#    $battle->warning( "Call hhagis");
    my $battle = shift;
    $battle->setEgid(11);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('���͓��A��');
    $battle->setPartyImg("hagis2");
    $battle->setPartyLevel(7);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("e_hagis");
    $enemy->setName('���Qʷ޽A');
    $enemy->getHp()->setBothValue(80);
    $enemy->gDef()->setBothValue(5);
    $enemy->getAtack()->setBothValue(15);
    push(@{$enemy->getDropItems()}, 
       ( $im->loadItem( 9, 20),
        $im->loadItem( 1, 80),)
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
    $enemy->fixInit();

    my $enemy2 = new Anothark::Character::Enemy();
    $enemy2->setId("e_hagis2");
    $enemy2->setName('���Qʷ޽B');
    $enemy2->getHp()->setBothValue(80);
    $enemy2->gDef()->setBothValue(5);
    $enemy2->getAtack()->setBothValue(15);
    push(@{$enemy2->getDropItems()}, 
       ( $im->loadItem( 9, 20),
        $im->loadItem( 1, 80),)
    );
    $enemy2->setCmd([
        [],
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
        $sl->loadSkill(1009),
    ]);
    $enemy2->setSide("e");
    $enemy2->getPosition()->setBothValue("f");
    $enemy2->fixInit();


    $battle->appendCharacter( $enemy );
    $battle->appendCharacter( $enemy2 );

    $sl->finish();
}



sub enemy010
{
    golem(@_);
}

sub golem
{
    my $battle = shift;
    $battle->setEgid(10);
#    $battle->warning( "Call golem");
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('�f�r���y�l�`');
    $battle->setPartyImg("golem");
    $battle->setPartyLevel(15);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("e_golem");
    $enemy->setName('���ڽ��A');
    $enemy->getHp()->setBothValue(500);
    $enemy->getAgility()->setBothValue(20);
    $enemy->gDef()->setBothValue(5);
    $enemy->getAtack()->setBothValue(50);
    $enemy->setCmd([
        [],
        $sl->loadSkill(1019),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1019),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");

    push(
        @{$enemy->getDropItems()},
        ($im->loadItem( 12, 10), $im->loadItem( 12, 10),)
    );

    my $enemy2 = new Anothark::Character::Enemy();
    $enemy2->setId("e_golem2");
    $enemy2->setName('���ڽ��B');
    $enemy2->getHp()->setBothValue(500);
    $enemy2->getAgility()->setBothValue(20);
    $enemy2->gDef()->setBothValue(5);
    $enemy2->getAtack()->setBothValue(50);
    $enemy2->setCmd([
        [],
        $sl->loadSkill(1019),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1019),
    ]);
    $enemy2->setSide("e");
    $enemy2->getPosition()->setBothValue("f");

    push(
        @{$enemy2->getDropItems()},
        ($im->loadItem( 12, 10), $im->loadItem( 12, 10),)
    );


    my $enemy3 = new Anothark::Character::Enemy();
    $enemy3->setId("e_golem3");
    $enemy3->setName('���ڽ��C');
    $enemy3->getHp()->setBothValue(500);
    $enemy3->getAgility()->setBothValue(20);
    $enemy3->gDef()->setBothValue(5);
    $enemy3->getAtack()->setBothValue(50);
    $enemy3->setCmd([
        [],
        $sl->loadSkill(1019),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1018),
        $sl->loadSkill(1019),
    ]);
    $enemy3->setSide("e");
    $enemy3->getPosition()->setBothValue("f");

    push(
        @{$enemy3->getDropItems()},
        ($im->loadItem( 12, 10), $im->loadItem( 12, 10),)
    );

    $enemy->fixInit();
    $enemy2->fixInit();
    $enemy3->fixInit();
    $battle->appendCharacter( $enemy );
    $battle->appendCharacter( $enemy2 );
    $battle->appendCharacter( $enemy3 );
    $sl->finish();
}



sub enemy001
{
    my $battle = shift;
    $battle->setEgid(1);
#    $battle->warning( "Call hhagis");
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    my $enemy = new Anothark::Character::Enemy();
    $battle->setPartyName('�s���Ȗ�ǌ�');
    $battle->setPartyImg("noimage");
    $battle->setPartyLevel(6);
    $enemy->setId("enemy001");
    $enemy->setName('���޼����ʳ���');
    $enemy->getHp()->setBothValue(80);
    $enemy->getAgility()->setBothValue(95);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(10);
    push(@{$enemy->getDropItems()}, 
       ( $im->loadItem( 2, 5),
        $im->loadItem( 1, 30),)
    );
    $enemy->setCmd([
        [],
        $sl->loadSkill(1088),
        $sl->loadSkill(1010),
        $sl->loadSkill(1088),
        $sl->loadSkill(1010),
        $sl->loadSkill(1088),
#        new Anothark::Skill( '���݂�' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
#        new Anothark::Skill( '���݂�' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
#        new Anothark::Skill( '���݂�' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
#        new Anothark::Skill( '���݂�' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
#        new Anothark::Skill( '���݂�' , { skill_rate => 1.2 ,length_type => 1, range_type => 1, power_source => 1 } ),
    ]);
    $enemy->setSide("e");
    $enemy->getPosition()->setBothValue("f");
    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}


# ���� duke
# ��� marquis
# ���� earl
# �q�� viscount
# �j�� baron

sub enemy002
{
    my $battle = shift;
    $battle->setEgid(2);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('�j��');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(5);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy002_01");
    $enemy->setName('����');
    $enemy->getHp()->setBothValue(40);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(10);
    push(@{$enemy->getDropItems()}, 
       (
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 30),
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

    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy003
{
    my $battle = shift;
    $battle->setEgid(3);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('�q��');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(8);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy003_01");
    $enemy->setName('�ާ�����');
    $enemy->getHp()->setBothValue(60);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(15);
    push(@{$enemy->getDropItems()}, 
       (
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 5),
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

    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy004
{
    my $battle = shift;
    $battle->setEgid(4);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('����');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(10);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy004_01");
    $enemy->setName('���');
    $enemy->getHp()->setBothValue(80);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(20);
    push(@{$enemy->getDropItems()}, 
       (
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 5),
            $im->loadItem( 14, 5),
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

    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy005
{
    my $battle = shift;
    $battle->setEgid(5);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('���');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(10);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy004_01");
    $enemy->setName('ϰ����');
    $enemy->getHp()->setBothValue(100);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(25);
    push(@{$enemy->getDropItems()}, 
       (
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 5),
            $im->loadItem( 14, 5),
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

    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}

sub enemy006
{
    my $battle = shift;
    $battle->setEgid(6);
    my $db       = $battle->getAt()->getDbHandler();
    my $sl = new Anothark::SkillLoader($db);
    my $im = new Anothark::ItemManager($db);
    $battle->setPartyName('����');
    $battle->setPartyImg("potate");
    $battle->setPartyLevel(12);

    my $enemy = new Anothark::Character::Enemy();
    $enemy->setId("enemy006_01");
    $enemy->setName('�ޭ��');
    $enemy->getHp()->setBothValue(120);
    $enemy->gDef()->setBothValue(10);
    $enemy->getAtack()->setBothValue(40);
    push(@{$enemy->getDropItems()}, 
       (
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 100),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 30),
            $im->loadItem( 14, 5),
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

    $enemy->fixInit();
    $battle->appendCharacter( $enemy );
    $sl->finish();
}


#sub setSkills
#{
#    my $bs   = shift;
#    my $sl   = shift;
#    my $char = shift;
#
#    $bs->setUserId( $char->getUserId());
#    my $settings = $bs->getBattleSettings();
#
#    if ( $settings )
#    {
#        $bs->notice("FOUND ! [" . $char->getUserId() .  "]");
#        foreach my $set ( @{$settings} )
#        {
#            if ( $set->{position} > 0 )
#            {
#                if ($set->{setting_id} == 2 )
#                {
#                    $char->getCmd()->[$set->{position}] = $sl->loadSkill( $set->{info} );
#                }
#                elsif ( $set->{setting_id} == 3 )
#                {
#                    $char->getCmd()->[$set->{position}] = $sl->loadSkill( 31 );
#                    $char->getCmd()->[$set->{position}]->setNoSkillType($set->{setting_id});
#                    $char->getCmd()->[$set->{position}]->setIsSkill(0);
#                }
#                elsif ( $set->{setting_id} == 4 )
#                {
#                    $char->getCmd()->[$set->{position}] = $sl->loadSkill( 40 + ( $set->{info} > 0 ? $set->{info} : 2 ) );
#                    $char->getCmd()->[$set->{position}]->setNoSkillType($set->{setting_id});
#                    $char->getCmd()->[$set->{position}]->setIsSkill(0);
#                }
#                elsif ( $set->{setting_id} == 1 && $char->getEquipSkillId() )
#                {
#                    $char->error( "[ATACK SKILL ID] (" .$char->getEquipSkillId() . ")" );
#                    $char->getCmd()->[$set->{position}] = $sl->loadSkill( $char->getEquipSkillId() );
#                }
#                else
#                {
#                    $char->getCmd()->[$set->{position}] = $sl->loadSkill( 1001 );
#                }
#            }
#        }
#    }
#    else
#    {
#        $bs->warning("No settings found ! [" . $char->getUserId() .  "]");
#    }
#}

1;

