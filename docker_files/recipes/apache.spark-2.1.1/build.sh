#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting Apache Spark"

echo "Build OSv Process Builder (mvn fails to build spark if not)"

cd ${RECIPE_DIR}
git clone -b feature/java_so https://github.com/gasper-vrhovsek/osv-process-builder-lib.git

cd osv-process-builder-lib
mvn install -T ${CPU_COUNT}
osvPbDir=${RECIPE_DIR}/osv-process-builder-lib/target

echo "Build Spark"

cd ${RECIPE_DIR}
git clone -b feature/v.2.1.1_osvProcessBuilder https://github.com/gasper-vrhovsek/spark.git
cd ${RECIPE_DIR}/spark
./dev/make-distribution.sh --tgz -Phadoop-2.7

echo "Grab results needed"

mkdir ${PACKAGE_RESULT_DIR}/spark
mkdir -p ${PACKAGE_RESULT_DIR}/spark/launcher/target/scala-2.11
mkdir -p ${PACKAGE_RESULT_DIR}/usr/lib
tar xvf ${RECIPE_DIR}/spark/spark-2.1.1-bin-2.7.3.tgz -C ${PACKAGE_RESULT_DIR}/spark --strip-components=1
cp ${osvPbDir}/libOsvProcessBuilder.so ${PACKAGE_RESULT_DIR}/usr/lib/libOsvProcessBuilder.so

echo "Create configuration files for Capstan"

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "Apache Spark" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.3 \
    --require openjdk8-zulu-compact3-with-java-beans \
    --platform ${PLATFORM}
