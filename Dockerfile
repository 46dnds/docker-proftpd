FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y proftpd openssl

ADD launch.sh /launch.sh
RUN chmod a+x /launch.sh
RUN mkdir /etc/proftpd/ssl


EXPOSE 21
EXPOSE 20
# couple available volumes you may want to use
RUN mkdir /ftpdata
VOLUME ["/ftpdata"]

ENTRYPOINT /launch.sh
