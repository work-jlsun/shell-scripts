#!/bin/bash
port=8087
url="http://127.0.0.1:$port"


fileloc="./tobietmpalramdata.txt"
errRateLogFile="./errrateLogFile.txt"
averageQueueSizeLogFile="./averageQueueSizeLogFile.txt"
CorrectRequestAvgTimeLogFile="./CorrectRequestAvgTimeLogFile.txt"

curl -i $url > $fileloc     2>/dev/null


#各项指标的据对上限值与相对上一次比较上限值
errRateThreshold="0.2"
errRateBiggerThreshold="0.2"
CorrectRequestAvgTimeThreshold="500000"
CorrectRequestAvgTimeBiggerThreshold="500000"
averageQueueSizeThreshold="50"
averageQueueSizeBiggerThreshold="10"


key="correctRequestCount"
line=`grep "$key"   $fileloc`
correctRequestCount=$(echo $line | awk '{print $3}' | cut -f1 -d ',' )

key="requestCount"
line=`grep "$key"   $fileloc`
requestCount=$(echo $line | awk '{print $3}' | cut -f1 -d ',' )

line=`grep "formerErrRate" $errRateLogFile  2>/dev/null`
formerErrRate=$(echo $line | awk '{print $3}' | cut -f1 -d ',' )


if [ "0" = "$requestCount" ]; then
    :
else
    notCorrectCount=$(awk -v x=$requestCount -v y=$correctRequestCount 'BEGIN {printf "%d\n",x-y}')
    errRate=$(awk -v x=$notCorrectCount -v y=$requestCount 'BEGIN {printf "%.2f\n",x/y}')
    echo "Tobie_errRate  $errRate > $errRateThreshold  Tobie平均5s内的错误率 大于阈值 $errRateThreshold"
    if [ -z "$formerErrRate" ]; then
        echo "formerErrRate = $errRate," > $errRateLogFile
    else
        ifzero=$(awk -v x=$errRate -v y=$formerErrRate 'BEGIN {printf "%d\n",x/y}')
        if [ -z $ifzero ]; then
            dval=$(awk -v  x=$formerErrRate -v   y=$errRate 'BEGIN {printf "%.2f\n", x-y}')
            echo "Tobie_errRate_against_former $dval > $errRateBiggerThreshold Tobie平均5s内的错误率$errRate,明显小于前一分钟的统璁????$formerErrRate"
        else    
            dval=$(awk -v x=$errRate -v y=$formerErrRate 'BEGIN {printf "%.2f\n", x-y}')
            echo "Tobie_errRate_against_former $dval > $errRateBiggerThreshold Tobie平均5s内的错误率$errRate,明显大于前一分钟�??统计值$formerErrRate"
        fi
        echo "formerErrRate = $errRate," > $errRateLogFile
    fi
fi



key="CorrectRequestAvgTime"
line=`grep "$key"   $fileloc`
CorrectRequestAvgTime=$(echo $line | awk '{print $3}' | cut -f1 -d ',' )

line=`grep "formerCorrectRequestAvgTime" $CorrectRequestAvgTimeLogFile  2>/dev/null`
formerCorrectRequestAvgTime=$(echo $line | awk '{print $3}' | cut -f1 -d ',' )

echo "Tobie_CorrectRequestAvgTime $CorrectRequestAvgTime > $CorrectRequestAvgTimeThreshold Tobie平鍧??s内的响应时间$CorrectRequestAvgTime 大于阈值 $CorrectRequestAvgTimeThreshold "

if [ "0" = "$CorrectRequestAvgTime" ]; then
    :
else 
    if [ -z "$formerCorrectRequestAvgTime" ]; then
        echo "formerCorrectRequestAvgTime = $CorrectRequestAvgTime," > $CorrectRequestAvgTimeLogFile
    else
        if [ $CorrectRequestAvgTime -gt $formerCorrectRequestAvgTime  ]; then    
            dval=$(awk -v x=$CorrectRequestAvgTime -v y=$formerCorrectRequestAvgTime 'BEGIN {printf "%d\n", x-y}')
            echo "Tobie_CorrectRequestAvgTime_against_former $dval > $CorrectRequestAvgTimeBiggerThreshold Tobie平均5s内的响应时间$CorrectRequestAvgTime 明显大于前一分钟的统计值$formerCorrectRequestAvgTime"
        else
            dval=$(awk -v y=$CorrectRequestAvgTime -v x=$formerCorrectRequestAvgTime 'BEGIN {printf "%d\n", x-y}')
            echo "Tobie_CorrectRequestAvgTime_against_former $dval > $CorrectRequestAvgTimeBiggerThreshold Tobie骞????5s内的响应时间$CorrectRequestAvgTime 明显小于前一分钟的统璁????$formerCorrectRequestAvgTime"

        fi
        echo "formerCorrectRequestAvgTime = $CorrectRequestAvgTime," > $CorrectRequestAvgTimeLogFile
    fi
fi
