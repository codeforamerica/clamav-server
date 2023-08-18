FROM golang:alpine AS build-env
ENV CGO_ENABLED 0
WORKDIR /app
RUN apk add --no-cache git ca-certificates make cmake
ENV GOBIN=/app/bin
RUN git clone https://github.com/ifad/clammit . && make all

# Build runtime image
FROM alpine:latest
RUN apk --no-cache add ca-certificates clamav curl && \
    addgroup -S clam && adduser -u 101 -S -G clam clam

WORKDIR /home/clam

COPY launcher.sh /

ARG APTIBLE_ENV=/app/.aptible.env
# Set permissions, and create required directories and files
RUN set -a  && \
    if [ -e ${APTIBLE_ENV} ] ; then . ${APTIBLE_ENV} ; fi && \
    mkdir -p /var/log/clamav && touch /var/log/clamav/clamd.log && touch /var/log/clamav/freshclam.log && \
    mkdir -p /run/clamav && touch /run/clamav/clamd.pid && \
    chown -R clam:clam /run/clamav && \
    chown -R clam:clam /var/log/clamav && \
    chown clam /var/spool/cron/crontabs/root && \
    chmod 644 /var/log/clamav/* && \
    chown -R clam /var/lib/clamav/ && \
    chown clam /launcher.sh && \
    chmod g+s /var/spool/cron/crontabs/root && \
    chmod +x /launcher.sh && \
    echo "0 0/2 * * * freshclam" >> /var/spool/cron/crontabs/root && \
    # Configure clamd to listen on TCP
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    echo "TCPAddr 127.0.0.1" >> /etc/clamav/clamd.conf

RUN echo "*** Variables: " && \
    echo ${CLAMMIT_LISTEN} && \
    echo ${CLAMMIT_CLAMD_URL} && \
    echo "***"

# Switch to clam user and update virus definitions
USER clam
RUN freshclam

# Copy clammit binaries and test files
COPY --from=build-env --chown=clam:clam /app/bin/clammit .
COPY --from=build-env --chown=clam:clam /app/testfiles ./testfiles

EXPOSE 8438

CMD ["sh", "/launcher.sh", "/home/clam/clammit.cfg", "/home/clam/clammit", "-config", "clammit.cfg"]
