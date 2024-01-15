FROM scratch
ADD alpine-minirootfs-3.16.7-x86_64.tar.gz /
CMD ["/bin/sh"]
