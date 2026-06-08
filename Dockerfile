FROM alpine:latest

ARG RAD_URL=https://files.radicle.dev/releases/latest/radicle-1.9.1-x86_64-unknown-linux-musl.tar.xz

RUN apk add --no-cache curl xz ca-certificates git openssh-client \
    && curl -fsSL "$RAD_URL" -o /tmp/rad.tar.xz \
    && tar -xJf /tmp/rad.tar.xz -C /tmp \
    && cp /tmp/radicle-*/bin/* /usr/local/bin/ \
    && rm -rf /tmp/rad.tar.xz /tmp/radicle-*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

# run as container-root: under rootless docker this maps to the host user
# that owns the bind mount, so RAD_HOME is writable and host backups are clean.
WORKDIR /root
ENV RAD_HOME=/root/.radicle

EXPOSE 8776
ENTRYPOINT ["entrypoint.sh"]
