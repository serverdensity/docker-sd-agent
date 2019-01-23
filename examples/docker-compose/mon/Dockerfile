FROM serverdensity/sd-agent:latest
RUN apt-get update && apt-get install sd-agent-nginx -y
ADD nginx.yaml /etc/sd-agent/conf.d/nginx.yaml
