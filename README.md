# docker-sd-agent
Server Density Agent Dockerfile for Trusted Builds. https://registry.hub.docker.com/u/serverdensity/

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

## Building the image
Download the [Dockerfile](DockerFile) and [entrypoint.sh](entrypoint.sh) script, and build the image. 

```
docker build -t sd-agent .
```

## Information
Get info regarding the sd-agent service: 
```
docker exec sd-agent service sd-agent info
```

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