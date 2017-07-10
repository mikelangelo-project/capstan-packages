#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting OSv Process Builder"

binaryDir=${RECIPE_DIR}/osv-process-builder-lib/src/main/java/org/mikelangelo/osvprocessbuilder

cd ${RECIPE_DIR}
git clone -b feature/pyspark_testing https://github.com/gasper-vrhovsek/osv-process-builder-lib.git

cd ${binaryDir}
make -j ${CPU_COUNT}
mvn install:install-file \
 -Dfile=osv-process-builder.jar \
 -DgroupId=org.mikelangelo.osv \
 -DartifactId=osvProcessBuilder \
 -Dversion=0.1 \
 -Dpackaging=jar \
 -T ${CPU_COUNT}

mkdir -p ${PACKAGE_RESULT_DIR}/usr/lib
cp ${binaryDir}/stormy-java/libOsvProcessBuilder.so ${PACKAGE_RESULT_DIR}/usr/lib/libOsvProcessBuilder.so

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "OSv Process Builder" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1
