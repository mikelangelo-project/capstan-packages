#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Clear usr.manifest.skel that is already contained in bootstrap package
echo "[manifest]" > ${OSV_DIR}/usr.manifest.skel

###############################################################################
# Build the CLI package.
###############################################################################

echo "Exporting CLI"

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${RECIPE_DIR}/cli.patch
${OSV_DIR}/scripts/build image=cli -j ${CPU_COUNT}

cd ${OSV_BUILD_DIR}
${OSV_DIR}/scripts/upload_manifest.py -m usr.manifest -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv Command Line Interface" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --require osv.httpserver
