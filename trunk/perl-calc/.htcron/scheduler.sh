#!/bin/bash


HOUR=$(date +"%H");

if [ "x${HOUR}" != "x" -a "${HOUR}" == "00" ];
then
    /home/users/2/ciao.jp-anothark/web/.htcron/twitter.pl
fi;

if [ "x${HOUR}" != "x" -a "${HOUR}" == "04" ];
then
    /home/users/2/ciao.jp-anothark/web/.htcron/daily_bat.pl
fi;



/home/users/2/ciao.jp-anothark/web/.htcron/daily_bat.pl


