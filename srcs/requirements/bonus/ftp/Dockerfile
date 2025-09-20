FROM debian:bookworm

# Install vsftpd
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create FTP user
RUN useradd -m -d /var/www/wordpress -s /bin/bash ftpuser && \
    echo "ftpuser:ftppass123" | chpasswd

# Configure vsftpd
COPY conf/vsftpd.conf /etc/vsftpd.conf

# Create necessary directories
RUN mkdir -p /var/run/vsftpd/empty && \
    chmod 755 /var/run/vsftpd/empty

EXPOSE 21 20 21100-21110

CMD ["vsftpd", "/etc/vsftpd.conf"]