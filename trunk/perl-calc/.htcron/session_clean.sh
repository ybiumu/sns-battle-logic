#!/bin/bash

pushd /home/users/2/ciao.jp-anothark/web/.htsession
find . -name 'cgisess_*' -mtime +3 -exec rm -f {} \;
popd;
