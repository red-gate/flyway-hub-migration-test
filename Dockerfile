FROM alpine/httpie:2.6.0

RUN apk update && apk add jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
