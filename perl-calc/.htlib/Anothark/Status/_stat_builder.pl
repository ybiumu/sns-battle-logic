#!/usr/bin/perl -I /srv/anothark/.htlib
use strict;
use Anothark::StatusManager;
open OP, "_template.pm";
my $fbase = join("",<OP>);
close(OP);
#print $fbase;
my $s = new Anothark::StatusManager();
my $m = $s->get_stat_master();
foreach my $i ( sort { $a <=> $b } keys %{ $m } )
{
    my $o = $m->{$i};
    my $tmp = $fbase;
    my $ucfirst = ucfirst($o->{system_name});
    $tmp=~ s/_UCFIRST_/$ucfirst/g;
    $tmp=~ s/_ID_/$i/g;

    $tmp=~ s/_NO_MOVE_/$o->{no_move}/g;
    $tmp=~ s/_NO_TARGET_/$o->{no_target}/g;
    $tmp=~ s/_EFFECT_SPAN_/$o->{effect_span}/g;
    $tmp=~ s/_LONG_LABEL_/'$o->{long_label}'/g;
    $tmp=~ s/_SHORT_LABEL_/'$o->{short_label}'/g;
    $tmp=~ s/_SYSTEM_NAME_/'$o->{system_name}'/g;
    $tmp=~ s/_STAT_MSG_/'$o->{stat_msg}'/g;
    $tmp=~ s/_ARRAY_ORDER_/$o->{array_order}/g;
    $tmp=~ s/_CANCEL_BY_/$o->{cancel_by}/g;
    $tmp=~ s/_TRIGGERED_BY_/$o->{triggered_by}/g;
    $tmp=~ s/_MAIN_EFFECT_/$o->{effect}/g;
    $tmp=~ s/_ENCHANT_EFFECT_/$o->{enchant_effect}/g;

    open WR, ">$ucfirst.pm";
    print WR $tmp;
    close WR;
}

