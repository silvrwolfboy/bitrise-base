FROM ubuntu:14.04

# Environments
# - Language
RUN locale-gen en_US.UTF-8
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
# - CI
ENV CI "true"
ENV BITRISE_IO "true"
# - main dirs
ENV BITRISE_SOURCE_DIR "/bitrise/src"
ENV BITRISE_BRIDGE_WORKDIR "/bitrise/src"
ENV BITRISE_DEPLOY_DIR "/bitrise/deploy"

# create base dirs
RUN mkdir -p /bitrise/src
RUN mkdir -p /bitrise/deploy

# prep dir
RUN mkdir -p /bitrise/prep
WORKDIR /bitrise/prep


RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git mercurial curl wget rsync ruby sudo

# install Ruby from source
#  from source: mainly because of GEM native extensions,
#  this is the most reliable way to use Ruby no Ubuntu if GEM native extensions are required
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev
RUN wget http://cache.ruby-lang.org/pub/ruby/ruby-2.2.3.tar.gz
RUN tar -xvzf ruby-2.2.3.tar.gz
RUN cd ruby-2.2.3 && ./configure --prefix=/usr/local && make && make install
# cleanup
RUN rm -rf ruby-2.2.3
RUN rm ruby-2.2.3.tar.gz

RUN gem install bundler --no-document

# install Go
#  from official binary package
RUN wget https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz -O go-bins.tar.gz
RUN tar -C /usr/local -xvzf go-bins.tar.gz
RUN rm go-bins.tar.gz
ENV PATH $PATH:/usr/local/go/bin

#
# Install Bitrise CLI
RUN curl -fL https://github.com/bitrise-io/bitrise/releases/download/1.2.3/bitrise-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise
RUN chmod +x /usr/local/bin/bitrise
RUN bitrise setup --minimal

WORKDIR $BITRISE_SOURCE_DIR

CMD ls -alh
