[![Build Status](https://ci.matthewbrown.io/api/badges/mnbbrown/ci/status.svg)](https://ci.matthewbrown.io/mnbbrown/ci)

*ci* is used by ci.matthewbrown.io to build, test, publish and deploy applications written in google go. Can be used by including the below snippet in your `.drone.yml` file. 

```yaml
build:
    image: mnbbrown/ci:latest
    commands:
        - go get -t -v ./...
        - CGO_ENABLED=0 GOOS=linux go build -ldflags $(LD_FLAGS) -a -installsuffix cgo
```
