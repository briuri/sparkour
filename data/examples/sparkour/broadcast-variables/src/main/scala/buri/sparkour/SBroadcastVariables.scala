/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package buri.sparkour

import org.apache.spark.sql.SparkSession

/**
 * Uses a broadcast variable to generate summary information
 * about a list of store locations.
 */
object SBroadcastVariables {
	def main(args: Array[String]) {
		val spark = SparkSession.builder.appName("SBroadcastVariables").getOrCreate()

		// Register state data and schema as broadcast variables
		val localDF = spark.read.json("us_states.json")
		val broadcastStateData = spark.sparkContext.broadcast(localDF.collectAsList())
		val broadcastSchema = spark.sparkContext.broadcast(localDF.schema)

		// Create a DataFrame based on the store locations.
		val storesDF = spark.read.json("store_locations.json")

		// Create a DataFrame of US state data with the broadcast variables.
		val stateDF = spark.createDataFrame(broadcastStateData.value, broadcastSchema.value)

		// Join the DataFrames to get an aggregate count of stores in each US Region
		println("How many stores are in each US region?")
		val joinedDF = storesDF.join(stateDF, "state").groupBy("census_region").count()
		joinedDF.show()

		spark.stop()
	}
}
// scalastyle:on println
