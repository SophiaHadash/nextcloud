#!/bin/bash

# configure application prior to build
if test -f ".env"; then
  export $(cat .env | xargs)
fi

# test availability of environment variables
if [ -z "$MYSQL_PASSWORD" ]; then echo "Environment variable MYSQL_PASSWORD is unset or empty." && exit 1; fi
if [ -z "$NEXTCLOUD_PATH" ]; then echo "Environment variable NEXTCLOUD_PATH is unset or empty." && exit 1; fi
if [ -z "$NEXTCLOUD_PATH" ]; then echo "Environment variable BACKUP_PATH is unset or empty." && exit 1; fi

# define some derivative variables
export MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD
export MYSQL_DATABASE=nextcloud
export MYSQL_USER=nextcloud

# clone rsnapshot-docker
git clone https://github.com/helmuthb/rsnapshot-docker


# generate synapse default config
#docker run -it --rm \
#    --mount type=bind,src=$NEXTCLOUD_PATH/synapse,target=/data \
#    -e SYNAPSE_SERVER_NAME=synapse.sophiahadash.nl \
#    -e SYNAPSE_REPORT_STATS=yes \
#    matrixdotorg/synapse:3af9bb7198c64c6e6001b96cbfadc0bc2123d318-multiarch generate

# deploy
docker-compose --env-file ./.env -f nextcloud.yml -p letsencrypt up -d

# create cron-job entries
croncmd="docker exec -u www-data nextcloud:fpm php -f /var/www/html/cron.php"
cronjob="*/5 * * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

croncmd="docker-compose -f /home/shadash/nextcloud/letsencrypt/renew.yml -p letsencrypt up && docker-compose -f /home/shadash/nextcloud.yml -p letsencrypt up -d"
cronjob="0 23 * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -