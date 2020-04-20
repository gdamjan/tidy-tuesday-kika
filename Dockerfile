FROM ubuntu:20.04
# Makes a Docker image based on ubuntu:20.04
# and installs ubuntu packages from ubuntu-packages.list
# and R dependencies from DESCRIPTION
#
# To build manually:
#   docker build -t gdamjan/tidy-tuesday-kika:latest .

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /build

COPY ubuntu-packages.list ./
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends $(grep -vE "^\s*#" ./ubuntu-packages.list | xargs)

COPY Makefile DESCRIPTION ./
RUN make deps
