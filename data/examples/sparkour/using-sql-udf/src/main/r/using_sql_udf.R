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
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

# Create a DataFrame based on the JSON results.
rawDF <- read.df(sqlContext, "loudoun_d_primary_results_2016.json", "json")

print("Who was on the ballet?")
# Get all distinct candidate names from the DataFrame
print(collect(distinct(select(rawDF, "candidate_name"))))

print("What order were candidates on the ballot?")
# Get the ballot order and discard the many duplicates (all VA ballots are the same)
# Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
orderDF <- orderBy(distinct(select(rawDF, "candidate_name", "candidate_ballot_order")), "candidate_ballot_order")
persist(orderDF, "MEMORY_ONLY")
print(collect(orderDF))

print("What order were candidates on the ballot (in descriptive terms)?")
# Load a reference table of friendly names for the ballot orders.
friendlyDF <- read.df(sqlContext, "friendly_orders.json", "json")
# Join the tables so the results show descriptive text
joinedDF <- join(orderDF, friendlyDF, orderDF$candidate_ballot_order == friendlyDF$candidate_ballot_order)
# Hide the numeric column in the output.
print(collect(select(joinedDF, "candidate_name", "friendly_name")))

print("How many votes were cast?")
# Orginal data is string-based. Create an integer version of the total votes column.
votesColumn <- alias(cast(rawDF$total_votes, "int"), "total_votes_int")
# Get the integer-based votes column and sum all values together
print(collect(sum(groupBy(select(rawDF, votesColumn)), "total_votes_int")))
   
print("How many votes did each candidate get?")
# Get just the candidate names and votes.
candidateDF <- select(rawDF, rawDF$candidate_name, votesColumn)
# Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
# Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
groupedDF <- agg(groupBy(candidateDF, "candidate_name"), sum_column=sum(candidateDF$total_votes_int))
summaryDF <- orderBy(groupedDF, desc(groupedDF$sum_column))
persist(summaryDF, "MEMORY_ONLY")
print(collect(summaryDF))

print("Which polling station had the highest physical turnout?")
# All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
# Spark's cast function converts these to "null".
precinctColumn <- alias(cast(rawDF$precinct_code, "int"), "precinct_code_int")
# Get the precinct name, integer-based code, and integer-based votes, then filter on non-null codes.
pollingDF <- filter(select(rawDF, rawDF$precinct_name, precinctColumn, votesColumn), "precinct_code_int is not null")
# Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
# Then, show the max row.
groupedDF <- agg(groupBy(pollingDF, "precinct_name"), sum_column=sum(pollingDF$total_votes_int))
pollingDF <- limit(orderBy(groupedDF, desc(groupedDF$sum_column)), 1)
print(collect(pollingDF))

sparkR.stop()
