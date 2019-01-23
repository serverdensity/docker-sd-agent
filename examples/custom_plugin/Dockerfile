FROM serverdensity/sd-agent

# Add Custom plugin configuration (portmon)
ADD portmon.yaml /etc/sd-agent/conf.d/portmon.yaml

# Add Custom plugin check (portmon)
ADD portmon.py /usr/share/python/sd-agent/checks.d/portmon.py
