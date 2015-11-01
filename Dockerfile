FROM gliderlabs/alpine

RUN echo '@community http://dl-4.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk update && apk add bash curl git mercurial bzr go@community>=1.5 ca-certificates make jq && rm -rf /var/cache/apk/*

# Install golang.
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV GOBIN /go/bin
ENV PATH $GOBIN:$PATH
RUN go get -u golang.org/x/tools/cmd/vet golang.org/x/tools/cmd/cover github.com/jteeuwen/go-bindata/...
