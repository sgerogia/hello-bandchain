package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
)

const URL = "https://aerodatabox.p.rapidapi.com/flights/number/%s/%s"

var headers = map[string]string{
	"User-Agent":      "curl/7.64.1",
	"Content-Type":    "application/json",
	"X-RapidAPI-Host": "aerodatabox.p.rapidapi.com",
	// Replace your own private API key below
	"X-RapidAPI-Key": "XXX",
}

// subset auto-generated from https://mholt.github.io/json-to-go/
type Airport struct {
	Iata string `json:"iata"`
}

type Arrival struct {
	Airport          Airport `json:"airport"`
	ScheduledTimeUtc string  `json:"scheduledTimeUtc"`
	ActualTimeUtc    string  `json:"actualTimeUtc,omitempty"`
}

type Flight struct {
	Arrival Arrival `json:"arrival"`
	Status  string  `json:"status"`
}

type ApiResult []Flight

// Results are comma-sparated values (no spaces)
// Flight Status, Arrival airport, Scheduled Time UTC, Actual Time UTC
func main() {

	if (len(os.Args) < 3) {
		log.Fatal("Not enough arguments: ", len(os.Args))
	}

	flight := os.Args[1]
	date := os.Args[2]

	url := fmt.Sprintf(URL, flight, date)

	req, err := http.NewRequest("GET", url, nil)
	for k, v := range headers {
		req.Header.Add(k, v)
	}
	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil {
		log.Fatal("Error on API request.\n", err)
	}
	defer resp.Body.Close()

	res := ApiResult{}
	err = parse(resp.Body, &res)

	if err != nil {
		log.Fatal("Error parsing response\n", err)
	}

	fmt.Print(
		strings.Join(
			[]string{
				res[0].Status,
				res[0].Arrival.Airport.Iata,
				res[0].Arrival.ScheduledTimeUtc,
				res[0].Arrival.ActualTimeUtc,
			}, ","))
}

func parse(j io.Reader, f *ApiResult) error {
	err := json.NewDecoder(j).Decode(f)
	return err
}
