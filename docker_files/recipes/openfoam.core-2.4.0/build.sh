#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${RECIPE_DIR}/openfoam-core.patch
patch -p1 < ${COMMON_DIR}/openfoam_remove_ompi.patch

${OSV_DIR}/scripts/build image=OpenFOAM export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

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
