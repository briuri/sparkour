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
from pyspark import SparkContext
from pyspark.sql import SQLContext
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
    sc = SparkContext(appName="using_sql_udf")
    sqlContext = SQLContext(sc)

    # Create a DataFrame based on the JSON results.
    rawDF = sqlContext.read.json("loudoun_d_primary_results_2016.json")

    print("Who was on the ballet?")
    # Get all distinct candidate names from the DataFrame
    rawDF.select("candidate_name").distinct().show()

    print("What order were candidates on the ballot?")
    # Get the ballot order and discard the many duplicates (all VA ballots are the same)
    # Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
    orderDF = rawDF.select(rawDF["candidate_name"], rawDF["candidate_ballot_order"]) \
        .dropDuplicates().orderBy("candidate_ballot_order").persist()
    orderDF.show()

    print("What order were candidates on the ballot (in descriptive terms)?")
    # Load a reference table of friendly names for the ballot orders.
    friendlyDF = sqlContext.read.json("friendly_orders.json")
    # Join the tables so the results show descriptive text
    joinedDF = orderDF.join(friendlyDF, "candidate_ballot_order")
    # Hide the numeric column in the output.
    joinedDF.select(joinedDF["candidate_name"], joinedDF["friendly_name"]).show()

    print("How many votes were cast?")
    # Orginal data is string-based. Create an integer version of the total votes column.
    votesColumn = rawDF["total_votes"].cast("int").alias("total_votes_int")
    # Get the integer-based votes column and sum all values together
    rawDF.select(votesColumn).groupBy().sum("total_votes_int").show()
   
    print("How many votes did each candidate get?")
    # Get just the candidate names and votes.
    candidateDF = rawDF.select(rawDF["candidate_name"], votesColumn)
    # Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
    # Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
    summaryDF = candidateDF.groupBy("candidate_name").agg(func.sum("total_votes_int").alias("sum_column")) \
        .orderBy("sum_column", ascending=False).persist()
    summaryDF.show()

    print("Which polling station had the highest physical turnout?")
    # All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
    # Spark's cast function converts these to "null".
    precinctColumn = rawDF["precinct_code"].cast("int").alias("precinct_code_int")
    # Get the precinct name, integer-based code, and integer-based votes, then filter on non-null codes.
    pollingDF = rawDF.select(rawDF["precinct_name"], precinctColumn, votesColumn) \
        .filter("precinct_code_int is not null")
    # Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
    # Then, show the max row.
    pollingDF.groupBy("precinct_name").agg(func.sum("total_votes_int").alias("sum_column")) \
        .orderBy("sum_column", ascending=False).limit(1).show()

    sc.stop()
