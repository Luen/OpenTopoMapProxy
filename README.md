# OpenTopoMap Proxy

This is a blazing-fast Nginx proxy that caches tiles for one month. The Nginx proxy acts as an intermediary between clients (such as web browsers or mapping applications) and the OpenTopoMap tile servers. It handles incoming requests for map tiles, caches them locally, and serves them to clients. This setup improves performance, reduces bandwidth usage, and decreases load on the upstream servers. It ensures that if a tile is accessed at least twice, it's served from Nginx's static file cache. In this case, a simple 100 GB cache can cover the entire world, as it only caches titles that people view somewhat frequently. Nginx is really good at this. If run on a separate computer, this doesn't need a lot of CPU or memory; it just needs a decent SSD drive.

## How to Run

`docker compose up -d`

## How it works

### 1. How the Proxy Works

a. Client Request Handling

- Incoming Requests: When a client requests a map tile (e.g., a specific zoom level and coordinates), the request is directed to your proxy server.
- Cache Check: Nginx checks if the requested tile is already cached.
  - Cache Hit: If the tile is in the cache and valid, Nginx serves it directly from the cache.
  - Cache Miss: If not, Nginx forwards the request to the upstream servers to fetch the tile.

b. Upstream Servers Configuration

Upstream Block: In your `nginx.conf`, the upstream servers are defined:

```nginx
upstream opentopomap_proxy_servers {
    server a.tile.opentopomap.org;
    server b.tile.opentopomap.org;
    server c.tile.opentopomap.org;
}
```

Load Balancing: Nginx distributes requests among these servers, balancing the load and improving reliability.

c. Proxying and Caching

Proxy Pass: Requests are proxied to the upstream servers using:

```nginx
proxy_pass http://opentopomap_proxy_servers;
```

Caching Mechanism: Responses from the upstream servers are cached based on your caching rules.

### 2. Caching Behavior and Duration

a. Cache Storage Configuration

Cache Path: Defined in the http block:

```nginx
proxy_cache_path /data/opentopomap_proxy/cache levels=1:2 keys_zone=opentopomap_proxy_cache:10m max_size=10g inactive=1M use_temp_path=off;
```

- `/data/opentopomap_proxy/cache`: Directory where cached tiles are stored.
- `levels=1:2`: Directory hierarchy for cache files.
- `keys_zone=opentopomap_proxy_cache:10m`: Memory zone for caching keys, size 10MB.
- `max_size=10g`: Maximum cache size of 10 gigabytes.
- `inactive=1M`: Cached tiles not accessed for 1 month are removed.
- `use_temp_path=off`: Writes cache files directly to the cache directory.

b. Cache Control in Location Block

Caching Directives:

```nginx
location / {
    proxy_cache_key "$request_uri";
    proxy_cache opentopomap_proxy_cache;
    proxy_cache_lock on;
    proxy_cache_min_uses 2;
    proxy_ignore_headers Cache-Control expires;
    add_header Cache-Control public;
    add_header Access-Control-Allow-Origin *;
    expires 1M;
    proxy_cache_valid any 1M;
    # ... other directives ...
}
```

Explanation:

- `proxy_cache_key "$request_uri";`: Uses the request URI as the cache key.
- `proxy_cache opentopomap_proxy_cache;`: Specifies which cache zone to use.
- `proxy_cache_lock on;`: Ensures only one request at a time is allowed to populate a new cache item.
- `proxy_cache_min_uses 2;`: Caches a response only after it has been requested at least twice.
- `proxy_ignore_headers Cache-Control expires;`: Ignores these headers from the upstream server to enforce proxy cache settings.
- `add_header Cache-Control public;`: Adds a Cache-Control header to responses, indicating that the content can be cached by any cache.
- `add_header Access-Control-Allow-Origin *;`: Allows cross-origin requests, useful for web applications.
- `expires 1M;`: Sets the Expires header to 1 month from the time of the response.
- `proxy_cache_valid any 1M;`: Cached responses are considered valid for 1 month for any HTTP status code.

c. Cache Duration

