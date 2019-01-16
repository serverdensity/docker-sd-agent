FROM serverdensity/sd-agent

# Install the MySQL & nginx plugins
RUN apt-get update && apt-get install sd-agent-mysql sd-agent-nginx -y
# Add MySQL check configuration
ADD mysql.yaml /etc/sd-agent/conf.d/mysql.yaml
# Add nginx check configuration
ADD nginx.yaml /etc/sd-agent/conf.d/nginx.yaml

# Cleanup apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
