# OpenTopoMap tile cache proxy — Alpine slim nginx is appropriate (static HTML + proxy cache)
FROM nginx:1.31.2-alpine3.23-slim@sha256:dd722b8ee8794f3c273bfaf8b5351b0652a68ccd73c17e5f0d029857a58f25ef

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html robots.txt /usr/share/nginx/html/

RUN mkdir -p /data/opentopomap_proxy/cache /data/opentopomap_proxy/logs \
    && chown -R nginx:nginx /data/opentopomap_proxy

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
