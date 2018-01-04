#!/usr/bin/env bash
#
# Copyright (C) 2017 XLAB, Ltd.
#
# This work is open source software, licensed under the terms of the
# BSD license as described in the LICENSE file in the top-level directory.
#

#
# This script is meant to be run by CRON to periodically rebuild all packages
# from scratch on the latest OSv master. The build will take two hours or so,
# therefore don't run it too often.
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Pull latest code"
git fetch upstream
git checkout upstream/master

echo "Remove old images and containers"
docker rm mikelangelo/capstan-packages --force || true # forcibly stop old container if it's still running for some reason
docker system prune -a --force # remove all unused images and containers

echo "Build container from scratch"
docker build -t mikelangelo/capstan-packages . --no-cache

echo "Prepare results directory"
mkdir -p result

#
# In the section below we manually set container's CMD in order to avoid waiting forever
# when the container is done working.
#
echo "Run all recipes and then exit"
docker run -i --privileged --volume="$PWD/result:/result" --env SILENT=yes mikelangelo/capstan-packages python /capstan-packages.py

echo "Done"

