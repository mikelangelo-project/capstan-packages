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

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "compose-remote util for preparing base image" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}
