Hello world project for Band Chain
---

# Introduction
Contains all the Data Source and Oracle source code for my Band Chain [blog post]().

# Prerequisites 
* Golang 1.17+
* Python 3
* Make
* Requires the creation of a cloud function based on the [data-source-runtime](https://github.com/sgerogia/bandchain-data-source-runtime).

# Usage

## Update API key & Cloud function
* Go to [AeroDataBox](https://rapidapi.com/aedbx-aedbx/api/aerodatabox/) and get yourself a free API key. 
* Add this key to the 2 Data Sources: [ds.go](./ds/ds.go) and [ds.py](./python/ds.py)
* Update [call_executor.sh](./call_executor.sh) with your cloud function URL.

## Test & Build Go code
* `go test -v ./ds/...`
* `make all`

## E2E testing 
* Invoke `call_executor.sh` with no arguments for help.
* Example invocation for flight data, using the Go binary  
`./call_executor.sh ds -t g -a "'EK29' '2022-06-08'"`
* Example invocation of the Python 'Hello World'  
  `./call_executor.sh hello -t p -a "'Hello world'"`