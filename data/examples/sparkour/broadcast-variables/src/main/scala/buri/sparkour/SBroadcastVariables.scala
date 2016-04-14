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

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.types.{StringType, StructType, StructField}

/**
 * Uses a broadcast variable to generate summary information
 * about a list of store locations.
 */
object SBroadcastVariables {
	def main(args: Array[String]) {
		val sparkConf = new SparkConf().setAppName("SBroadcastVariables")
		val sc = new SparkContext(sparkConf)
                val sqlContext = new SQLContext(sc)

                // Register state data as a broadcast variable
                val broadcastStateData = sc.broadcast(sqlContext.read.json("us_states.json").collectAsList())

                // Create a DataFrame based on the store locations.
                val storesDF = sqlContext.read.json("store_locations.json")

                // Create a DataFrame of US state data with the broadcast variable.
                val schema = StructType(
                    Array(
                        StructField("census_division", StringType, false),
                        StructField("census_region", StringType, false),
                        StructField("name", StringType, false),
                        StructField("state", StringType, false)
                    )
                )
                val stateDF = sqlContext.createDataFrame(broadcastStateData.value, schema)

                // Join the DataFrames to get an aggregate count of stores in each US Region
                println("How many stores are in each US region?")
                val joinedDF = storesDF.join(stateDF, "state").groupBy("census_region").count()
                joinedDF.show()

		sc.stop()
	}
}
// scalastyle:on println
