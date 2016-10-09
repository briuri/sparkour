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

from __future__ import print_function
from pyspark import AccumulatorParam
from pyspark.sql import SparkSession

"""
    Uses accumulators to provide statistics on potentially incorrect
    data.

    This example still uses the deprecated Accumulator API from
    Spark 1.x. The AccumlatorV2 from Spark 2.0 has not yet
    been implemented in PySpark. You can track this work in
    https://issues.apache.org/jira/browse/SPARK-16861

    camelCase used for variable names for consistency and
    ease of translation across the prevailing style of
    the Java, R, and Scala examples.
"""

# Create a function that checks for questionable values.
def validate(row):
    height = row.height
    if (height < 15 or height > 84):
        heightCount.add(1)
        heightValues.add(str(height))

# Create a custom accumulator for string concatenation
# Contrived example -- see recipe for caveats.
class StringAccumulatorParam(AccumulatorParam):
    def zero(self, initialValue=""):
        return ""

    def addInPlace(self, s1, s2):
        return s1.strip() + " " + s2.strip()

if __name__ == "__main__":
    spark = SparkSession.builder.appName("aggregating_accumulators").getOrCreate()

    # Create an accumulator to count how many rows might be inaccurate.
    heightCount = spark.sparkContext.accumulator(0)

    # Create an accumulator to store all questionable values.
    heightValues = spark.sparkContext.accumulator("", StringAccumulatorParam())

    # Create a DataFrame from a file of names and heights in inches.
    heightDF = spark.read.json("heights.json")

    # Validate the data with the function.
    heightDF.foreach(lambda x : validate(x))

    # Show how many questionable values were found and what they were.
    print("{} rows had questionable values.".format(heightCount.value))
    print("Questionable values: {}".format(heightValues.value))

    spark.stop()
