#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting Apache Spark"

echo "Build OSv Process Builder (mvn fails to build spark if not)"

cd ${RECIPE_DIR}
git clone -b feature/pyspark_testing https://github.com/gasper-vrhovsek/osv-process-builder-lib.git

osvpbDir=${RECIPE_DIR}/osv-process-builder-lib/src/main/java/org/mikelangelo/osvprocessbuilder
cd ${osvpbDir}
make -j ${CPU_COUNT}
mvn install:install-file \
 -Dfile=osv-process-builder.jar \
 -DgroupId=org.mikelangelo.osv \
 -DartifactId=osvProcessBuilder \
 -Dversion=0.1 \
 -Dpackaging=jar \
 -T ${CPU_COUNT}

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
cp ${osvpbDir}/stormy-java/libOsvProcessBuilder.so ${PACKAGE_RESULT_DIR}/usr/lib/libOsvProcessBuilder.so

echo "Create configuration files for Capstan"

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "Apache Spark" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1 \
    --require openjdk8-zulu-compact3-with-java-beans

cat >meta/run.yaml <<'EOL'
runtime: native
config_set:
  master:
    bootcmd: /java.so -Xms512m -Xmx512m -cp /spark/conf:/spark/jars/* -Dscala.usejavacp=true org.apache.spark.deploy.master.Master --host 0.0.0.0 --port 7077 --webui-port 8080
  worker:
    bootcmd: --env=MASTER?=localhost:7077 /java.so -Xms512m -Xmx512m -cp /spark/conf:/spark/jars/* -Dscala.usejavacp=true org.apache.spark.deploy.worker.Worker $MASTER
config_set_default: worker
EOL

cp ${RECIPE_DIR}/README.md ${PACKAGE_RESULT_DIR}/meta/
