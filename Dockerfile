FROM nginx:1.29.3-alpine3.22-slim

RUN rm /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/nginx.conf

COPY index.html /usr/share/nginx/html/index.html

RUN mkdir -p /data/opentopomap_proxy/cache \
    && mkdir -p /data/opentopomap_proxy/logs \
    && chown -R nginx:nginx /data/opentopomap_proxy

EXPOSE 80