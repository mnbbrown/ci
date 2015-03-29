FROM debian:wheezy

RUN apt-get update
RUN apt-get install -y --no-install-recommends curl git subversion mercurial ca-certificates bzip2

ENV BUILD_DEPS autoconf bison build-essential libssl-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
RUN apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS && rm -rf /var/lib/apt/lists/*

# Install golang.
ENV GOLANG_VERSION 1.4.2
RUN curl -sSL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz | tar -v -C /usr/src -xz \
	&& cd /usr/src/go/src \
	&& ./make.bash --no-clean 2>&1
ENV PATH /usr/src/go/bin:$PATH
RUN mkdir -p /go
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN go get golang.org/x/tools/cmd/vet golang.org/x/tools/cmd/cover

# Install docker.
RUN apt-get update && apt-get install -y apparmor
RUN curl -s https://get.docker.io/ubuntu/ | sh  
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker
VOLUME /var/lib/docker

# Install libyaml for Ruby
RUN mkdir -p /usr/src/yaml && curl -sSL http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz | tar -vzxC /usr/src/yaml --strip-components=1 \
	&& cd /usr/src/yaml \
	&& ./configure \
	&& make
	&& make install
	&& rm -rf /usr/src/yaml

# Install ruby
ENV RUBY_VERSION 2.2.0
ENV RUBY_VERSION_MAJOR 2.2
RUN mkdir -p /usr/src/ruby
RUN curl -sSL http://cache.ruby-lang.org/pub/ruby/$RUBY_VERSION_MAJOR/ruby-$RUBY_VERSION.tar.bz2 | tar -xjC /usr/src/ruby --strip-components=1 \
	&& cd /usr/src/ruby \
	&& autoconf \
	&& ./configure --disable-install-doc \
	&& make -j"$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/ruby

# Install FPM
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN gem install fpm

# Cleanup
RUN apt-get remove -y --purge $BUILD_DEPS
RUN apt-get update && apt-get install --force-yes -y --no-install-recommends openssh-client git libffi-dev && apt-get -y --purge autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*
