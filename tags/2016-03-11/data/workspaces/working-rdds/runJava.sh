#!/bin/bash

# Helper script to compile and JAR the Scala source code.
set -e
cd /opt/sparkour/working-rdds
javac java/buri/sparkour/RddSandbox.java \
    -classpath /opt/spark/lib/spark-assembly-1.6.0-hadoop2.6.0.jar \
    -d output/java
cd output/java
jar -cf ../JavaRddSandbox.jar *
cd ../..
/opt/spark/bin/spark-submit --class buri.sparkour.RddSandbox output/JavaRddSandbox.jar
