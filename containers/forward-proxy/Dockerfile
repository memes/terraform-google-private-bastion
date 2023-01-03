# Run tinyproxy in forward only mode
FROM alpine:3.17.0
LABEL maintainer="Matthew Emes <memes@matthewemes.com>"

RUN apk --no-cache add tinyproxy=1.11.1-r2 ca-certificates=20220614-r3
EXPOSE 8888
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
USER nobody
ENTRYPOINT ["/usr/bin/tinyproxy", "-d"]
CMD []
