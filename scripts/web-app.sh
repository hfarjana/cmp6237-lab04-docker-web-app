#!/usr/bin/env bash
set -euo pipefail

# Move to the project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Build the Docker image
docker build -t cmp6237-lab04:course .

# Remove an existing container with the same name
old=$(docker ps -aq --filter name=^/cmp6237-lab04$)

if [ -n "$old" ]; then
    docker rm -f "$old"
fi

# Run the application container
docker run -d --name cmp6237-lab04 \
    -p 5000:5000 \
    cmp6237-lab04:course

# Display the running container
docker ps --filter name=^/cmp6237-lab04$
