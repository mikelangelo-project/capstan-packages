#!/usr/bin/env bash
#
# Copyright (C) 2017 XLAB, Ltd.
#
# This work is open source software, licensed under the terms of the
# BSD license as described in the LICENSE file in the top-level directory.
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting OpenJDK 8 Zulu Full"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=openjdk8-zulu-full export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenJDK 1.8.0 zulu-full" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

echo "Done"

