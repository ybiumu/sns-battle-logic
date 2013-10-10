#!/bin/bash


HOUR=$(date +"%H");

if [ "x${HOUR}" != "x" -a "${HOUR}" == "00" -o  "${HOUR}" == "04"  -o  "${HOUR}" == "08" -o  "${HOUR}" == "12" -o  "${HOUR}" == "16" -o  "${HOUR}" == "20" ];
then
    /home/users/2/ciao.jp-anothark/web/.htcron/twitter.pl
fi;
#
#if [ "x${HOUR}" != "x" -a "${HOUR}" == "04" ];
#then
#    /home/users/2/ciao.jp-anothark/web/.htcron/daily_bat.pl
#fi;
#
#
#
#/home/users/2/ciao.jp-anothark/web/.htcron/daily_bat.pl
#

