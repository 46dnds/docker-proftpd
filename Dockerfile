FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y proftpd

ADD launch /launch.sh
RUN chmod a+x /launch.sh

EXPOSE 21
EXPOSE 20
# couple available volumes you may want to use
RUN mkdir /ftpdata
VOLUME ["/ftpdata"]

ENTRYPOINT /launch
