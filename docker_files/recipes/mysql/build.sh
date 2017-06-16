#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# Clear usr.manifest.skel that is already contained in bootstrap package
echo "[manifest]" > ${OSV_DIR}/usr.manifest.skel

echo "Exporting MySQL"

# make fails if there is no 'mysql' user
useradd -ms /bin/bash mysql

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=mysql -j ${CPU_COUNT}

cd ${OSV_BUILD_DIR}
${OSV_DIR}/scripts/upload_manifest.py -m usr.manifest -e ${PACKAGE_RESULT_DIR} -D gccbase=${GCCBASE} -D miscbase=${MISCBASE}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "MySQL 5.6.21". \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 5.6.21

echo "Include additional files in MPM"
cd ${PACKAGE_RESULT_DIR}
cp ${RECIPE_DIR}/mysql-init.sql ./etc/mysql-init.sql
cp ${RECIPE_DIR}/run.yaml ./meta/run.yaml

echo "Done"
