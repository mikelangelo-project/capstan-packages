#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting HTTP server"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=httpserver export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv HTTP REST Server" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

echo "Done"
