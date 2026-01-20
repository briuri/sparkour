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

# Demonstrates strategies for controlling the schema of a
# DataFrame built from a JSON data source.

library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
sparkR.session()

# Demonstrations using RDDs cannot be done with SparkR.

# Create a DataFrame from a JSON source, inferring the schema from all rows.
print("JSON: Schema inferred from all rows.")
dataDF <- read.df("data.json", "json", samplingRatio = "1.0")
printSchema(dataDF)

# Create a DataFrame from a JSON source, specifying a schema.
print("JSON: Schema programmatically specified.")
schema <- structType(
    structField("name", "string", TRUE),
    structField("num_pets", "integer", TRUE),
    structField("paid_in_full", "boolean", TRUE),
    structField("preferences", "map<string,string>", TRUE),
    structField("registered_on", "date", TRUE),
    structField("visits", "array<timestamp>", TRUE)
)
dataDF <- read.df("data.json", "json", schema)
printSchema(dataDF)

sparkR.stop()
