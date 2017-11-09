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
# Build the bootstrap package
###############################################################################

echo "Exporting bootstrap"

cd ${OSV_DIR}
patch -p1 -i ${RECIPE_DIR}/bootstrap.patch

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=empty export=all export_dir=$PACKAGE_RESULT_DIR

# Include additional essential tools into the bootstrap package.
cd ${RECIPE_DIR}
git clone https://github.com/mikelangelo-project/osv-utils-xlab.git
cd ./osv-utils-xlab
make
mkdir ${PACKAGE_RESULT_DIR}/bin
cp ./*.so ${PACKAGE_RESULT_DIR}/bin/

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv Bootstrap" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.5 \
    --platform ${PLATFORM}

echo "Done"
