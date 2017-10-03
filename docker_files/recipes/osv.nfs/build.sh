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

###############################################################################
# Build the NFS tools package
###############################################################################

echo "Exporting NFS tools"

cd ${OSV_DIR}
patch -p1 -i ${RECIPE_DIR}/nfs.patch

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=empty export=all export_dir=$PACKAGE_RESULT_DIR

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv NFS Client Tools" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.2 \
    --platform ${PLATFORM}

echo "Done"
