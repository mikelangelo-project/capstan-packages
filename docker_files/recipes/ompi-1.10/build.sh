#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting Open MPI"

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=open-mpi export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "Open MPI" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --require osv.httpserver \
    --platform ${PLATFORM}
