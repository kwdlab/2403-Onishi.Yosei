FROM scratch

ADD oraclelinux-7-amd64-rootfs.tar.xz /

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
