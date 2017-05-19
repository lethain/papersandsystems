FROM ubuntu:zesty

RUN apt-get update
RUN apt-get install curl
RUN apt-get install ruby-full
RUN apt-get install libmysqlclient-dev


RUN touch /var/log/papers/log
ENTRYPOINT tail -f /var/log/papers/log

# ENTRYPOINT cron && nginx -g "daemon off;"
# EXPOSE 80