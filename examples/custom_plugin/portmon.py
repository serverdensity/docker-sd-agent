import time
import socket

from checks import AgentCheck


class PortMon(AgentCheck):
    def check(self, instance):
        # Load default_timeout value from the init_config, if not present default to 5
        default_timeout = self.init_config.get('default_timeout', 5)
        # Load port value from the instance config
        port = instance.get('port', 80)
        # Attempt to load the timeout from the instance config. If not present fallback to default_timeout
        timeout = float(instance.get('timeout', default_timeout))
        # If we don't find a server for this instance stop the check now
        if 'server' not in instance:
            # Output to the info log that we're skipping this instance due to no server being configured
            self.log.info("Skipping instance, no server found.")
            return
        server = instance['server']
        # Attempt to load the tags from the instance config. If not present fallback to an empty list
        tags = instance.get('tags', [])
        # Append the tag 'server: server:port' to the tags list, based on the values loaded from the instance config.
        tags.append("server: {}:{}".format(server,port))
        # A handy debug line in case we need to output information for troubleshooting
        self.log.debug("Timeout set to {} for {}:{} with tags: {}".format(timeout, server, port, tags))

        # Begin the check by creating a socket
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # Set the timeout on the socket to the configured timeout
        s.settimeout(timeout)
        # Get the current time so we can calculate the response time
        t_init = time.time()
        # Attempt the following unless an error is seen
        try:
            # Set status to 1, so we can report back a simple status metric
            status = 1
            # Attempt to connect to a remote socket at server, port
            s.connect((server, port))
            # Measure the response time from the timestamp we took earlier in the check
            response_time = time.time() - t_init
            # Close the socket
            s.close()
        # If we see a socket error or a socket timeout
        except (socket.error, socket.timeout):
            # As this is an error condition we'll set the response time to '-1'
            # so that it's obvious the connection failed when viewing graphs
            response_time =  -1
            # We'll also set the status to 0 as this is an error
            status = 0
        # Set the portmon.response.time metric, along with the tags we set earlier
        self.gauge('portmon.reponse.time', response_time, tags=tags)
        # Set the portmon.response.status metric, along with the tags we set earlier
        self.gauge('portmon.reponse.status', status, tags=tags)
        # The check is complete.
        # Once all instances have completed checks the results will be sent to Server Density!

if __name__ == '__main__':
    # Load the check and instance configurations
    check, instances = PortMon.from_yaml('/etc/sd-agent/conf.d/portmon.yaml')
    for instance in instances:
        print "\nRunning the check against host: {}:{}".format(instance['server'],instance.get('port', 80))
        check.check(instance)
        print 'Metrics: {}'.format(check.get_metrics())
