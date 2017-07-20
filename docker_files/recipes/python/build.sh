#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

echo "Exporting Python 2.7"

cd $RECIPE_DIR
rm -rf cpython
git clone https://github.com/python/cpython.git
cd cpython
# Use 2.7 branch for now
git checkout -b 2.7 origin/2.7

export PYTHON_PREFIX=$RECIPE_DIR/install
echo $PYTHON_PREFIX

# Configure to compile shared libs and make an explicit install dir that
# we are going to use for extracting the content for the package
./configure --enable-shared --prefix=$PYTHON_PREFIX
make -j $CPU_COUNT

# Add -shared flag to LDFLAGS
sed -i 's/^LDFLAGS=.*$/LDFLAGS=-shared/g' Makefile
# Compile just the python binary
make -j $CPU_COUNT python
# Make a copy so that we'll be able to use it later on.
cp python python.so

# Now we need to revert back the LDFLAGS as otherwise make install fails...
sed -i 's/^LDFLAGS=.*$/LDFLAGS=/g' Makefile
# Install to the prefix that we have set above. This will copy all the necessary
# files for us that we will then use in the app.
make -j $CPU_COUNT install

# Copy the shared object python.so to the install dir
cp python.so $PYTHON_PREFIX/bin/python

mkdir -p $PACKAGE_RESULT_DIR/pyenv/lib

# Copy binary and libs. These will be copied into root dir
cp $PYTHON_PREFIX/bin/python $PACKAGE_RESULT_DIR
cp $PYTHON_PREFIX/lib/libpython* $PACKAGE_RESULT_DIR

# Copy the Python environment. Since we'd like to exclude some dirs, rsync is used
rsync -a $PYTHON_PREFIX/lib/python2.7 $PACKAGE_RESULT_DIR/pyenv/lib --exclude test --exclude unittest

# Copy two files from the system... There must be a better way
cp /lib/x86_64-linux-gnu/libreadline.so* $PACKAGE_RESULT_DIR
cp /lib/x86_64-linux-gnu/libtinfo.so* $PACKAGE_RESULT_DIR

echo "Create configuration files for Capstan"

cd ${PACKAGE_RESULT_DIR}
capstan package init --name "${PACKAGE_NAME}" \
    --title "Python 2.7" \
    --author "MIKELANGELO Project (info@mikelangelo-project.eu)" \
    --version 0.1

echo "Done"
