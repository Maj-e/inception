FROM debian:bookworm

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        bash \
        ca-certificates \
        gnupg \
        lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Netdata
RUN apt-get update && \
    apt-get install -y netdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Netdata
COPY conf/netdata.conf /etc/netdata/netdata.conf

EXPOSE 19999

# Use Netdata's built-in user
USER netdata

CMD ["/usr/sbin/netdata", "-D"]