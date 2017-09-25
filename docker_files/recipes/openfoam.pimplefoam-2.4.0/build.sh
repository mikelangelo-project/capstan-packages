#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

cd ${OSV_BUILD_DIR}
echo "/usr/bin/pimpleFoam.so: ${OSV_DIR}/mike-apps/OpenFOAM/ROOTFS/usr/bin/pimpleFoam.so" > usr.manifest

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${COMMON_DIR}/openfoam_remove_ompi.patch
${OSV_DIR}/scripts/build image=OpenFOAM export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenFOAM pimpleFoam" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.2 \
    --require openfoam.core-2.4.0 \
    --platform ${PLATFORM}
