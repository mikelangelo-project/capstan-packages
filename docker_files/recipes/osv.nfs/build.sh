#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

###############################################################################
# Build the NFS tools package
###############################################################################

echo "Exporting NFS tools"

cd ${OSV_DIR}
patch -p1 -i ${RECIPE_DIR}/nfs.patch

cd ${OSV_BUILD_DIR}
${OSV_DIR}/scripts/upload_manifest.py -m ${OSV_DIR}/usr.manifest.skel -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv NFS Client Tools" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1    

echo "Done"
