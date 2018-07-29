#!/bin/sh

#全局变量定义
year=$(date +"%Y")
month=$(date +"%m")
day=$(date +"%d")
hour=$(date +"%H")
base_url=/home/nv/recordings
date_url=$year/$month/$day
updir=$base_url/$date_url
todir=$updir
#需要在这里设置判断，执行该脚本前是默认有完整日期目录的
if [ ! -d "$base_url/$year" ]; then
    echo "该年没有录音文件存档"
    else 
        if [ ! -d "$base_url/$year/$month" ]; then
            echo "该月没有录音文件存档"
            else
            if [ ! -d "$base_url/$year/$month/$day" ]; then
                echo "该天没有录音文件存档"
                else
                dirCommand=`find $updir -type d -printf $todir/'%P\n'| awk '{if ($0 == "")next;print "mkdir " $0}'` 
                upCommand=`find $updir -type f -printf 'put %p %P \n'` 
                #计算执行脚本所需时间
                startTime=$(date "+%s")
                ####把本地/home下的text.txt上传到ftp相应日期目录下####
                ftp -n <<EOF
                open 172.16.20.72
                user root root01
                binary
                cd $base_url
                mkdir $year
                cd $year
                mkdir $month
                cd $month
                mkdir $day
                cd $day
                lcd $base_url/$date_url
                prompt
                $dirCommand
                $upCommand
                close
                bye
EOF
                endTime=$(date "+%s")
                cost=$(($endTime-$startTime))
                echo "上传文件花费了$cost秒"
            fi
        fi    
fi

