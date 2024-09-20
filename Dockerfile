# Use the official Nginx image as the base
FROM nginx:latest

# Remove the default Nginx configuration
RUN rm /etc/nginx/nginx.conf

# Copy your custom Nginx configuration into the container
COPY nginx.conf /etc/nginx/nginx.conf

# Create necessary directories for cache and logs
RUN mkdir -p /data/opentopomap_proxy/cache \
    && mkdir -p /data/opentopomap_proxy/logs \
    && chown -R nginx:nginx /data/opentopomap_proxy

# Expose port 80 to the host
EXPOSE 80

# The Nginx base image already specifies CMD ["nginx", "-g", "daemon off;"]
