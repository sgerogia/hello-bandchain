#!/bin/bash

# Replace with your Cloud function URL (Google or Amazon)
BASE_URL="https://xyz.cloudfunctions.net/my_function_name/execute"

BINARY_BASE64="/tmp/program.base64"
PAYLOAD_BASE64="/tmp/payload.base64"


usage()
{
    echo -e "Call the remote function endpoint, using the given program and arguments\n"
    echo -e "Usage: \n  $0 [command]\n"
    echo -e "Available Commands:"
    echo -e "  hello \t Print back the argument passed"
    echo -e "  ds \t\t Call DataAeroBox API using the argument passed"
    echo -e "\nFlags:"
    echo -e "  -a, --arg \t Argument for the remotely executing program (e.g. -a \"'ARG1' 'ARG2'\")"
    echo -e "  -t,  --type \t Type of executor to use [p(ython), g(olang)] (default: p)"
    echo -e "  -h,  --help \t Show this menu\n"
    exit 1
}

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

call_api()
{
    echo -e "${green}Info:${reset} Calling remote function endpoint."

    curl --location --request POST $BASE_URL \
    --header 'Content-Type: application/json' \
    --data-binary '@/tmp/payload.base64'
}

create_payload()
{
  TYPE=$1
  PROGRAM=$2
  ARGUMENT=$3

  echo -e "${green}Info:${reset} Creating payload [Type: $TYPE, Program: $PROGRAM, Arg: $ARGUMENT]\n"

  if [ "$TYPE" = "p" ]
  then
    cat "./python/$PROGRAM.py" | base64 | tr -d '\n' > "$BINARY_BASE64"
  else
    cat "./bin/$PROGRAM-amd64-linux" | base64 | tr -d '\n' > "$BINARY_BASE64"
  fi

  cat <<EOT > "$PAYLOAD_BASE64"
  {
      "executable":
EOT

  echo -n '"' >> "$PAYLOAD_BASE64"

  cat "$BINARY_BASE64" >> "$PAYLOAD_BASE64"

  echo -n '"' >> "$PAYLOAD_BASE64"

  cat <<EOT >> "$PAYLOAD_BASE64"
  ,
    "calldata": "$ARGUMENT",
    "timeout": 3000
  }
EOT
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--arg)
    ARG="$2"
    shift
    shift
    ;;
    -t|--type)
    TYPE="$2"
    shift
    ;;
    -h|--help)
    usage
    shift
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

COMMAND=${POSITIONAL[0]}

if [ "$COMMAND" = "" ]
then
    usage
fi

if [ "$TYPE" = "" ]
then
    TYPE="p"
fi

if [[ ! "$TYPE" =~ ^(p|g)$ ]]
then
    usage
fi

if [[ ! "$COMMAND" =~ ^(hello|ds)$ ]]
then
    echo -e "${red}Error:${reset} Program not recognised\n"
    usage
fi

create_payload "$TYPE" "$COMMAND" "$ARG"

call_api






