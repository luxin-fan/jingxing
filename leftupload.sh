#!/bin/sh
#1.变量接收用户输入日期 不正确的输入格式进行友好提示
#2.获取其年月日,如果没有目录的话就创建相应目录，如果有目录当有文件的时候就执行上传，如果没有文件就友好的提示
#经过多次测试 如果上传的文件重名 是会默认的覆盖的
#全局变量定义
QUIT_COMMAND=quit
base_url=/home/nv/recordings
while [ 1=1 ]
do
   stty erase '^H'
   read -p "请输入您想重新上传录音文件日期，形如20180101：" pdate
   #对用户的输入进行匹配
   case $pdate in
       "$QUIT_COMMAND")
            echo "谢谢使用！"
            exit 0
        ;;
        * )
            if echo $pdate | date -d $pdate +%Y%m%d 2>/dev/null
            then
                year=${pdate:0:4}
                month=${pdate:4:2}
                day=${pdate:6:2}
                date_url=$year/$month/$day
                updir=$base_url/$date_url
                todir=$updir
                if [ ! -d "$base_url/$year" ]; then
                    echo "该年没有录音文件存档"
                else
                    if [ ! -d "$base_url/$year/$month" ]; then
                        echo "该月没有录音文件存档"
                    else
                        if [ ! -d "$base_url/$year/$month/$day" ]; then
                            echo "该天没有录音文件存档"
                        else
                            #计算执行脚本所需时间
                            startTime=$(date "+%s")
                            dirCommand=`find $updir -type d -printf $todir/'%P\n'| awk '{if ($0 == "")next;print "mkdir " $0}'`
                            upCommand=`find $updir -type f -printf 'put %p %P \n'`
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
                exit 0
            else
                echo "您输入的日期格式有误"
            fi
        ;;
   esac
   echo
done



