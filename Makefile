
.PHONY: all

all: clean build-hello build-ds build-oracle

clean:
	$(RM) -r bin
	$(RM) -r ./oracle/target

build-hello:
	@echo "Building 'Hello' for your native OS"
	go build -o ./bin/hello ./hello/hello.go

	@echo "Building 'Hello' for Linux AMD64"
	GOOS=linux GOARCH=amd64 go build -o ./bin/hello-amd64-linux ./hello/hello.go

build-ds:
	@echo "Building 'Data Source' for your native OS"
	go build -o ./bin/ds ./ds/ds.go

	@echo "Building 'Data Source' for Linux AMD64"
	GOOS=linux GOARCH=amd64 go build -o ./bin/ds-amd64-linux ./ds/ds.go

build-oracle:
	@echo "Building 'Flight Oracle'"
	RUSTFLAGS='-C link-arg=-s' cargo build --manifest-path ./oracle/Cargo.toml --release --target wasm32-unknown-unknown