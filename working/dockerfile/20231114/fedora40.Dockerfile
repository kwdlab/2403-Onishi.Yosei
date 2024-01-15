FROM scratch
LABEL maintainer="Clement Verna <cverna@fedoraproject.org>"                    
ENV DISTTAG=f40container FGC=f40 FBR=f40
ADD fedora-40-x86_64.tar.xz / 
CMD ["/bin/bash"]