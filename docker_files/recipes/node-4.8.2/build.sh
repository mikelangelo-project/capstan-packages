#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

NODE_VERSION=4.8.2
echo "Exporting Node ${NODE_VERSION}"

cd ${OSV_DIR}/apps/node
./GET ${NODE_VERSION}
make NODE_VERSION=${NODE_VERSION} -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
mkdir ./bin
cp ${OSV_DIR}/apps/node/libnode-${NODE_VERSION}.so ./bin/
ln -s /bin/libnode-${NODE_VERSION}.so node

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "NodeJS ${NODE_VERSION}" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

echo "Done"
