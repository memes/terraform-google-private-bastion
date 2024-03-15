# Run tinyproxy in forward only mode
FROM alpine:3.19.1
LABEL maintainer="Matthew Emes <memes@matthewemes.com>"

RUN apk --no-cache add tinyproxy=1.11.1-r3 ca-certificates-bundle=20230506-r0
EXPOSE 8888
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
USER nobody
ENTRYPOINT ["/usr/bin/tinyproxy", "-d"]
CMD []
