#!/usr/bin/env bash

export IMAGE=$1
docker compose up -d
echo "compose applied"
