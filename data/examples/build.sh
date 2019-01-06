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

USAGE="Usage:\n
    \tbuild.sh create some-example SomeExample some_example\n
    \tbuild.sh clean some-example\n
    \tbuild.sh run some-example\n
    \tbuild.sh run all\n
    \tbuild.sh zip some-example\n
    \tbuild.sh zip all"

COMMAND=$1
ID=$2
NAME_COMPILED=$3
NAME_INTERPRETED=$4
MANUAL_EXAMPLES=("building-maven" "building-sbt" "submitting-applications" "using-jdbc")
SPARK_VERSION=`head -1 $SPARK_HOME/RELEASE | awk '{print $2}'`
PROJECT_PATH="/opt/git/sparkour"
PACKAGE="buri/sparkour"
EXAMPLES_PATH="$PROJECT_PATH/data/examples/sparkour"
EXAMPLE_PATH="$EXAMPLES_PATH/$ID"
SRC_PATH="$EXAMPLE_PATH/src/main"
OUTPUT_PATH="$EXAMPLE_PATH/target"
LOG_PATH="$PROJECT_PATH/data/examples/log"
JAVA_CP="$SPARK_HOME/jars/*"                                           # Spark Core
JAVA_CP="$JAVA_CP:$PROJECT_PATH/data/examples/lib/commons-csv-1.2.jar" # building-sbt

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
    rm -rf $EXAMPLE_PATH/metastore_db
    rm -rf $EXAMPLE_PATH/spark-warehouse
    if [[ -f "$EXAMPLE_PATH/build.sbt" ]]; then
        rm -rf $EXAMPLE_PATH/project/project/target/*
        rm -rf $EXAMPLE_PATH/project/target/*
    fi
}

# Compiles Java, Python, and Scala code to check for syntax errors. R not supported.
function compileExample {
    if [[ -d "$SRC_PATH/java" ]]; then
        mkdir -p $OUTPUT_PATH/java
        javac $SRC_PATH/java/$PACKAGE/* -cp "$JAVA_CP" -d $OUTPUT_PATH/java
    fi
    if [[ -d "$SRC_PATH/python" ]]; then
        python -m py_compile $SRC_PATH/python/*.py
    fi
    if [[ -d "$SRC_PATH/scala" ]]; then
        mkdir -p $OUTPUT_PATH/scala
        scalac $SRC_PATH/scala/$PACKAGE/* -cp "$JAVA_CP" -d $OUTPUT_PATH/scala
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

# Iterates over all examples and runs the sparkour.sh script for each.
function runAll {
    for RUN_EXAMPLE in $EXAMPLES_PATH/*; do
        RUN_SIMPLE_FILENAME=$(basename "$RUN_EXAMPLE")
        bash ./build.sh run $RUN_SIMPLE_FILENAME
    done
}

# Runs the sparkour.sh script for an example.
function runExample {
    if [[ "${MANUAL_EXAMPLES[*]}" == *"$ID"* ]]; then
        echo "Skipping $ID because it must be manually run."
    else
        OUTPUT_FILE="$LOG_PATH/`date +%Y-%m-%d`-$SPARK_VERSION.txt"
        echo "Running sparkour.sh for $ID to $OUTPUT_FILE"
        printf "### $ID ###" >> $OUTPUT_FILE
        for LANGUAGE in "java" "python" "r" "scala"; do
            printf "\n$LANGUAGE\n" >> $OUTPUT_FILE
            bash $EXAMPLES_PATH/$ID/sparkour.sh $LANGUAGE >> $OUTPUT_FILE
        done
        printf "\n" >> $OUTPUT_FILE
    fi
}

# Iterates over all examples and creates a ZIP archive for each.
function zipAll {
    for ZIP_EXAMPLE in $EXAMPLES_PATH/*; do
        ZIP_SIMPLE_FILENAME=$(basename "$ZIP_EXAMPLE")
        bash ./build.sh zip $ZIP_SIMPLE_FILENAME
    done
}

# Creates a ZIP archive of an example.
function zipExample {
    rm -f zip/$ID.zip
    sudo zip -qr zip/$ID.zip sparkour/$ID -x .svn
    sudo chown ec2-user:ec2-user zip/$ID.zip
}

if [[ -z $1 || -z $2 || ($1 = "create" && (-z $3 || -z $4)) ]]; then
    echo -e $USAGE
    exit 1
fi
set -e

if [[ $COMMAND = "run" && $ID = "all" ]]; then
    runAll
elif  [[ $COMMAND = "zip" && $ID = "all" ]]; then
    zipAll
elif [ $COMMAND = "create" ]; then
    assertNew
    createExample
elif [ $COMMAND = "clean" ]; then
    assertExists
    cleanExample
elif [ $COMMAND = "run" ]; then
    assertExists
    compileExample
    runExample
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
