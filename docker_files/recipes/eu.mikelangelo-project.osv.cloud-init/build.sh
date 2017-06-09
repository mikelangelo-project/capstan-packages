#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Clear usr.manifest.skel that is already contained in bootstrap package
echo "[manifest]" > ${OSV_DIR}/usr.manifest.skel

###############################################################################
# Build the cloud-init package.
###############################################################################

echo "Exporting cloud-init"

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${RECIPE_DIR}/cloud-init.patch
${OSV_DIR}/scripts/build image=cloud-init

cd ${OSV_BUILD_DIR}
${OSV_DIR}/scripts/upload_manifest.py -m usr.manifest -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "cloud-init" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --require eu.mikelangelo-project.osv.httpserver
