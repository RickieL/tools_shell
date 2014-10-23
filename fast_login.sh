#!/bin/bash

bj="1.1.1.1"
bj_bkup="2.2.2.2"
cs="3.3.3.3"
if [ "x$1" == "xcs" ]; then 
     cmd="ssh ${!1}"
elif [ "x$1" == "xbj" ] || [ "x$1" == "xbj_bkup" ] ; then
    if [ $# -eq 1 ]; then
        cmd="ssh ${!1}"
    else
        cmd="ssh -t yongfu@${!1}"
        cmd="${cmd} /home/yongfu/bin/g $2"
    fi
else
    ip=$1
    ipsuffixarray=($(echo $ip |sed 's/\./ /g'))
    len=${#ipsuffixarray[@]}
    if [ $len -eq 1 ];then
        realip="192.168.1.$ip"
    elif [ $len -eq 2 ];then
        realip="192.168.$ip"
    elif [ $len -eq 3 ];then
        realip="192.$ip"
    else
        realip=$ip
    fi
    cmd="ssh $realip"
fi

eval $cmd

exit 0
