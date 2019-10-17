#!/bin/bash

# base configuration directory
DIR="/home/$USER/.config/mem_daemon"

# option menu
options=(
    "Install memory daemon"
    "Edit mail.conf"
    "Test memory daemon with dummy trigger"
    "Add crontab for memory daemon"
    "Uninstall memory daemon"
)

install_mem_daemon(){
    echo  "checking for existence of $DIR and /home/$USER/bin; creating where necessary... "
    mkdir -p $DIR
    mkdir -p "/home/$USER/bin"
    echo "copying default mail configuration to $DIR..."
    if [ -f $DIR/mail.conf ]; then
        read -rep "keep previous mail.conf configuration? (y|n): " ans
        if [ $ans == "n" ]; then
           mv $DIR/mail.conf $DIR/mail.conf.bak
           cp ./aux/mail.conf $DIR/mail.conf
        fi
    else
        cp ./aux/mail.conf $DIR/mail.conf
    fi
    if [ -z $(echo $PATH | grep "/home/$USER/bin") ]; then
        echo -n "adding /home/$USER/bin to system path"
        echo "export PATH=$PATH:/home/$USER/bin" >> /home/$USER/.bashrc
        source /home/$USER/.bashrc
        echo -n "... done"
    fi
    echo "copying executables to /home/$USER/bin..."
    cp mem_daemon /home/$USER/bin/mem_daemon
    cp mem_daemon_mail.py /home/$USER/bin/mem_daemon_mail
    chmod +x /home/$USER/bin/mem_daemon_mail
    echo "installation complete! fill out $DIR/mail.conf with email-related details to use this service"
}

uninstall_mem_daemon(){
    # remove executables
    echo "removing executables from /home/$USER/bin..."
    rm -f /home/$USER/bin/mem_daemon
    rm -f /home/$USER/bin/mem_daemon_mail
    # remove crontab
    read -rep "remove mem_daemon crontab (if it exists)? (y|n): " ans
    if [[ $ans == "y" ]]; then
        crontab -l > $DIR/mycron
        # echo new cron into cron file
        sed -i "/mem_daemon/d" $DIR/mycron
        # install new cron file
        crontab $DIR/mycron
        rm $DIR/mycron
    fi
}

# case selection plan
select option in "${options[@]}"; do
    case "$REPLY" in
        1) install_mem_daemon
           break
           ;;
        2) vim $DIR/mail.conf
	         break
	         ;;
        3) echo "An email will be sent to your specified address, but fret not; no process will be killed"
           mem_daemon 1 1
	         break
	         ;;
        4) mem_daemon 1 0
           if [ $(echo $?) -eq 2 ]; then
              echo "please fill out $DIR/mail.conf before setting up a crontab"
              exit 1
           fi
           if [ -z $(crontab -l | grep "mem_daemon") ]; then
                # write out current crontab
                read -rep "With what periodicity should memory be checked (in minutes) ?: " ans
                crontab -l > $DIR/mycron
                # echo new cron into cron file
                echo "*/$ans * * * * /home/$USER/bin/mem_daemon 0 1" >> $DIR/mycron
                # install new cron file
                crontab $DIR/mycron
                rm $DIR/mycron
           fi
           break
           ;;
	      5) uninstall_mem_daemon
	         break
	         ;;
    esac
done
