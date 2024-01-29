# This Dockerfile should be used for docker official repo

# https://github.com/docker-library/official-images:
# No official images can be derived from, or depend on, non-official images
# with the following notable exceptions...
FROM oraclelinux:8

LABEL org.opencontainers.image.authors="info@percona.com"

# It is intentionally used another UID, to have backward compatibility with
# the previous image versions published on Docker Hub
RUN set -ex; \
    groupdel ssh_keys; \
    userdel systemd-coredump; \
    groupadd -g 999 mysql; \
    useradd -u 999 -r -g 999 -s /sbin/nologin \
        -c "Default Application User" mysql

# check repository package signature in secure way
RUN set -ex; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A 99DB70FAE1D7CE227FB6488205B555B38483C65D; \
    gpg --batch --export --armor 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A > ${GNUPGHOME}/RPM-GPG-KEY-Percona; \
    gpg --batch --export --armor 99DB70FAE1D7CE227FB6488205B555B38483C65D > ${GNUPGHOME}/RPM-GPG-KEY-centosofficial; \
    rpmkeys --import ${GNUPGHOME}/RPM-GPG-KEY-Percona ${GNUPGHOME}/RPM-GPG-KEY-centosofficial; \
    curl -Lf -o /tmp/percona-release.rpm https://repo.percona.com/yum/percona-release-latest.noarch.rpm; \
    rpmkeys --checksig /tmp/percona-release.rpm; \
    rpm -i /tmp/percona-release.rpm; \
    rm -rf "$GNUPGHOME" /tmp/percona-release.rpm; \
    rpm --import /etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY; \
    dnf -y module disable mysql

ENV PS_VERSION 5.7.43-47.1
ENV OS_VER el8
ENV FULL_PERCONA_VERSION "$PS_VERSION.$OS_VER"

RUN set -ex; \
    rpm -e --nodeps tzdata; \
    dnf config-manager --enable ol8_u4_security_validation; \
    dnf -y install \
        tzdata \
        jemalloc \
        which \
        cracklib-dicts \
        policycoreutils; \
    \
    dnf -y install \
        Percona-Server-server-57-${FULL_PERCONA_VERSION} \
        Percona-Server-devel-57-${FULL_PERCONA_VERSION} \
        Percona-Server-tokudb-57-${FULL_PERCONA_VERSION} \
        Percona-Server-rocksdb-57-${FULL_PERCONA_VERSION}; \
    dnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/mysql

# purge and re-create /var/lib/mysql with appropriate ownership
RUN set -ex; \
    /usr/bin/install -m 0775 -o mysql -g root -d /var/lib/mysql /var/run/mysqld /docker-entrypoint-initdb.d; \
# comment out a few problematic configuration values
	find /etc/percona-server.cnf /etc/percona-server.conf.d /etc/my.cnf.d -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log|user)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log|user)/#&/'; \
# don't reverse lookup hostnames, they are usually another container
	printf '[mysqld]\nskip-host-cache\nskip-name-resolve\n' > /etc/my.cnf.d/docker.cnf; \
# TokuDB modifications
	/usr/bin/install -m 0664 -o mysql -g root /dev/null /etc/sysconfig/mysql; \
	echo "LD_PRELOAD=/usr/lib64/libjemalloc.so.1" >> /etc/sysconfig/mysql; \
	echo "THP_SETTING=never" >> /etc/sysconfig/mysql; \
# keep backward compatibility with debian images
	ln -s /etc/my.cnf.d /etc/mysql; \
# allow to change config files
	chown -R mysql:root /etc/percona-server.cnf /etc/percona-server.conf.d /etc/my.cnf.d; \
	chmod -R ug+rwX /etc/percona-server.cnf /etc/percona-server.conf.d /etc/my.cnf.d

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

COPY ps-entry.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER mysql
EXPOSE 3306
CMD ["mysqld"]
