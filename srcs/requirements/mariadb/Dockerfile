FROM debian:bookworm

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y -o Acquire::Retries=3 --fix-missing mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

COPY conf/mariadb-server.cnf /etc/mysql/mariadb.conf.d/mariadb-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

CMD ["/usr/local/bin/entrypoint.sh"]