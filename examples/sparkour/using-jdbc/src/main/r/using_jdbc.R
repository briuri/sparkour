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

#
# Loads a DataFrame from a relational database table over JDBC,
# manipulates the data, and saves the results back to a new table.
#
install.packages("rjson", repos="http://cran.r-project.org")
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
library(rjson)

sparkR.session()

# Load properties from file
properties <- fromJSON(file="db-properties.json")
jdbcUrl <- paste(properties["jdbcUrl"], "?user=", properties["user"], "&password=", properties["password"], sep="")

print("A DataFrame loaded from the entire contents of a table over JDBC.")
where <- "sparkour.people"
entireDF <- read.jdbc(url=jdbcUrl, tableName=where)
printSchema(entireDF)
print(collect(entireDF))

print("Filtering the table to just show the males.")
print(collect(filter(entireDF, "is_male = 1")))

print("Alternately, pre-filter the table for males before loading over JDBC.")
where <- "(select * from sparkour.people where is_male = 1) as subset"
malesDF <- read.jdbc(url=jdbcUrl, tableName=where)
print(collect(malesDF))

print("Update weights by 2 pounds (results in a new DataFrame with same column names)")
heavyDF <- withColumn(entireDF, "updated_weight_lb", entireDF$weight_lb + 2)
selectDF = select(heavyDF, "id", "name", "is_male", "height_in", "updated_weight_lb")
updatedDF <- withColumnRenamed(selectDF, "updated_weight_lb", "weight_lb")
print(collect(updatedDF))

print("Save the updated data to a new table with JDBC")
where <- "sparkour.updated_people"
write.jdbc(updatedDF, jdbcUrl, tableName=where)

print("Load the new table into a new DataFrame to confirm that it was saved successfully.")
retrievedDF <- read.jdbc(url=jdbcUrl, tableName=where)
print(collect(retrievedDF))

sparkR.stop()
