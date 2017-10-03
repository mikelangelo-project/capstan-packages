#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting HTTP server (frontend)"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=httpserver-html5-gui export=selected usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

# Fix bug that both httpserver-api and httpserver-html5-gui provide a file in /init
# which then results in "httpserver failed: bind: Address in use"
rm -f ${PACKAGE_RESULT_DIR}/init -R

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv HTTP REST Server (web frontend)" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --require osv.httpserver-api \
    --platform ${PLATFORM}

echo "Done"
