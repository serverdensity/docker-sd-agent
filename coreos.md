# CoreOS Support

- Create a device for each host in your cluster using the following scheme: `etcdctl set /serverdensity/agent_key/$HOSTNAME $AGENT_KEY` E.g. For a 3 host cluster made up of `core-01`, `core-02` and `core-03` set the following
```
	etcdctl set /serverdensity/agent_key/core-01 $AGENT_KEY-1
	etcdctl set /serverdensity/agent_key/core-02 $AGENT_KEY-2
	etcdctl set /serverdensity/agent_key/core-03 $AGENT_KEY-3
```
- Deploy your account to etcd: `etcdctl set /serverdensity/ACCOUNT $ACCOUNT`
- Copy [sd-agent.service](sd-agent.service) to your server
- Load the agent unit into fleet: `fleetctl load sd-agent.service`
- Start the agent everywhere : `fleetctl start sd-agent.service`
