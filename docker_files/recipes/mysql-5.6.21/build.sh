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

echo "Exporting MySQL"

# make fails if there is no 'mysql' user
useradd -ms /bin/bash mysql

cd ${OSV_DIR}
${OSV_DIR}/scripts/build image=mysql export=all usrskel=none export_dir=$PACKAGE_RESULT_DIR -j ${CPU_COUNT}

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "MySQL 5.6.21". \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.2 \
    --platform ${PLATFORM}

echo "Include additional files in MPM"
cd ${PACKAGE_RESULT_DIR}
cp ${RECIPE_DIR}/mysql-init.sql ./etc/mysql-init.sql
tar -xvzf ${RECIPE_DIR}/data.tar.gz -C ./usr/data

echo "Done"
