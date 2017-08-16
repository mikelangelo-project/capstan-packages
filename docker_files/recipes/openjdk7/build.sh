#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting OpenJDK 7"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=java export=all usrskel=none -j ${CPU_COUNT}
cp -R ${OSV_DIR}/build/export/. ${PACKAGE_RESULT_DIR}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenJDK 1.7.0" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

echo "Done"
