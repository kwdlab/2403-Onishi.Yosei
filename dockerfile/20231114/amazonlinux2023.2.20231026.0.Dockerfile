FROM alpine:3.17 AS verify
RUN apk add --no-cache curl tar xz

RUN ROOTFS=$(curl -sfOJL -w "al2023-container-2023.2.20231026.0-x86_64.tar.xz" "https://amazon-linux-docker-sources.s3.amazonaws.com/al2023/2023.2.20231026.0/al2023-container-2023.2.20231026.0-x86_64.tar.xz") \
  && echo 'a29d58a4201229eeb11f66597985afd5e48f1d66b8c111174d0ce136a47a1a25  al2023-container-2023.2.20231026.0-x86_64.tar.xz' >> /tmp/al2023-container-2023.2.20231026.0-x86_64.tar.xz.sha256 \
  && cat /tmp/al2023-container-2023.2.20231026.0-x86_64.tar.xz.sha256 \
  && sha256sum -c /tmp/al2023-container-2023.2.20231026.0-x86_64.tar.xz.sha256 \
  && mkdir /rootfs \
  && tar -C /rootfs --extract --file "${ROOTFS}"

FROM scratch AS root
COPY --from=verify /rootfs/ /

CMD ["/bin/bash"]
