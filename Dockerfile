FROM ubuntu:zesty

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install ruby-full -y
RUN apt-get install libmysqlclient-dev -y

RUN mkdir /var/papers/
COPY . /var/papers/


ENTRYPOINT tail -f /var/papers/Dockerfile

# ENTRYPOINT cron && nginx -g "daemon off;"
# EXPOSE 80