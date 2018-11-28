# docker-sd-agent
Server Density Agent Dockerfile. https://hub.docker.com/r/serverdensity/sd-agent/

## Quick Start
The default image is ready-to-go. You just need to set your AGENT_KEY and ACCOUNT in the environment.

```
docker run -d --name sd-agent -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```
You can also enable DEBUG mode and set the hostname in your sd-agent config.cfg

```
docker run -d --name sd-agent -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT -e LOG_LEVEL=$LOG_LEVEL serverdensity/sd-agent
```

## Full list of env variables
The following environment variables can be used when running the container:

* `AGENT_KEY` - Your agent key, can be found in your UI *Required*
* `ACCOUNT` - Your account name *Required*
* `LOG_LEVEL` - The log level of the agent running in the container
* `SD_HOSTNAME` - The hostname specified in your containered agent's config.cfg (Note that this does not set the container hostname)
* `PROXY_HOST` - Configures a proxy host for the agent
* `PROXY_PORT` - Configures a proxy port for the agent
* `PROXY_USER` - Configures a proxy user for the agent
* `PROXY_PASSWORD` - Configures a proxy password for the agent
* `NON_LOCAL_TRAFFIC` - Enable (non local traffic support)[https://support.serverdensity.com/hc/en-us/articles/360001065203]
* `CONTAINER_SIZE` - Set to `TRUE` to enable container size metrics
* `IMAGE_STATS` - Set to `TRUE` to enable image stat metrics
* `IMAGE_SIZE` - Set to `TRUE` to enable image size metrics
* `DISK_STATS` - Set to `TRUE` to enable disk stat metrics
* `TIMEOUT` - Set the timeout for the docker_daemon check in seconds
* `SDSTATSD` - Set to `TRUE` to enable `sd-agent-sdstatsd`
* `SDSTATSD_NAMESPACE` - Set a namespace for SDStatsD metrics. This will change `custom.metric` into `namespace.custom.metric`
* `SDSTATSD_UTF8` - Enables UTF8 decoding for SDStatsD
* `SDSTATSD_SO_RCVBUF` - The number of bytes allocated to the statsd socket receive buffer

## Building the image
Download the [Dockerfile](Dockerfile) and [entrypoint.sh](entrypoint.sh) script, and build the image.

```
docker build -t sd-agent .
```

## Information
Get info regarding the sd-agent service:
```
docker exec sd-agent service sd-agent info
```

## SDStatsD
SDStatsD is available in the container but is disabled by default.

### Enabling SDStatsD
#### Env Variables

To enable SDStatsD pass the env variable `SDSTATSD` to the container. The value does not matter, the container simply checks for the presence of this variable. `NON_LOCAL_TRAFFIC` is also required to allow the agent to receive metrics from any IP address (*NOTE*: This is a potential security risk as it allows metrics to be posted from any IP address. Please ensure that your host configuration does not allow external access to this port to prevent this). For example:

```
docker run -d --name sd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-e AGENT_KEY=$AGENT_KEY \
-e ACCOUNT=$ACCOUNT \
-e SDSTATSD="TRUE" \
-e NON_LOCAL_TRAFFIC="TRUE" \
serverdensity/sd-agent
```

#### Port

Note that you will need to publish the port to make use of SDStatsD:

```
docker run -d --name sd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-e AGENT_KEY=$AGENT_KEY \
-e ACCOUNT=$ACCOUNT \
-e SDSTATSD="TRUE" \
-e NON_LOCAL_TRAFFIC="TRUE" \
-p 127.0.0.1:8125:8125/udp \
serverdensity/sd-agent
```
The above example will make the port available on the host only. If you want the port to be available from anywhere you should use the following instead:

```
-p 8125:8125/udp
```

## Enabling Plugins
### Official Plugins
You can enable official plugins by mounting the conf.d & checks.d folders which will be copied to the correct locations for the agent when the container starts. Checks and config files can be found at the [sd-agent-core-plugins repo](https://github.com/serverdensity/sd-agent-core-plugins).

The example below is for MySQL, however any plugin can be used.

1. Create a a configuration directory on your host and download the `conf.yaml.example` YAML configuration file to the new directory, with the correct name (the name used should be the same as the directory of the check in the [sd-agent-core-plugins repo](https://github.com/serverdensity/sd-agent-core-plugins) repository):

    ```
    mkdir -p /opt/sd-agent/conf.d
    wget https://raw.githubusercontent.com/serverdensity/sd-agent-core-plugins/master/mysql/conf.yaml.example -O /opt/sd-agent/conf.d/mysql.yaml
    ```

2. Edit the configuration file for your chosen plugin.

3. Create a checks directory and download the `check.py` file to the new directory, with the correct name (the name used should be the same as the directory of the check in the [sd-agent-core-plugins repo](https://github.com/serverdensity/sd-agent-core-plugins) repository):

    ```
    mkdir -p /opt/sd-agent/checks.d
    wget https://raw.githubusercontent.com/serverdensity/sd-agent-core-plugins/master/mysql/check.py -P /opt/sd-agent/checks.d/mysql.py
    ```

4. When creating the container mount the `check` and `conf` directories:

    ```
    docker run -d --name sd-agent \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v /proc/:/host/proc/:ro \
        -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
        -v /opt/sd-agent/conf.d:/conf.d:ro \
        -v /opt/sd-agent/checks.d:/checks.d:ro \
        -e AGENT_KEY=$AGENT_KEY \
        -e ACCOUNT=$ACCOUNT \
        serverdensity/sd-agent
    ```

    It's important to note the addition of `-v /opt/conf.d:/conf.d:ro -v /opt/checks.d:/checks.d:ro`

Now when the container starts the checks and their configs will be copied to the correct directories.

### Custom plugins - v2 (Preferred)
1. Create a custom plugin as per the [Information about Custom Plugins - v2](https://support.serverdensity.com/hc/en-us/articles/115014887548) document.

2. Create a configuration directory (if you're using official plugins too you may already have this) and copy your custom plugin `conf.yaml` files to the new directory:

    ```
    mkdir -p /opt/sd-agent/conf.d
    cp ~/Example.yaml /opt/sd-agent/conf.d/Example.yaml
    ```

3. Edit the configuration file for your custom plugin.

4. Create a checks directory and copy your custom plugin `check.py` file to the new directory:

    ```
    mkdir -p /opt/sd-agent/checks.d
    cp ~/Example.py /opt/sd-agent/checks.d/Example.py
    ```

4. When creating the container mount the `check` and `conf` directories:

    ```
    docker run -d --name sd-agent \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v /proc/:/host/proc/:ro \
        -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
        -v /opt/sd-agent/conf.d:/conf.d:ro \
        -v /opt/sd-agent/checks.d:/checks.d:ro \
        -e AGENT_KEY=$AGENT_KEY \
        -e ACCOUNT=$ACCOUNT \
        serverdensity/sd-agent
    ```

    It's important to note the addition of `-v /opt/conf.d:/conf.d:ro -v /opt/checks.d:/checks.d:ro`

Now when the container starts your v2 custom plugins will be copied to the correct directories for the agent.

### Custom plugins - v1 (Legacy)
1. Create a plugins directory and copy your `check.py` files to the new directory:

    ```
    mkdir /opt/plugins
    touch /opt/plugins/Plugin.py
    ```

2. When creating the container mount the directories:

   ```
    docker run -d --name sd-agent \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v /proc/:/host/proc/:ro \
        -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
        -v /opt/plugins:/plugins:ro \
        -e AGENT_KEY=$AGENT_KEY \
        -e ACCOUNT=$ACCOUNT \
        serverdensity/sd-agent
    ```

    It's important to note the addition of `-v /opt/plugins:/plugins:ro`

Now when the container starts your v1 custom plugins will be copied to the correct directories for the agent.

## Logs
### Copy logs from the container to the host
Use the following to copy the sd-agent logs from the container to your host:
`docker cp sd-agent:/var/log/sd-agent /tmp/log-sd-agent`

### Supervisor logs
Basic information about the Agent execution is available via dockers `logs` command.
`docker logs sd-agent`
You can also exec a shell on the container and tail the logs from there for debugging. (Note that the following logs are availabe: collector.log, forwarder.log and supervisord.log)
```
$ docker exec -it sd-agent bash
# tail -f /var/log/sd-agent/collector.log
2016-09-22 14:49:52 UTC | DEBUG | sd.collector | checks.collector(emitter.py:52) | payload_size=41161, compressed_size=41161, compression_ratio=1.000
2016-09-22 14:49:53 UTC | DEBUG | sd.collector | checks.check_status(check_status.py:136) | Persisting status to /run/sd-agent/CollectorStatus.pickle
2016-09-22 14:49:53 UTC | DEBUG | sd.collector | checks.collector(collector.py:561) | Finished run #22. Collection time: 9.0s. Emit time: 0.79s
```
## Limitations
The Agent cannot collect disk metrics from volumes that are not mounted to the Agent container. If you want to monitor additional partitions, make sure to share them to the container when executing the docker run command (e.g. `-v /data:/data:ro`)

As docker isolates containers from the host the Agent cannot access all host metrics.

Known missing/incorrect metrics:

* Network
* Process list

These limitations can be worked around by telling docker not to containerize the network and by using the host's PID namespace inside the container.
### Workarounds
To enable host network metrics run the container with `--net=host`

```
docker run -d --name sd-agent --net=host -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```

To enable host process list metrics run the container with `--pid=host`

```
docker run -d --name sd-agent --pid=host -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```

Both options can be combined:

```
docker run -d --name sd-agent --net=host --pid=host -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```
