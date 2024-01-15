FROM scratch
ADD alpine-minirootfs-20230901-x86_64.tar.gz /
CMD ["/bin/sh"]