- Cached for 1 Month: Tiles are cached for 1 month (`1M` stands for one month in Nginx time units).
  - Validity Period: For 1 month after a tile is cached, Nginx serves it from the cache without revalidating it with the upstream server.
  - Expiration: After 1 month, the cached tile expires and Nginx fetches a fresh copy from the upstream server upon the next request.
- Inactive Cache Items: Tiles not accessed for 1 month are automatically removed from the cache due to the `inactive=1M` setting.

### 3. Detailed Flow of a Tile Request

Initial Request:

- The client requests a tile for the first time.
- Nginx checks the cache and doesn't find the tile (cache miss).
- Since `proxy_cache_min_uses` is set to 2, Nginx doesn't cache this first response.
- Nginx forwards the request to an upstream server and serves the tile to the client.

Subsequent Requests:

- On the second request for the same tile, Nginx again fetches it from the upstream server.
- After the second request, Nginx caches the tile.

Serving from Cache:

- For the next 1 month, Nginx serves the tile from its cache.
- The `Expires` header tells clients they can also cache the tile for 1 month.

Cache Expiration and Refresh:

- After 1 month, the cached tile expires.
- The next request after expiration causes Nginx to fetch a fresh tile from the upstream server.

Inactive Tiles Removal:

- Tiles not requested for 1 month are removed from the cache to free up space.

### 4. Benefits of This Proxy Setup

Performance Improvement: Serving tiles from the local cache reduces latency and speeds up map loading times for clients.

Bandwidth Reduction: Decreases the amount of data transferred from the upstream servers, conserving bandwidth.

Load Balancing: Distributes requests among multiple upstream servers, enhancing reliability and efficiency.

Cross-Origin Resource Sharing (CORS): The `Access-Control-Allow-Origin *` header allows the tiles to be used in web applications hosted on different domains.

Cache Control: You have granular control over caching behavior, including cache duration, size, and conditions for caching.

### 5. Important Considerations

Disk Space Management: Monitor the cache directory to ensure it doesn't exceed the specified `max_size` or consume excessive disk space.

Upstream Server Policies: Ensure compliance with OpenTopoMap's usage policies, especially regarding caching and bandwidth usage.

Cache Invalidation: If tiles are updated upstream within the cache duration, clients may receive outdated tiles unless the cache is cleared manually.

Security: Be cautious with headers `like Access-Control-Allow-Origin *`; while it allows flexibility, it may have security implications if not managed properly.

### 6. Summary

Proxy Functionality: Acts as an intermediary, caching and serving map tiles to improve performance and reduce upstream load.

Caching Duration: Tiles are cached for 1 month, after which they expire and are refreshed upon the next request.

Cache Mechanism:

- `proxy_cache_min_uses 2;`: Ensures that only frequently requested tiles are cached.
- `proxy_cache_valid any 1M;`: Sets the cache validity period.
- `inactive=1M`: Removes tiles not accessed for 1 month.

Configuration Highlights:

- Load Balancing among upstream servers.
- CORS Support via `Access-Control-Allow-Origin *`.
- Client-Side Caching enabled through the `Expires` header.

### 7. Example Scenario

Suppose a user navigates a map in a web application:

First Visit: The proxy fetches tiles from the upstream servers. Tiles are served to the client but not cached yet.

Repeated Navigation: As the user continues to navigate, tiles requested at least twice are cached. Subsequent users benefit from faster load times as cached tiles are served directly.

After 1 Month: Cached tiles expire. New requests for those tiles cause the proxy to fetch updated tiles from upstream servers.

Unused Tiles: Tiles not accessed for over a month are purged from the cache to optimize storage.

### 8. Monitoring and Maintenance

- Logs: Regularly check Nginx access and error logs to monitor performance and troubleshoot issues.
- Cache Size: Keep an eye on the cache size to prevent it from exceeding the `max_size` limit.
- Updates: If the OpenTopoMap servers update their tiles frequently, consider adjusting the cache duration accordingly.
- Security Updates: Ensure that the Nginx server and Docker image are kept up to date with the latest security patches.
