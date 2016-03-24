#!/bin/bash

# Helper script to compile and JAR the Scala source code.
set -e
cd /opt/sparkour/working-dataframes
scalac scala/buri/sparkour/DataFrameSandbox.scala \
    -classpath /opt/spark/lib/spark-assembly-1.6.0-hadoop2.6.0.jar \
    -d output/scala
cd output/scala
jar -cf ../ScalaDataFrameSandbox.jar *
cd ../..
/opt/spark/bin/spark-submit --class buri.sparkour.DataFrameSandbox output/ScalaDataFrameSandbox.jar
