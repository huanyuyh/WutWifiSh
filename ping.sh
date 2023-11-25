username=""                  
password=""                           
url="172.30.21.100"                            
id="52" 
#ping 的总次数
PING_SUM=3
#ping 的间隔时间，单位秒
SLEEP_SEC=10
#连续重启网卡 REBOOT_CNT 次网络都没有恢复正常，重启软路由
#时间= (SLEEP_SEC * PING_SUM + 20) * REBOOT_CNT
REBOOT_CNT=3
LOG_PATH="/root/autologin/log.txt"
cnt=0
reboot_cnt=0
while :
do
    ping -c 1 -W 1 www.baidu.com > /dev/null
    ret=$?
    
    ping -c 1 -W 1 www.bilibili.com > /dev/null
    ret2=$?
    if [[ $ret -eq 0 || $ret2 -eq 0 ]]
    then
		echo -e 'network is ok\r'
    	exit
        #cnt=0
        #reboot_cnt=0
    else
        cnt=`expr $cnt + 1`
        echo -n `date '+%Y-%m-%d %H:%M:%S'` >> $LOG_PATH
        printf '-> [%d/%d] Network maybe disconnected,checking again after %d seconds!\r\n' $cnt $PING_SUM $SLEEP_SEC >> $LOG_PATH
        printf '-> [%d/%d] Network maybe disconnected,checking again after %d seconds!\r\n' $cnt $PING_SUM $SLEEP_SEC 
        
        if [ $cnt == $PING_SUM ]
        then
            echo 'try to re curl' >> $LOG_PATH
            echo 'ifup wan!!!'
            sleep 5
	    receive=`curl 1.1.1.1`
	echo $receive
	strb="NextURL"
	if [[ "$receive" == *"user"* ]]
	then
	url1=${receive##*http://}
	url=${url1%%/api/r/*}
	echo "yse$url"
	id1=${receive#*api/r/}
	id=${id1%%?userip*}
	echo "yes"
	fi
	curl --location "http://${url}/api/account/login" \
	--header 'Content-Type: application/x-www-form-urlencoded' \
	--data-urlencode "username=$username" \
	--data-urlencode "password=$password" \
	--data-urlencode "nasId=${id}"
 
 
            cnt=0
            #重连后，等待10秒再进行ping检测
            sleep 8
            #网卡重启超过指定次数还没恢复正常，重启软路由
            reboot_cnt=`expr $reboot_cnt + 1`
            if [ $reboot_cnt == $REBOOT_CNT ]
            then
                echo -n `date '+%Y-%m-%d %H:%M:%S reboot!'` >> $LOG_PATH
                echo '-> Network has some problem, lets reboot' >> $LOG_PATH
                echo '-> =============== reboot!'
                reboot
            fi
        fi
    fi    
    sleep $SLEEP_SEC
done
