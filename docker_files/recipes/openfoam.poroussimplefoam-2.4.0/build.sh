#!/usr/bin/env bash
#
# Copyright (C) 2017 XLAB, Ltd.
#
# This work is open source software, licensed under the terms of the
# BSD license as described in the LICENSE file in the top-level directory.
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

cd ${OSV_BUILD_DIR}
echo "/usr/bin/porousSimpleFoam.so: ${OSV_DIR}/mike-apps/OpenFOAM/ROOTFS/usr/bin/porousSimpleFoam.so" > usr.manifest

# Patch the module file to exclude the dependency on HTTP server
cd ${OSV_DIR}
patch -p1 < ${COMMON_DIR}/openfoam_core.patch
patch -p1 < ${COMMON_DIR}/openfoam_remove_ompi.patch
${OSV_DIR}/scripts/build image=OpenFOAM export=none usrskel=none -j ${CPU_COUNT}

# Add porousSimpleFoam solver
mkdir -p ${PACKAGE_RESULT_DIR}/usr/bin
cp ${OSV_DIR}/mike-apps/OpenFOAM/ROOTFS/usr/bin/porousSimpleFoam.so ${PACKAGE_RESULT_DIR}/usr/bin

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OpenFOAM porousSimpleFoam" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.3 \
    --require openfoam.core-2.4.0 \
    --platform ${PLATFORM}
