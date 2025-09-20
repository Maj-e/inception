FROM debian:bookworm

# Install Redis
RUN apt-get update && \
    apt-get install -y redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Redis
RUN sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf && \
    sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf && \
    sed -i 's/# maxmemory <bytes>/maxmemory 256mb/' /etc/redis/redis.conf && \
    sed -i 's/# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf", "--daemonize", "no"]