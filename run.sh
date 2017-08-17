#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Pull latest code"
git fetch upstream
git checkout upstream/master

echo "Build container from scratch"
docker build -t mikelangelo/capstan-packages . --no-cache

echo "Prepare results directory"
mkdir -p result

#
# In the section below we manually set container's CMD in order to avoid waiting forever
# when the container is done working.
#
echo "Run all recipes and then exit"
docker run -it --privileged --volume="$PWD/result:/result" --env SILENT=yes mikelangelo/capstan-packages python /capstan-packages.py

echo "Done"

