FROM ghcr.io/openfaas/of-watchdog:0.9.11 as watchdog

FROM alpine:3.17.3 as build

ARG ADDITIONAL_PACKAGE=""

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

RUN addgroup -S app && adduser app -S -G app

RUN apk add --no-cache ${ADDITIONAL_PACKAGE}

WORKDIR /root/

RUN mkdir -p /home/app

# Wrapper/boot-strapper
WORKDIR /home/app
COPY index.sh ./

WORKDIR /home/app/function
COPY function/*.sh ./

# Copy in additional function files and folders
COPY --chown=app:app function/ .

WORKDIR /home/app/

# chmod for tmp is for a buildkit issue (@alexellis)
RUN chmod +rx -R ./function \
    && chown app:app -R /home/app \
    && chmod 777 /tmp

USER app

ENV mode="streaming"

ENV fprocess="sh ./index.sh"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
