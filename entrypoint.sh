#!/bin/bash
set -e

# Agent Config
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

if [[ $NON_LOCAL_TRAFFIC ]]; then
    echo "non_local_traffic: true" >> /etc/sd-agent/config.cfg
fi

# Sdstatsd Config
if [[ $SDSTATSD ]]; then
    sed -i -e "s/# use_sdstatsd: yes/use_sdstatsd: yes/g" /etc/sd-agent/config.cfg
else
    sed -i -e "s/# use_sdstatsd: yes/use_sdstatsd: no/g" /etc/sd-agent/config.cfg
fi

if [[ $SDSTATSD_NAMESPACE ]]; then
    sed -i -e "s/# statsd_metric_namespace:/statsd_metric_namespace: ${SDSTATSD_NAMESPACE}/g" /etc/sd-agent/config.cfg
fi

if [[ $SDSTATSD_UTF8 ]]; then
    sed -i -e "s/# utf8_decoding: false/utf8_decoding: true/g" /etc/sd-agent/config.cfg
fi

if [[ $SDSTATSD_SO_RCVBUF ]]; then
    sed -i -e "s/# statsd_so_rcvbuf:/statsd_so_rcvbuf: ${SDSTATSD_SO_RCVBUF}/g" /etc/sd-agent/config.cfg
fi

# Docker Check Config
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
