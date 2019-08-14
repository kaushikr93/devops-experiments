ARG version=latest

LABEL maintainer "kaushikr93@gmail.com"

FROM ubuntu:$version

RUN apt-get update && apt-get install my-sql -y && apt-get install httpd -y && apt-get install php -y

ENV home /root

WORKDIR /root

CMD ["/bin/bash" , "/bash"]

EXPOSE 8085
