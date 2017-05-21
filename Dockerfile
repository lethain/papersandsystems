FROM ubuntu:zesty

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install ruby-full -y
RUN apt-get install libmysqlclient-dev -y
RUN apt-get install mysql-client -y
RUN gem install bundler

RUN mkdir /var/papers/
COPY . /var/papers/

WORKDIR /var/papers/
RUN bundle install

#ENTRYPOINT bundler exec unicorn -c unicorn.rb
ENTRYPOINT tail -f unicorn.rb

# ENTRYPOINT cron && nginx -g "daemon off;"
# EXPOSE 80