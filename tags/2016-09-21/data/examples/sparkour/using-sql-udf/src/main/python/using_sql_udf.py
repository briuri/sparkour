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
from pyspark.sql import SparkSession
from pyspark.sql.types import *
import pyspark.sql.functions as func

"""
    Performs a variety of DataFrames manipulations using raw SQL and
    User-Defined Functions (UDFs).
    
    camelCase used for variable names for consistency and
    ease of translation across the prevailing style of
    the Java, R, and Scala examples.
"""
if __name__ == "__main__":
    spark = SparkSession.builder.appName("using_sql_udf").getOrCreate()

    # Create a DataFrame based on the JSON results.
    rawDF = spark.read.json("loudoun_d_primary_results_2016.json")

    # Register as a SQL-accessible table
    rawDF.createOrReplaceTempView("votes")

    print("Who was on the ballet?")
    # Get all distinct candidate names from the DataFrame
    query = "SELECT DISTINCT candidate_name FROM votes"
    spark.sql(query).show()

    print("What order were candidates on the ballot?")
    # Get the ballot order and discard the many duplicates (all VA ballots are the same)
    # We also register this DataFrame as a table to reuse later.
    query = """SELECT DISTINCT candidate_name, candidate_ballot_order
        FROM votes ORDER BY candidate_ballot_order"""
    orderDF = spark.sql(query)
    orderDF.createOrReplaceTempView("ordered_candidates")
    orderDF.show()

    print("What order were candidates on the ballot (in descriptive terms)?")
    # Load a reference table of friendly names for the ballot orders.
    friendlyDF = spark.read.json("friendly_orders.json")
    friendlyDF.createOrReplaceTempView("ballot_order")
    # Join the tables so the results show descriptive text.
    query = """SELECT oc.candidate_name, bo.friendly_name
        FROM ordered_candidates oc JOIN ballot_order bo 
        ON oc.candidate_ballot_order = bo.candidate_ballot_order""" 
    spark.sql(query).show()

    print("How many votes were cast?")
    # Orginal data is string-based. Create a UDF to cast as an integer.
    spark.udf.register("to_int", lambda x: int(x))
    query = "SELECT SUM(to_int(total_votes)) AS sum_total_votes FROM votes"
    spark.sql(query).show()
   
    print("How many votes did each candidate get?")
    query = """SELECT candidate_name, SUM(to_int(total_votes)) AS sum_total_votes
        FROM votes GROUP BY candidate_name ORDER BY sum_total_votes DESC"""
    spark.sql(query).show()

    print("Which polling station had the highest physical turnout?")
    # All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
    query = """SELECT precinct_name, SUM(to_int(total_votes)) AS sum_total_votes
        FROM votes WHERE precinct_code NOT LIKE '##%'
        GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1"""
    spark.sql(query).show()

    spark.stop()
