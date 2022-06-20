Hello world project for Band Chain
---

# Introduction
Contains all the Data Source and Oracle source code for my Band Chain [blog post]().

# Prerequisites 
* Golang 1.17+
* Python 3
* Rust
* Make
* Requires the creation of a cloud function using the [data-source-runtime](https://github.com/sgerogia/bandchain-data-source-runtime).

# Development

## Update URLs and identifiers
* Go to [AeroDataBox](https://rapidapi.com/aedbx-aedbx/api/aerodatabox/) and get yourself a free API key. 
* Add this key to the 2 Data Sources: [ds.go](./ds/ds.go) and [ds.py](./python/ds.py)
* Update [call_executor.sh](./call_executor.sh) with your cloud function URL.
* (After deploying the Data Sources) Update the [Oracle script](./oracle/src/lib.rs) with the unique data source ids.

## Build 
`make all`

## Test Go code logic
`go test -v ./ds/...` 

## E2E Data Source testing 
* Invoke `call_executor.sh` with no arguments for help.
* Example invocation for flight data, using the Go binary  
`./call_executor.sh ds -t g -a "'EK29' '2022-06-08'"`
* Example invocation of 'Hello World', using Python  
  `./call_executor.sh hello -t p -a "'Hello world'"`

# Deployment

Examples provided for a local chain deployment, using the default generated values from genesis.

## Data Source
```
bandd tx oracle create-data-source \
    --name "AeroDataBox Data Source" \              # name of the created data source
    --fee 50000uband \                              # fee charged when using this data source
    --description "AeroDataBox using Python" \      # description of the data source
    --script ./python/ds.py \                       # path to the data source script
    --from requester \                              # sender account
    --owner band1p40yh3zkmhcv0ecqp3mcazy83sa57rgjp07dun \     # data source owner address (replace)
    --treasury band1p40yh3zkmhcv0ecqp3mcazy83sa57rgjp07dun \  # address to collect the fee (replace)
    --node http://localhost:26657 \                           # rpc node
    --chain-id bandchain \                                    # chain id (see genesis.json)
    --gas auto \                                              # transaction gas
    --keyring-backend test                                    # specify keyring (test,os,...)
```

## Oracle
```
bandd tx oracle create-oracle-script \
    --schema "{flight:string,date:string}/{status:string,arrival_airport:string,scheduled_time_utc:string,actual_time_utc:string}" \  # schema of the input/output
    --name "Flight Arrival Status" \                      # name of the created oracle script
    --description "This Oracle queries multiple flight status data sources to give the status of a flight on a given date." \         # description of the oracle script
    --script "./oracle/target/wasm32-unknown-unknown/release/flight_arrivals.wasm" \                                                  # path to the oracle script script
    --from requester \                                    # sender account (replace)
    --owner band1p40yh3zkmhcv0ecqp3mcazy83sa57rgjp07dun \ # oracle script owner address (replace)
    --node http://localhost:26657 \                       # rpc node
    --chain-id bandchain \                                # chain id
    --gas auto \                                          # transaction gas
    --keyring-backend os                                  # specify keyring (test,os,...)
```