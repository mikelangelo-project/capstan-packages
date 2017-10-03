#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting sample recipe 0.1"

echo
echo "These are my environment variables:"
echo "-----------------------------------"
printenv
echo "-----------------------------------"

cd ${RECIPE_DIR}
echo "I'm now in my RECIPE_DIR directory: ${RECIPE_DIR}"

cd ${PACKAGE_RESULT_DIR}
echo "I'm now in my PACKAGE_RESULT_DIR directory: ${PACKAGE_RESULT_DIR}"

cd ${OSV_DIR}
echo "I'm now in my OSV_DIR directory: ${OSV_DIR}"

echo "I'm about to pretend that I'm compiling some source"
echo "make -j ${CPU_COUNT}"

echo "I'm about to create hello-world.txt file and put it to the root of my package"
echo "Hello world" > ${PACKAGE_RESULT_DIR}/hello-world.txt

echo "I'm about to initialize my package"
cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "Sample package that does nothing" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --platform ${PLATFORM}

cat << "EOF"
Now that I've compiled whatever I wanted an put desired files into the PACKAGE_RESULT_DIR, my work is done.
I leave it to my caller (capstan-packages.py script) to finish the work. Namely, I trust it will:

1. copy my meta/README.md and meta/run.yaml into my PACKAGE_RESULT_DIR
2. invoke `chmod u+x` on my PACKAGE_RESULT_DIR
3. invoke `capstan package build` in my PACKAGE_RESULT_DIR
4. compose and run unikernel that I've defined in demo/pkg directory

EOF

echo "Done"
