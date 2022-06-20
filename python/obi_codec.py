#!/usr/bin/env python3

import sys
import argparse
import ast

from pyband.obi import PyObi

SCHEMA = """
{
    flight: string,
    iso_date: string
} / {
    status: string,
    arrival_airport: string,
    scheduled_time_utc: string,
    actual_time_utc: string
}
"""

def parseArgs():
    parser = argparse.ArgumentParser(description="OBI encoder/decoder",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("data", nargs="?", help="Data to process. E.g. OBI hex '000000034254430000000000002328010200', OBI string '{\"symbols\": \"ETH\", \"multiplier\": 100}'. Can be string or stdin")
    parser.add_argument("-a", "--action", type=str, choices=["e", "d"], default="e", help="action to take on the data, (e)ncode or (d)ecode. Default: e")
    parser.add_argument("-s", "--schema", type=str, choices=["i", "o"], default="i", help="schema to use, (i)nput or (o)utput. Default: i")
    args = parser.parse_args()
    return args

def processData(args):
    obi = PyObi(SCHEMA)
    # convert string representation to a Python dict
    if args.data is None:
        args.data = sys.stdin.read()

    result = ''
    # processing logic
    if args.action == "e":
        data_dict = ast.literal_eval(args.data)
        if args.schema == "i":
            result = obi.encode_input(data_dict).hex()
        else:
            result = obi.encode_output(data_dict).hex()
    else:
        if args.schema == "i":
            result = obi.decode_input(bytearray.fromhex(args.data))
        else:
            result = obi.decode_output(bytearray.fromhex(args.data))
    return result

def main():
    args = parseArgs()
    return processData(args)

if __name__ == "__main__":
    try:
        print(main(), end="")
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)