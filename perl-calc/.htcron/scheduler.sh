#!/bin/bash


HOUR=$(date +"%H");

if [ "x${HOUR}" != "x" -a "${HOUR}" == "00" -o  "${HOUR}" == "04"  -o  "${HOUR}" == "08" -o  "${HOUR}" == "12" -o  "${HOUR}" == "16" -o  "${HOUR}" == "20" ];
then
    /home/users/2/ciao.jp-anothark/web/.htcron/twitter.pl
fi;


# onetime scheduler
ONETIME_PATH=/home/users/2/ciao.jp-anothark/web/.htcron/onetimes;
pushd ${ONETIME_PATH};
for RUNTIME in *.bat
do
    if [ -f "${RUNTIME}" ];
    then
        echo "Do [${RUNTIME}]";
#        exec ${ONETIME_PATH}/${RUNTIME};
        /bin/bash ${RUNTIME};
        mv ${RUNTIME} ends/${RUNTIME}.$(date +"%s");
    fi
done
popd;
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

