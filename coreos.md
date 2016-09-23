# CoreOS Support

1. Deploy your agent key to etcd: `etcdctl set /serverdensity/AGENT_KEY abcdefghijklmnopqrstuvwxzy`
1. Deploy your account to etcd: `etcdctl set /serverdensity/ACCOUNT abcdefghijklmnopqrstuvwxzy`
1. Copy [sd-agent.service](sd-agent.service) to your server
1. Load the agent unit into fleet: `fleetctl load sd-agent.service`
1. Start the agent everywhere : `fleetctl start sd-agent.service`