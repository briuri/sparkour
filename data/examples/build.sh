#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Command line entry point for building the examples.
# This script is for pre-publishing only. You don't need it
# to run any examples.
#

USAGE="Usage: build.sh [clean|create|zip] id [name_compiled] [name_interpreted]\n
    \tbuild.sh create some-example SomeExample some_example\n
    \tbuild.sh clean some-example\n
    \tbuild.sh zip some-example"
COMMAND=$1
ID=$2
NAME_COMPILED=$3
NAME_INTERPRETED=$4
PACKAGE="buri/sparkour"
EXAMPLES_PATH="/opt/examples/sparkour"
EXAMPLE_PATH="$EXAMPLES_PATH/$ID"
SRC_PATH="$EXAMPLE_PATH/src/main"
OUTPUT_PATH="$EXAMPLE_PATH/target"
JAVA_CP="$SPARK_HOME/lib/spark-assembly-1.6.1-hadoop2.6.0.jar"			# Spark assembly
JAVA_CP="$JAVA_CP:/opt/examples/lib/commons-csv-1.2.jar"				# building-sbt

# Asserts that an example exists before cleaning or zipping it.
function assertExists {
    if [[ ! -d "$EXAMPLE_PATH" ]]; then
        echo "Could not locate ${ID} example."
        exit 1
    fi
}

# Asserts that an example does not exist yet before creating it.
function assertNew {
    if [[ -d "$EXAMPLE_PATH" ]]; then
        echo "${ID} example already exists."
        exit 1
    fi
}

# Cleans any compiled bits within an example.
function cleanExample {
    rm -rf $OUTPUT_PATH/*
    rm -f $SRC_PATH/python/*.pyc
    if [[ -f "$EXAMPLE_PATH/build.sbt" ]]; then
        rm -rf $EXAMPLE_PATH/project/project/target/*
        rm -rf $EXAMPLE_PATH/project/target/*
    fi
}

# Compiles Java, Python, and Scala code to check for syntax errors. R not supported.
function compileExample {
    if [[ -d "$SRC_PATH/java" ]]; then
        mkdir -p $OUTPUT_PATH/java
        javac $SRC_PATH/java/$PACKAGE/* -cp $JAVA_CP -d $OUTPUT_PATH/java
    fi
    if [[ -d "$SRC_PATH/python" ]]; then
        python -m py_compile $SRC_PATH/python/*.py
    fi
    if [[ -d "$SRC_PATH/scala" ]]; then
        mkdir -p $OUTPUT_PATH/scala
        scalac $SRC_PATH/scala/$PACKAGE/* -cp $JAVA_CP -d $OUTPUT_PATH/scala
    fi
}

# Creates a new example using the files in the template directory.
function createExample {
    mkdir $EXAMPLE_PATH
    cp -R template/* $EXAMPLE_PATH
    sed -i "s/@id@/$ID/" $EXAMPLE_PATH/sparkour.sh
    sed -i "s/@name_compiled@/$NAME_COMPILED/" $EXAMPLE_PATH/sparkour.sh
    sed -i "s/@name_compiled@/$NAME_COMPILED/" $SRC_PATH/java/$PACKAGE/Template.java
    sed -i "s/@name_compiled@/$NAME_COMPILED/" $SRC_PATH/python/template.py
    sed -i "s/@name_compiled@/$NAME_COMPILED/" $SRC_PATH/scala/$PACKAGE/Template.scala
    sed -i "s/@name_interpreted@/$NAME_INTERPRETED/" $EXAMPLE_PATH/sparkour.sh
    sed -i "s/@name_interpreted@/$NAME_INTERPRETED/" $SRC_PATH/python/template.py 
    mv $SRC_PATH/java/$PACKAGE/Template.java $SRC_PATH/java/$PACKAGE/J$NAME_COMPILED.java
    mv $SRC_PATH/python/template.py $SRC_PATH/python/$NAME_INTERPRETED.py
    mv $SRC_PATH/r/template.R $SRC_PATH/r/$NAME_INTERPRETED.R
    mv $SRC_PATH/scala/$PACKAGE/Template.scala $SRC_PATH/scala/$PACKAGE/S$NAME_COMPILED.scala
    echo "Next, run 'svn add' and 'svn propset svn:ignore \"*\" target'."
}

# Creates a ZIP archive of an example.
function zipExample {
    rm -f zip/$ID.zip
    sudo zip -r zip/$ID.zip sparkour/$ID -x .svn
    sudo chown ec2-user:ec2-user zip/$ID.zip
}

if [[ -z $1 || -z $2 || ($1 = "create" && (-z $3 || -z $4)) ]]; then
    echo -e $USAGE
    exit 1
fi
set -e

if [ $COMMAND = "create" ]; then
    assertNew
    createExample
elif [ $COMMAND = "clean" ]; then
    assertExists
    cleanExample
elif [ $COMMAND = "zip" ]; then
    assertExists
    compileExample
    cleanExample
    zipExample
else
    echo -e $USAGE
    exit 1
fi
