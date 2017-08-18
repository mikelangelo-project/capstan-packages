#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Clear usr.manifest.skel that is already contained in bootstrap package
echo "[manifest]" > ${OSV_DIR}/usr.manifest.skel

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${RECIPE_DIR}/openfoam-core.patch
patch -p1 < ${COMMON_DIR}/openfoam_remove_ompi.patch

${OSV_DIR}/scripts/build image=OpenFOAM -j ${CPU_COUNT}

cd ${OSV_BUILD_DIR}
${OSV_DIR}/scripts/upload_manifest.py -m usr.manifest -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

# Add decompose and reconstruct that are in the same directory as (ignored) solvers
cp ${OSV_DIR}/mike-apps/OpenFOAM/ROOTFS/usr/bin/decomposePar.so ${PACKAGE_RESULT_DIR}/usr/bin
cp ${OSV_DIR}/mike-apps/OpenFOAM/ROOTFS/usr/bin/reconstructPar.so ${PACKAGE_RESULT_DIR}/usr/bin

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenFOAM Core" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.2 \
    --require ompi-1.10 \
    --platform ${PLATFORM}
