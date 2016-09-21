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

import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.util.LongAccumulator

/**
 * Uses accumulators to provide statistics on potentially incorrect data.
 */
object SAggregatingAccumulators {

	def main(args: Array[String]) {
		val spark = SparkSession.builder.appName("SAggregatingAccumulators").getOrCreate()

		// Create an accumulator to count how many rows might be inaccurate.
		val heightCount = spark.sparkContext.longAccumulator

		// Create an accumulator to store all questionable values.
                val heightValues = new StringAccumulator()
                spark.sparkContext.register(heightValues)

		// A function that checks for questionable values
		def validate(row: Row) = {
			val height = row.getLong(row.fieldIndex("height"))
			if (height < 15 || height > 84) {
				heightCount.add(1)
				heightValues.add(height.toString)
			}
		}

		// Create a DataFrame from a file of names and heights in inches.
		val heightDF = spark.read.json("heights.json")

		// Validate the data with the function.
		heightDF.foreach(validate(_))

		// Show how many questionable values were found and what they were.
		println(s"${heightCount.value} rows had questionable values.")
		println(s"Questionable values: ${heightValues.value}")

		spark.stop()
	}
}
// scalastyle:on println
