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

# Performs a variety of DataFrames manipulations using raw SQL and
# User-Defined Functions (UDFs).

library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
sparkR.session()

# Create a DataFrame based on the JSON results.
rawDF <- read.df("loudoun_d_primary_results_2016.json", "json")

# Register as a SQL-accessible table
createOrReplaceTempView(rawDF, "votes")

print("Who was on the ballot?")
# Get all distinct candidate names from the DataFrame
query <- "SELECT DISTINCT candidate_name FROM votes"
print(collect(sql(query)))

print("What order were candidates on the ballot?")
# Get the ballot order and discard the many duplicates (all VA ballots are the same)
# We also register this DataFrame as a table to reuse later.
query <- paste("SELECT DISTINCT candidate_name, candidate_ballot_order",
    "FROM votes ORDER BY candidate_ballot_order", sep=" ")
orderDF <- sql(query)
createOrReplaceTempView(orderDF, "ordered_candidates")
print(collect(orderDF))

print("What order were candidates on the ballot (in descriptive terms)?")
# Load a reference table of friendly names for the ballot orders.
friendlyDF <- read.df("friendly_orders.json", "json")
createOrReplaceTempView(friendlyDF, "ballot_order")
# Join the tables so the results show descriptive text
query <- paste("SELECT oc.candidate_name, bo.friendly_name",
    "FROM ordered_candidates oc JOIN ballot_order bo",
    "ON oc.candidate_ballot_order = bo.candidate_ballot_order", sep=" ")
print(collect(sql(query)))

print("How many votes were cast?")
# Orginal data is string-based. Create an integer version of the total votes column.
# Because UDFs are not yet supported in SparkR, we cast the column first, then run SQL.
votesColumn <- alias(cast(rawDF$total_votes, "int"), "total_votes_int")
votesDF <- withColumn(rawDF, "total_votes_int", cast(rawDF$total_votes, "int"))
createOrReplaceTempView(votesDF, "votes_int")
# Get the integer-based votes column and sum all values together
query <- "SELECT SUM(total_votes_int) AS sum_total_votes FROM votes_int"
print(collect(sql(query)))

print("How many votes did each candidate get?")
query <- paste("SELECT candidate_name, SUM(total_votes_int) AS sum_total_votes",
    "FROM votes_int GROUP BY candidate_name ORDER BY sum_total_votes DESC", sep=" ")
print(collect(sql(query)))
    
print("Which polling station had the highest physical turnout?")
# All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
query <- paste("SELECT precinct_name, SUM(total_votes_int) AS sum_total_votes",
    "FROM votes_int WHERE precinct_code NOT LIKE '##%'",
    "GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1", sep=" ")
print(collect(sql(query)))

sparkR.stop()
