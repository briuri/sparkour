#!/bin/bash

# Helper script to compile and JAR the Scala source code.
cd /opt/sparkour/working-rdds
scalac scala/buri/sparkour/RddSandbox.scala \
    -classpath /opt/spark/lib/spark-assembly-1.6.0-hadoop2.6.0.jar \
    -d output/scala
cd output/scala
jar -cf ../ScalaRddSandbox.jar *
cd ../..
/opt/spark/bin/spark-submit --class buri.sparkour.RddSandbox output/ScalaRddSandbox.jar
