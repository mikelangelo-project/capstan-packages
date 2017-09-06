#!/usr/bin/env bash

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

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv Bootstrap" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

echo "Done"