#!/bin/bash

# Helper script to compile and JAR the Scala source code.
set -e
cd /opt/sparkour/working-dataframes
javac java/buri/sparkour/DataFrameSandbox.java \
    -classpath /opt/spark/lib/spark-assembly-1.6.0-hadoop2.6.0.jar \
    -d output/java
cd output/java
jar -cf ../JavaDataFrameSandbox.jar *
cd ../..
/opt/spark/bin/spark-submit --class buri.sparkour.DataFrameSandbox output/JavaDataFrameSandbox.jar
