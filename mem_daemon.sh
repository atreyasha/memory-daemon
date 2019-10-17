#!/bin/bash
set -e

# declare config directory
DIR="/home/$USER/.config/mem_daemon"

if [ -f $DIR/mail.conf ];then
    # read key parameters for memory daemon
    if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
        max_threshold=0
    else
        max_threshold=$(grep "threshold" $DIR/mail.conf | awk '{print $2}')
    fi
    receiver=$(grep "receiver" $DIR/mail.conf | awk '{print $2}')
    sender=$(grep "sender" $DIR/mail.conf | awk '{print $2}')
    pass=$(grep "pass" $DIR/mail.conf | awk '{print $2}')
    smtp=$(grep "smtp" $DIR/mail.conf | awk '{print $2}')
    port=$(grep "port" $DIR/mail.conf | awk '{print $2}')
    if [ -z $max_threshold ] || [ -z $receiver ] || [ -z $sender ] || [ -z $pass ] || [ -z $smtp ] || [ -z $port ]; then
        echo "missing parameters in $DIR/mail.conf, please ensure all parameters are defined"
        exit 2
    else
        # check if memory threshold is exceeded
        exceed=$(free | grep Mem | awk '{print $3/$2 * 100.0}' \
                    | awk -vt1=$max_threshold '{print ($1>=t1)?1:0}')
        # if memory is exceeded, capture proc-doc to trigger email
        if [ $exceed -eq 1 ]; then
            # get highest memory process
            proc=$(ps -eo pid:10,user:20,%cpu,%mem,args --sort -%mem | \
                    head | awk 'NR >= 0 && NR <= 2 {print}')
            user=$(echo "$proc" | awk 'FNR == 2 {print $2}')
            pid=$(echo "$proc" | awk 'FNR == 2 {print $1}')
            nc=$(echo "$proc" | awk 'FNR == 1 {print NF}')
            if [[ "$user" == "$(whoami)" ]]; then
                if [ $1 -eq 1 ]; then
                    echo "dummy test"
                else
                    echo "killing: \n $proc"
                    kill $pid
                fi
                self=1
            else
                self=0
            fi
            # send out email
            if [ $2 -eq 1 ]; then
            /home/$USER/bin/mem_daemon_mail --receiver "$receiver" --sender "$sender" \
                    --password "$pass" --text "$proc" --smtp "$smtp" --port "$port" \
                    --threshold "$max_threshold" --columns-log $nc --selfie $self
            fi
        fi
        # leave subshell once all is well
        exit 0
    fi
else
    echo "$DIR/mail.conf does not exist"
    exit 1
fi
