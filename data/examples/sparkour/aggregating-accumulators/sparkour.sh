#!/bin/sh
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
# Convenience script for submitting examples to Spark for execution.
#

USAGE="Usage: sparkour.sh [java|python|r|scala] [--master spark://url:port]"
LANGUAGE=$1
SPARKOUR_HOME="/opt/sparkour/"
SRC_PATH="src/main"
PACKAGE="buri/sparkour"
NAME_COMPILED="AggregatingAccumulators"
NAME_INTERPRETED="aggregating_accumulators"
ID="aggregating-accumulators"
APP_ARGS=""

if [ -z $1 ]; then
    echo $USAGE
    exit 1
fi
shift
set -e
cd $SPARKOUR_HOME$ID

if [ $LANGUAGE = "java" ]; then
    mkdir -p target/java
    javac $SRC_PATH/java/$PACKAGE/*.java -classpath "$SPARK_HOME/jars/*" -d target/java -Xdiags:verbose
    cd target/java
    jar -cf ../J$NAME_COMPILED.jar *
    cd ../..
    APP_ARGS="--class buri.sparkour.J${NAME_COMPILED} target/J${NAME_COMPILED}.jar ${APP_ARGS}"
elif [ $LANGUAGE = "python" ]; then
	APP_ARGS="$SRC_PATH/python/${NAME_INTERPRETED}.py ${APP_ARGS}"
elif [ $LANGUAGE = "r" ]; then
    echo "This example uses the Spark Core API, which is not exposed through SparkR."
    exit 1
elif [ $LANGUAGE = "scala" ]; then
    mkdir -p target/scala
    scalac $SRC_PATH/scala/$PACKAGE/*.scala -classpath "$SPARK_HOME/jars/*" -d target/scala
    cd target/scala
    jar -cf ../S$NAME_COMPILED.jar *
    cd ../..
    APP_ARGS="--class buri.sparkour.S${NAME_COMPILED} target/S${NAME_COMPILED}.jar ${APP_ARGS}"
else
    echo $USAGE
    exit 1
fi

$SPARK_HOME/bin/spark-submit "$@" $APP_ARGS
