FROM serverdensity/sd-agent

# Install the MySQL plugin
RUN apt-get update && apt-get install sd-agent-mysql -y
# Add MySQL check configuration
ADD mysql.yaml /etc/sd-agent/conf.d/mysql.yaml

# Cleanup apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
