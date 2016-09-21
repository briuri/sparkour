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
import json

from pyspark.sql import SparkSession

"""
    Loads a DataFrame from a relational database table over JDBC,
    manipulates the data, and saves the results back to a table.

    camelCase used for variable names for consistency and
    ease of translation across the prevailing style of
    the Java, R, and Scala examples.
"""
if __name__ == "__main__":
    spark = SparkSession.builder.appName("using_jdbc").getOrCreate()

    # Load properties from file
    with open('db-properties.json') as propertyFile:
        properties = json.load(propertyFile)
    jdbcUrl = properties["jdbcUrl"]
    dbProperties = {
        "user" : properties["user"],
        "password" : properties["password"]
    }

    print("A DataFrame loaded from the entire contents of a table over JDBC.")
    where = "sparkour.people"
    entireDF = spark.read.jdbc(jdbcUrl, where, properties=dbProperties)
    entireDF.printSchema()
    entireDF.show()

    print("Filtering the table to just show the males.")
    entireDF.filter("is_male = 1").show()

    print("Alternately, pre-filter the table for males before loading over JDBC.")
    where = "(select * from sparkour.people where is_male = 1) as subset"
    malesDF = spark.read.jdbc(jdbcUrl, where, properties=dbProperties)
    malesDF.show()

    print("Update weights by 2 pounds (results in a new DataFrame with same column names)")
    heavyDF = entireDF.withColumn("updated_weight_lb", entireDF["weight_lb"] + 2)
    updatedDF = heavyDF.select("id", "name", "is_male", "height_in", "updated_weight_lb") \
        .withColumnRenamed("updated_weight_lb", "weight_lb")
    updatedDF.show()

    print("Save the updated data to a new table with JDBC")
    where = "sparkour.updated_people"
    updatedDF.write.jdbc(jdbcUrl, where, properties=dbProperties, mode="error")

    print("Load the new table into a new DataFrame to confirm that it was saved successfully.")
    retrievedDF = spark.read.jdbc(jdbcUrl, where, properties=dbProperties)
    retrievedDF.show()

    spark.stop()
