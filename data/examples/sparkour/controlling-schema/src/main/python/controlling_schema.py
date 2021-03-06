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
import datetime
from pyspark.sql import Row, SparkSession
from pyspark.sql.types import ArrayType, BooleanType, DateType, IntegerType, MapType, StringType, TimestampType, StructField, StructType

"""
    Demonstrates strategies for controlling the schema of a
    DataFrame built from a JSON or RDD data source.

    camelCase used for variable names for consistency and
    ease of translation across the prevailing style of
    the Java, R, and Scala examples.
"""

def build_sample_data():
    """Build and return the sample data."""
    data = [
        Row(
            name="Alex",
            num_pets=3,
            paid_in_full=True,
            preferences={
                "preferred_vet": "Dr. Smith",
                "preferred_appointment_day": "Monday"
            },
            registered_on=datetime.datetime(2015, 1, 1, 12, 0),
            visits=[
                datetime.datetime(2015, 2, 1, 11, 0),
                datetime.datetime(2015, 2, 2, 10, 45),
            ],
        ),
        Row(
            name="Beth",
            num_pets=2,
            paid_in_full=False,
            preferences={
                "preferred_vet": "Dr. Travis",
            },
            registered_on=datetime.datetime(2013, 1, 1, 12, 0),
            visits=[
                datetime.datetime(2015, 1, 15, 12, 15),
                datetime.datetime(2015, 2, 1, 11, 15),
            ],
        ),
        Row(
            name="Charlie",
            num_pets=1,
            paid_in_full=True,
            preferences={},
            registered_on=datetime.datetime(2016, 5, 1, 12, 0),
            visits=[],
        ),
    ]
    return data
   
def build_schema():
    """Build and return a schema to use for the sample data."""
    schema = StructType(
        [
            StructField("name", StringType(), True),
            StructField("num_pets", IntegerType(), True),
            StructField("paid_in_full", BooleanType(), True),
            StructField("preferences", MapType(StringType(), StringType(), True), True),
            StructField("registered_on", DateType(), True),
            StructField("visits", ArrayType(TimestampType(), True), True),
        ]
    )
    return schema

if __name__ == "__main__":
    spark = SparkSession.builder.appName("controlling_schema").getOrCreate()

    # Create an RDD with sample data.
    dataRDD = spark.sparkContext.parallelize(build_sample_data())

    # Create a DataFrame from the RDD, inferring the schema from the first row.
    print("RDD: Schema inferred from first row.")
    dataDF = spark.createDataFrame(dataRDD, samplingRatio=None)
    dataDF.printSchema()

    # Create a DataFrame from the RDD, inferring the schema from a sampling of rows.
    print("RDD: Schema inferred from random sample.")
    dataDF = spark.createDataFrame(dataRDD, samplingRatio=0.6)
    dataDF.printSchema()

    # Create a DataFrame from the RDD, specifying a schema.
    print("RDD: Schema programmatically specified.")
    dataDF = spark.createDataFrame(dataRDD, schema=build_schema())
    dataDF.printSchema()
    
    # Create a DataFrame from a JSON source, inferring the schema from all rows.
    print("JSON: Schema inferred from all rows.")
    dataDF = spark.read.option("samplingRatio", 1.0).json("data.json")
    dataDF.printSchema()

    # Create a DataFrame from a JSON source, specifying a schema.
    print("JSON: Schema programmatically specified.")
    dataDF = spark.read.json("data.json", schema=build_schema())
    dataDF.printSchema()

    spark.stop()
