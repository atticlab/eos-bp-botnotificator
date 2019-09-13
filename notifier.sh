#!/bin/bash
check ()
{
NAME=`echo $IP |awk -F ";" '{print $1}' | sed 's/NODE=//g'`
IPN=`echo $IP | awk -F ";" '{print $2}'`
for (( ITERATION=1; ITERATION<=$ITERATIONS; ITERATION++ )); do
        INITIAL=`curl --insecure --connect-timeout 6 -s http://$IPN/v1/chain/get_info |jq -r ".head_block_num"`
        if [ -z $INITIAL ]; then
                continue
        fi
        sleep 10;
        BLOCK=`curl --insecure --connect-timeout 6 -s http://$IPN/v1/chain/get_info |jq -r ".head_block_num"`
        if [ -z $BLEOS ]; then
                continue
        else
                break
        fi
done
if [ -z $INITIAL ]; then
        echo "node is down"
        curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN doesn't work. Please check http://$IPN/v1/chain/get_info"
else
        if [ -z $BLOCK ]; then
                echo "node is down"
                curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN doesn't work. Please check http://$IPN/v1/chain/get_info"
        else
                if [ "$INITIAL" -eq "$BLOCK" ]; then
                        echo "Node is STOP"
                        curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN stopped at block $BLEOS. Please check http://$IPN/v1/chain/get_info"
                fi
        fi
fi
}

CHATID=`cat ${PWD}/config.ini | grep -v "#" | grep "CHATID" | awk -F "=" '{print $2}'`
BOTNUMBER=`cat ${PWD}/config.ini | grep -v "#" | grep "BOTNUMBER" | awk -F "=" '{print $2}'`
PWD=$PWD
STATE=0
ITERATIONS=3
while true; do
	NODEIP=`cat ${PWD}/config.ini | grep -v "#" | grep "NODE"`
	for IP in $NODEIP
	do
		check $IP
	done
	sleep 10;
done


