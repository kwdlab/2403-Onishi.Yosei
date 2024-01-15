FROM scratch
ADD alpine-minirootfs-3.18.4-x86_64.tar.gz /
CMD ["/bin/sh"]
