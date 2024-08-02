#!/bin/sh
# *****************************************************************
# (C) Copyright IBM Corp. 2019, 2022. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *****************************************************************

#The below flags are present in open-ce and we have not used in this case

#-DLLVM_TOOLS_BINARY_DIR=$PREFIX/bin \
    #-DPYTHON_EXECUTABLE=$PYTHON \
    #-DPython3_EXECUTABLE=$PYTHON \
    #-DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
    #-DARROW_BUILD_BENCHMARKS=OFF \
    #-DARROW_BUILD_STATIC=OFF \
    #-DARROW_BUILD_UTILITIES=OFF \
    #-DBUILD_SHARED_LIBS=ON \
    #-DARROW_DEPENDENCY_SOURCE=SYSTEM \
    #-DARROW_PACKAGE_PREFIX=$PREFIX \
    #-DARROW_PYTHON=ON \
    #-DARROW_S3=OFF \
    #-DARROW_PLASMA=ON \

##please run below script on python virtual env 

#python3 -m venv pyarrow-dev
#source ./pyarrow-dev/bin/activate

set -e
set -x

repo=https://github.com/apache/arrow
branch=apache-arrow-15.0.1


git clone -b $branch $repo
cd arrow && git submodule update --init
export PARQUET_TEST_DATA="cpp/submodules/parquet-testing/data"
export ARROW_TEST_DATA="testing/data"
cd
pip install Cython==3.0.8   ##python build for pyarrow only suuports >=0.29>31<=3.0.8
pip install -r arrow/python/requirements-build.txt
pip install cmake
pip install ninja

mkdir arrowcpp

export ARROW_HOME=$(pwd)/arrowcpp
export PREFIX=$ARROW_HOME
export LD_LIBRARY_PATH=$(pwd)/arrowcpp/lib:$LD_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$ARROW_HOME:$CMAKE_PREFIX_PATH

mkdir arrow/cpp/build
pushd arrow/cpp/build


EXTRA_CMAKE_ARGS=""
export CC=`which gcc`
export CXX=`which g++`

echo $CC $CXX

# Include g++'s system headers
if [ "$(uname)" == "Linux" ]; then
  SYSTEM_INCLUDES=$(echo | ${CXX} -E -Wp,-v -xc++ - 2>&1 | grep '^ ' | awk '{print "-isystem;" substr($1, 1)}' | tr '\n' ';')
  EXTRA_CMAKE_ARGS=" -DARROW_GANDIVA_PC_CXX_FLAGS=${SYSTEM_INCLUDES}"
  sed -ie 's;"--with-jemalloc-prefix\=je_arrow_";"--with-jemalloc-prefix\=je_arrow_" "--with-lg-page\=16";g' ../cmake_modules/ThirdpartyToolchain.cmake
fi

if [[ "$(uname -m)" == "ppc64le" ]]; then
  EXTRA_CMAKE_ARGS=" ${EXTRA_CMAKE_ARGS} -DARROW_ALTIVEC=ON"
fi

pwd

cmake -DCMAKE_INSTALL_PREFIX=$ARROW_HOME -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=release -DARROW_BUILD_TESTS=OFF -DARROW_COMPUTE=ON -DARROW_CSV=ON -DARROW_DATASET=ON -DARROW_FILESYSTEM=ON -DARROW_HDFS=ON -DARROW_JSON=ON -DARROW_PARQUET=ON -DARROW_WITH_BROTLI=ON -DARROW_WITH_BZ2=ON -DARROW_WITH_LZ4=ON -DARROW_WITH_SNAPPY=ON -DARROW_WITH_ZLIB=ON -DARROW_WITH_ZSTD=ON -DARROW_BOOST_USE_SHARED=ON -DARROW_FLIGHT=ON -DARROW_FLIGHT_REQUIRE_TLSCREDENTIALSOPTIONS=ON -DARROW_WITH_BROTLI=ON -DARROW_JEMALLOC=ON -DARROW_MIMALLOC=ON -DARROW_ORC=ON -GNinja ..

ninja install

popd
