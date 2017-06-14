#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Clear usr.manifest.skel that is already contained in bootstrap package
echo "[manifest]" > ${OSV_DIR}/usr.manifest.skel

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${COMMON_DIR}/openfoam_remove_ompi.patch

${OSV_DIR}/scripts/build image=OpenFOAM

cd ${OSV_BUILD_DIR}
echo "/usr/bin/simpleFoam.so: ${OSV_DIR}/mike-apps/OpenFOAM/ROOTFS/usr/bin/simpleFoam.so" > usr.manifest
${OSV_DIR}/scripts/upload_manifest.py -m usr.manifest -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenFOAM simpleFoam" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 2.4.0 \
    --require openfoam.core
