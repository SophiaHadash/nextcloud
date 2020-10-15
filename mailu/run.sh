#!/bin/bash

# configure application prior to build
if test -f "mailu.env"; then
  export $(cat mailu.env | xargs)
fi

# test availability of environment variables
if [ -z "$BIND_ADDRESS" ]; then echo "Environment variable BIND_ADDRESS is unset or empty." && exit 1; fi
if [ -z "$VERSION" ]; then echo "Environment variable VERSION is unset or empty." && exit 1; fi
if [ -z "$ROOT" ]; then echo "Environment variable ROOT is unset or empty." && exit 1; fi
if [ -z "$SUBNET" ]; then echo "Environment variable SUBNET is unset or empty." && exit 1; fi

# deploy
docker-compose --env-file ./mailu.env -f docker-compose.yml -p letsencrypt up -d