#!/bin/bash
set -e

if [[ $API_KEY ]]; then
  if [[ $SD_HOSTNAME ]]; then
    name=`$SD_HOSTNAME`
  else
    name=`hostname -s`
  fi

  base_url="https://api.serverdensity.io/inventory"

  uri="$base_url/resources?token=$API_KEY&filter={\"name\":\"$name\",\"type\":\"device\"}&fields=[\"agentKey\"]"
  export AGENT_KEY=`curl -sg $uri | sed -n -e 's/.*"agentKey":"\([0-9a-f]*\)".*/\1/p'`

  if [[ -z "$AGENT_KEY" ]]; then
    uri="$base_url/devices/?token=$API_KEY"
    export AGENT_KEY=`curl -sX POST $uri -d "name=$name" | sed -n -e 's/.*"agentKey":"\([0-9a-f]*\)".*/\1/p'`
  fi
fi

if [[ $AGENT_KEY ]]; then
    sed -i -e "s/^.*agent_key:.*$/agent_key: ${AGENT_KEY}/" /etc/sd-agent/config.cfg
else
    echo "You must set AGENT_KEY environment variable to run the SD-Agent container"
    exit 1
fi

if [[ $ACCOUNT ]]; then
    sed -i -e "s/^.*sd_account:.*$/sd_account: ${ACCOUNT}/" /etc/sd-agent/config.cfg
else
    echo "You must set ACCOUNT environment variable to run the SD-Agent container"
    exit 1
fi
if [[ $SD_HOSTNAME ]]; then
    sed -i -e "s/^#hostname:.*$/hostname: ${SD_HOSTNAME}/" /etc/sd-agent/config.cfg
fi

if [[ $PROXY_HOST ]]; then
    sed -i -e "s/^# proxy_host:.*$/proxy_host: ${PROXY_HOST}/" /etc/sd-agent/config.cfg
fi

if [[ $PROXY_PORT ]]; then
    sed -i -e "s/^# proxy_port:.*$/proxy_port: ${PROXY_PORT}/" /etc/sd-agent/config.cfg
fi

if [[ $PROXY_USER ]]; then
    sed -i -e "s/^# proxy_user:.*$/proxy_user: ${PROXY_USER}/" /etc/sd-agent/config.cfg
fi

if [[ $PROXY_PASSWORD ]]; then
    sed -i -e "s/^# proxy_password:.*$/proxy_password: ${PROXY_PASSWORD}/" /etc/sd-agent/config.cfg
fi
if [[ $LOG_LEVEL ]]; then
    sed -i -e "s/^.*log_level:.*$/log_level: ${LOG_LEVEL}/" /etc/sd-agent/config.cfg
fi

if [[ "${CONTAINER_SIZE^^}" = "TRUE" ]]; then
    sed -i -e "s/# collect_container_size: false/collect_container_size: true/g" /etc/sd-agent/conf.d/docker_daemon.yaml
fi

if [[ "${IMAGE_STATS^^}" = "TRUE" ]]; then
    sed -i -e "s/# collect_images_stats: false/collect_images_stats: true/g" /etc/sd-agent/conf.d/docker_daemon.yaml
fi

if [[ "${IMAGE_SIZE^^}" = "TRUE" ]]; then
    sed -i -e "s/# collect_image_size: false/collect_image_size: true/g" /etc/sd-agent/conf.d/docker_daemon.yaml
fi

if [[ "${DISK_STATS^^}" = "TRUE" ]]; then
    sed -i -e "s/# collect_disk_stats: true/collect_disk_stats: true/g" /etc/sd-agent/conf.d/docker_daemon.yaml
fi

if [[ -z "$TIMEOUT" ]]; then
    TIMEOUT=10
fi

if [[ $TIMEOUT ]]; then
    sed -i -e "s/# timeout: 10/timeout: ${TIMEOUT}/g" /etc/sd-agent/conf.d/docker_daemon.yaml
fi

find /conf.d -name '*.yaml' -exec cp --parents {} /etc/sd-agent/ \;

find /checks.d -name '*.py' -exec cp {} /usr/share/python/sd-agent/checks.d/ \;

export PATH="/usr/share/python/sd-agent/bin:$PATH"

exec "$@"
