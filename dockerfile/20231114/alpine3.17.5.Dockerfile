FROM scratch
ADD alpine-minirootfs-3.17.5-x86_64.tar.gz /
CMD ["/bin/sh"]
