#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting cloud-init"

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${RECIPE_DIR}/cloud-init.patch
${OSV_DIR}/scripts/build image=cloud-init export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "cloud-init" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --require osv.httpserver \
    --platform ${PLATFORM}
