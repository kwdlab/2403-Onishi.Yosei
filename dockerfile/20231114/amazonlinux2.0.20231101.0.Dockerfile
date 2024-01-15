FROM alpine:3.17 AS verify
RUN apk add --no-cache curl tar xz

RUN ROOTFS=$(curl -sfOJL -w "amzn2-container-raw-2.0.20231101.0-x86_64.tar.xz" "https://amazon-linux-docker-sources.s3.amazonaws.com/amzn2/2.0.20231101.0/amzn2-container-raw-2.0.20231101.0-x86_64.tar.xz") \
  && echo 'bce1ac8bd0ae98b5628335070e24bceefb329ce9db919047f0f687274b33d4cf  amzn2-container-raw-2.0.20231101.0-x86_64.tar.xz' >> /tmp/amzn2-container-raw-2.0.20231101.0-x86_64.tar.xz.sha256 \
  && cat /tmp/amzn2-container-raw-2.0.20231101.0-x86_64.tar.xz.sha256 \
  && sha256sum -c /tmp/amzn2-container-raw-2.0.20231101.0-x86_64.tar.xz.sha256 \
  && mkdir /rootfs \
  && tar -C /rootfs --extract --file "${ROOTFS}"

FROM scratch AS root
COPY --from=verify /rootfs/ /

CMD ["/bin/bash"]
