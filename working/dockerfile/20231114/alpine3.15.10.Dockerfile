FROM scratch
ADD alpine-minirootfs-3.15.10-x86_64.tar.gz /
CMD ["/bin/sh"]
