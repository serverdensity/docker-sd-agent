# docker-sd-agent
Server Density Agent Dockerfile. https://hub.docker.com/r/serverdensity/sd-agent/

## Quick Start
The default image is ready-to-go. You just need to set your AGENT_KEY and ACCOUNT in the environment.

```
docker run -d --name sd-agent -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```
You can also enable DEBUG mode and set the hostname in your sd-agent config.cfg

```
docker run -d --name sd-agent -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT -e LOG_LEVEL=$LOG_LEVEL serverdensity/sd-agent
```

## Full list of env variables 
The following environment variables can be used when running the container:

* `AGENT_KEY` - Your agent key, can be found in your UI
* `ACCOUNT` - Your account name 
* `LOG_LEVEL` - The log level of the agent running in the container
* `SD_HOSTNAME` - The hostname specified in your containered agent's config.cfg (Note that this does not set the container hostname)
* `PROXY_HOST` - Configures a proxy host for the agent
* `PROXY_PORT` - Configures a proxy port for the agent
* `PROXY_USER` - Configures a proxy user for the agent
* `PROXY_PASSWORD` - Configures a proxy password for the agent
* `CONTAINER_SIZE` - Set to `TRUE` to enable container size metrics
* `IMAGE_STATS` - Set to `TRUE` to enable image stat metrics
* `IMAGE_SIZE` - Set to `TRUE` to enable image size metrics
* `DISK_STATS` - Set to `TRUE` to enable disk stat metrics
* `TIMEOUT` - Set the timeout for the docker_daemon check in seconds

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

## Enabling Plugins
### Official Plugins
You can enable official plugins by mounting the conf.d & checks.d folders which will be copied to the correct locations for the agent when the container starts. Checks and config files can be found at the [sd-agent repo](https://github.comserverdensity/sd-agent).

1. Create a a configuration directroy on your host and copy your YAML files to the new directory: 
	```
	mkdir /opt/conf.d
	wget https://raw.githubusercontent.com/serverdensity/sd-agent/master/conf.d/apache.yaml.example -O /opt/conf.d/apache.yaml
	```
2. Create a checks directory and copy your `check.py` files to the new directory: 
	```
	mkdir /opt/checks.d
	wget https://raw.githubusercontent.com/serverdensity/sd-agent/master/checks.d/apache.py -P /opt/checks.d
	```
3. When creating the container mount the directories: 
	```
	docker run -d --name sd-agent \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /proc/:/host/proc/:ro \
		-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
		-v /opt/conf.d:/conf.d:ro \
		-v /opt/checks.d:/checks.d:ro \	
		-e AGENT_KEY=$AGENT_KEY \
		-e ACCOUNT=$ACCOUNT \
		serverdensity/sd-agent
	```
	It's important to note the addition of `-v /opt/conf.d:/conf.d:ro -v /opt/checks.d:/checks.d:ro`

Now when the container starts the checks and their configs will be copied to the correct directories. 

### Custom plugins 
1. Create a plugins directory and copy your `check.py` files to the new directory: 
	```
	mkdir /opt/plugins
	touch /opt/plugins/Plugin.py
	```
2. When creating the container mount the directories: 
	```
	docker run -d --name sd-agent \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /proc/:/host/proc/:ro \
		-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
		-v /opt/plugins:/plugins:ro \
		-e AGENT_KEY=$AGENT_KEY \
		-e ACCOUNT=$ACCOUNT \
		serverdensity/sd-agent
	```
	It's important to note the addition of `-v /opt/plugins:/plugins:ro`

Now when the container starts your custom plugins will be copied to the correct directories for the agent. 

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
docker run -d --name sd-agent --net=host -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```

To enable host process list metrics run the container with `--pid=host`

```
docker run -d --name sd-agent --pid=host -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```

Both options can be combined: 

```
docker run -d --name sd-agent --net=host --pid=host -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e AGENT_KEY=$AGENT_KEY -e ACCOUNT=$ACCOUNT serverdensity/sd-agent
```