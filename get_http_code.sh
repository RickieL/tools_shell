#!/bin/bash

code_200=0
code_403=0
code_other=0
code=0

for i in {1..120}
do
    code=$(curl  -s -I http://login.haodou.com/register.php -o - |grep HTTP |awk '{print $2}')
    if [ $code -eq 200 ]; then
        code_200=$(expr $code_200 + 1)
    elif [ $code -eq 403 ]; then
        code_403=$(expr $code_403 + 1)
    else
        code_other=$($code_other + 1)
    fi
    echo "总次数: $i " '$code_200: ' $code_200 ' $code_403: ' $code_403 ' $code_other: ' $code_other
    sleep 1
done
