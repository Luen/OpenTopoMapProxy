FROM nginx:latest

RUN rm /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /data/opentopomap_proxy/cache \
    && mkdir -p /data/opentopomap_proxy/logs \
    && chown -R nginx:nginx /data/opentopomap_proxy

EXPOSE 80