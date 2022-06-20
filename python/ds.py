#!/usr/bin/env python3

import requests
import sys

URL = "https://aerodatabox.p.rapidapi.com/flights/number/{f}/{d}"
HEADERS = {
    'User-Agent': 'curl/7.64.1',
    'Content-Type': 'application/json',
    'X-RapidAPI-Host': 'aerodatabox.p.rapidapi.com',
    # Replace your own API key below
    'X-RapidAPI-Key': 'XXX'
}

# Results are comma-sparated values (no spaces)
# Flight Status, Arrival airport, Scheduled Time UTC, Actual Time UTC
def main(flight, date):
    try:
        flight = requests.get(
            URL.format(f=flight, d=date),
            headers=HEADERS
            ).json()

        results = []
        results.append(flight[0]['status'])
        arrival = flight[0]['arrival']
        results.append(arrival['airport']['iata'])
        results.append(arrival['scheduledTimeUtc'])
        if ('actualTimeUtc' in arrival):
            results.append(arrival['actualTimeUtc'])
        else:
            results.append('')
        return ','.join(results)
    except Exception as e:
        print(e)

if __name__ == "__main__":
    try:
        print(main(sys.argv[1], sys.argv[2]), end="")
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)