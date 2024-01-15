FROM alpine:3.17 AS verify
RUN apk add --no-cache curl tar xz

RUN ROOTFS=$(curl -sfOJL -w "amzn-container-minimal-2018.03.0.20231024.0-x86_64.tar.xz" "https://amazon-linux-docker-sources.s3.amazonaws.com/amzn/2018.03.0.20231024.0/amzn-container-minimal-2018.03.0.20231024.0-x86_64.tar.xz") \
  && echo '0c010fa3f28499543ef0a0cf18081a5692ba2357ec778b005cbe269081dfd374  amzn-container-minimal-2018.03.0.20231024.0-x86_64.tar.xz' >> /tmp/amzn-container-minimal-2018.03.0.20231024.0-x86_64.tar.xz.sha256 \
  && cat /tmp/amzn-container-minimal-2018.03.0.20231024.0-x86_64.tar.xz.sha256 \
  && sha256sum -c /tmp/amzn-container-minimal-2018.03.0.20231024.0-x86_64.tar.xz.sha256 \
  && mkdir /rootfs \
  && tar -C /rootfs --extract --file "${ROOTFS}"

FROM scratch AS root
COPY --from=verify /rootfs/ /

CMD ["/bin/bash"]
