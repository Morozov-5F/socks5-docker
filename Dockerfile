FROM alpine:3.7

ARG SOCKET_USER
ARG SOCKET_PASSWORD
ARG SOCKD_CONF_FILE

RUN adduser -s /bin/false -D -S -u 8062 -H $SOCKET_USER

RUN apk update
RUN apk add --no-cache linux-pam

# Install build dependacies for dante server
RUN apk add --no-cache -t .build-deps build-base linux-pam-dev
RUN set -x && apk add --no-cache linux-pam

# Build and install Dante
ADD https://www.inet.no/dante/files/dante-1.4.2.tar.gz /tmp/
RUN tar xzf /tmp/dante-1.4.2.tar.gz -C /tmp/
RUN (cd /tmp/dante-1.4.2 && ac_cv_func_sched_setscheduler=no ./configure)
RUN make -C /tmp/dante-1.4.2 install
RUN rm -rf /tmp/dante-1.4.2
RUN apk del --purge .build-deps

RUN apk add --no-cache dumb-init

RUN echo "${SOCKET_USER}:${SOCKET_PASSWORD}" | chpasswd

EXPOSE 1080

ADD ./sockd.conf /etc/sockd.conf
RUN chmod +rw /etc/sockd.conf

ENTRYPOINT ["dumb-init"]
CMD ["sockd"]

