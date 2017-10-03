#!/bin/bash
#
# Copyright (C) 2017 XLAB, Ltd.
#
# This work is open source software, licensed under the terms of the
# BSD license as described in the LICENSE file in the top-level directory.
#
# Usage:
#
#   publish.sh [RESULT_DIR]
#
# RESULT_DIR is optional and can be any path (defult: ./result)
#
# This script is used to publish all results found in the directory given by
# the first script argument. Alternatively, if the argument is not given a
# ./result subdir will be assumed. The script looks for "mike" and "packages"
# directories an uploads all relevant files sequentially to the MIKELANGELO
# package hub.
#
# Before using this script, you have to configure s3cmd (http://s3tools.org/s3cmd).
# After installing, you can invoke the configuration command
#
# $ s3cmd --configure
#
# You will be asked few AWS related questions (region, key, secret) that you need to
# provide for the user with write access.

set -o nounset
set -o errexit
set -o pipefail

result_dir=${1:-result/}

echo "Uploading packages from $result_dir"

IMAGES=`ls -1 $result_dir/mike`
for img in $IMAGES; do
  echo "Uploading image $img"
  for img_file in `ls -1 $result_dir/mike/$img/*.{yaml,qemu.gz}`; do
    echo "Uploading image file $img_file to s3://mikelangelo-capstan/mike/$img/${img_file##*/}"
    s3cmd put --acl-public --guess-mime-type $img_file s3://mikelangelo-capstan/mike/$img/${img_file##*/}
  done
done

FILES=`ls -1 $result_dir/packages/*.{yaml,mpm}`
for f in $FILES; do
    echo "Uploading package file: $f to s3://mikelangelo-capstan/packages/${f##*/}"
    s3cmd put --acl-public --guess-mime-type $f s3://mikelangelo-capstan/packages/${f##*/}
done

echo "DONE. All packages uploaded to S3 repository"
