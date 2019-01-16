FROM nginx:1.15.1
RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/
RUN rm /etc/nginx/conf.d/default.conf
COPY example.com.conf /etc/nginx/conf.d/
COPY index.html /var/www/index.html
