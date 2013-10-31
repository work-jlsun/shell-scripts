#!/bin/bash

maxTime="2"

result=`curl  --max-time $maxTime  "172.17.2.201:8086/testimages/b.jpg?imageView&thumbnail=500x500" -o /dev/null -s -w %{http_code}:%{time_total}`

httpcode=$(echo $result | cut -f1 -d ':')

if [ "200" = "$httpcode" ]; then
    consumerTime=$(echo $result | cut -f2 -d ':')
    ifzero=$(awk -v x=$consumerTime -v y=$maxtime 'BEGIN {printf "%d\n",x/y}')   
    if [ -z $ifzero ]; then
        :
    else
        echo "TobieResponstime $consumerTime >= $maxTime Tobie外部监控请求响应时间大于$maxTime秒" 
    fi
else
    echo "httcode 1 > 0   Tobie外部监控请求错误"
fi



