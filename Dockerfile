FROM debian:wheezy

RUN apt-get update
RUN apt-get install -y --no-install-recommends curl git subversion mercurial ca-certificates bzip2

ENV BUILD_DEPS autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
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
RUN curl https://get.docker.io/builds/Linux/x86_64/docker-latest -o /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker

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
RUN apt-get update && apt-get install -y --no-install-recommends git && apt-get -y --purge autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*
