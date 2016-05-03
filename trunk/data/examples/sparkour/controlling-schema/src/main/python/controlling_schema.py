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
from pyspark import SparkContext
from pyspark.sql import Row, SQLContext
from pyspark.sql.types import ArrayType, BooleanType, DateType, IntegerType, MapType, StringType, TimestampType, StructField, StructType

"""
    Demonstrates strategies for controlling the schema of a
    DataFrame built from a JSON or RDD data source.

    camelCase used for variable names for consistency and
    ease of translation across the prevailing style of
    the Java, R, and Scala examples.
"""
if __name__ == "__main__":
    sc = SparkContext(appName="controlling_schema")
    sqlContext = SQLContext(sc)

    # Define raw data for an RDD, consisting of 3 rows of veterinary records
    data = [
        Row(
            name="Alex",
            num_pets=3,
            paid_in_full=True,
            preferences={
                "preferred_vet": "Dr. Smith",
                "preferred_appointment_day": "Monday"
            },
            registered_on=datetime.datetime(2015, 01, 01, 12, 00),
            visits=[
                datetime.datetime(2015, 02, 01, 11, 00),
                datetime.datetime(2015, 02, 02, 10, 45),
            ],
        ),
        Row(
            name="Beth",
            num_pets=2,
            paid_in_full=False,
            preferences={
                "preferred_vet": "Dr. Travis",
            },
            registered_on=datetime.datetime(2013, 01, 01, 12, 00),
            visits=[
                datetime.datetime(2015, 01, 15, 12, 15),
                datetime.datetime(2015, 02, 01, 11, 15),
            ],
        ),
        Row(
            name="Charlie",
            num_pets=1,
            paid_in_full=True,
            preferences={},
            registered_on=datetime.datetime(2016, 05, 01, 12, 00),
            visits=[],
        ),
    ]
    dataRDD = sc.parallelize(data)

    # Create a DataFrame from the RDD, inferring the schema from the first row.
    print("RDD: Schema inferred from first row.")
    dataDF = sqlContext.createDataFrame(dataRDD, samplingRatio=None)
    dataDF.printSchema()

    # Create a DataFrame from the RDD, inferring the schema from a sampling of rows.
    print("RDD: Schema inferred from random sample.")
    dataDF = sqlContext.createDataFrame(dataRDD, samplingRatio=0.6)
    dataDF.printSchema()

    # Create a DataFrame from the RDD, specifying a schema.
    print("RDD: Schema programmatically specified.")
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
    dataDF = sqlContext.createDataFrame(dataRDD, schema=schema)
    dataDF.printSchema()
    
    # Create a DataFrame from a JSON source, inferring the schema from all rows.
    print("JSON: Schema inferred from all rows.")
    dataDF = sqlContext.read.json("data.json")
    dataDF.printSchema()

    # Create a DataFrame from a JSON source, specifying a schema.
    print("JSON: Schema programmatically specified.")
    dataDF = sqlContext.read.json("data.json", schema=schema)
    dataDF.printSchema()

    sc.stop()
