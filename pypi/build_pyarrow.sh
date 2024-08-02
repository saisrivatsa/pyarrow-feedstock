#!/bin/sh
# *****************************************************************
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


set -e
set -x

#Build dependencies
#export SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION
#export PYARROW_WITH_FLIGHT=1
# Disable Gandiva
#export PYARROW_WITH_ORC=1
#export PYARROW_WITH_PLASMA=1
#export PYARROW_WITH_S3=0
#export PYARROW_CMAKE_GENERATOR=Ninja

##
export ARROW_HOME=$(pwd)/arrowcpp
export CMAKE_PREFIX_PATH=$ARROW_HOME
export PARQUET_HOME=$ARROW_HOME
export PYARROW_WITH_PARQUET=1
export PYARROW_WITH_DATASET=1
export PYARROW_PARALLEL=4
export PYARROW_BUILD_TYPE=release
export PYARROW_BUNDLE_ARROW_CPP_HEADERS=0
export PYARROW_WITH_GANDIVA=0
export PYARROW_WITH_HDFS=1

cd arrow/python

#below both cmds will work

python setup.py build_ext --inplace

#python setup.py \
#        build_ext \
#        install --single-version-externally-managed \
#                --record=record.txt
