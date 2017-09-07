#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting OpenJDK 8 Zulu Compact1"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=openjdk8-zulu-compact1 export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

# Fix "java" empty folder problem
rmdir ${PACKAGE_RESULT_DIR}/usr/lib/jvm/java
mv ${PACKAGE_RESULT_DIR}/usr/lib/jvm/j2re-compact1-image ${PACKAGE_RESULT_DIR}/usr/lib/jvm/java

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenJDK 1.8.0_112" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

echo "Done"
