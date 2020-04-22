#!/bin/bash

cronjob() {
  PREFIX="$1"
  CONF_PATH="$2"
  if [ -z "$(crontab -l | grep mem_daemon)" ]; then
		# write out current crontab
		read -rep "With what periodicity should memory be checked (in minutes) ?: " ans
		crontab -l > "$CONF_PATH/mycron"
		# echo new cron into cron file
		echo "*/$ans * * * * $PREFIX/bin/mem_daemon 1 1 >> $CONF_PATH/md.log" \
         >> "$CONF_PATH/mycron"
		# install new cron file
		crontab "$CONF_PATH/mycron"
		rm "$CONF_PATH/mycron"
  else
		echo "crontab already installed"
  fi
}

cronjob "$@"
