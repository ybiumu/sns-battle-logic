package Anothark::ItemCallback::ChangeName;
#
# 愛
#
$|=1;
use strict;


use Anothark::ItemCallback;
use base qw( Anothark::ItemCallback );

use constant REPLACE_KEY => "_CHANGE_NAME_";

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setBasePage("body_item_using.html");
}

sub using
{
    $class->getAt()->setBody( $class->getBasePage() );

}

