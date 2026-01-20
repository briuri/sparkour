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

import org.apache.commons.csv.{CSVFormat, CSVPrinter}

/**
 * A simple Scala application with an external dependency to
 * demonstrate building and submitting as well as creating an
 * assembly JAR.
 */
object SBuildingMaven {
	def main(args: Array[String]) {
		val spark = SparkSession.builder.appName("SBuildingMaven").getOrCreate()

		// Create a simple RDD containing 4 numbers.
		val numbers = Array(1, 2, 3, 4)
		val numbersListRdd = spark.sparkContext.parallelize(numbers)

		// Convert this RDD into CSV (using Java CSV Commons library).
		val printer = new CSVPrinter(Console.out, CSVFormat.DEFAULT)
		val javaArray: Array[java.lang.Integer] = numbersListRdd.collect() map java.lang.Integer.valueOf
		printer.printRecords(javaArray)

		spark.stop()
	}
}
// scalastyle:on println
