#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Clear usr.manifest.skel that is already contained in bootstrap package
mv ${OSV_DIR}/usr.manifest.skel{,.tmp}
echo "[manifest]" > ${OSV_DIR}/usr.manifest.skel

###############################################################################
# Build the HTTP server package.
###############################################################################
echo "Exporting HTTP server"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=httpserver -j ${CPU_COUNT}

cd ${OSV_BUILD_DIR}
${OSV_DIR}/scripts/upload_manifest.py -m ${OSV_BUILD_DIR}/usr.manifest -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv HTTP REST Server" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1

echo "Done"
