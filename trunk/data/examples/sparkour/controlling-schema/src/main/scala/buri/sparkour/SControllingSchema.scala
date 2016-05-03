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
import org.apache.spark.sql.types.{ArrayType, BooleanType, DateType, IntegerType, MapType, StringType, TimestampType, StructField, StructType}

import java.util.Calendar
import java.sql.Date

/**
 * Demonstrates strategies for controlling the schema of a
 * DataFrame built from a JSON or RDD data source.
 */
object SControllingSchema {
	
	/**
	 * Case class used to define RDD.
	 */
	case class Record(
		name: String,
		num_pets: Long,
		paid_in_full: Boolean,
		preferences: Map[String, String],
		registered_on: Date,
		visits: List[Date]
	)
	
	def main(args: Array[String]) {
		val sparkConf = new SparkConf().setAppName("SControllingSchema")
		val sc = new SparkContext(sparkConf)
		val sqlContext = new SQLContext(sc)

		// Create an RDD with sample data.
		var caseRDD = sc.parallelize(buildSampleData())

		// Create a DataFrame from the RDD, inferring the schema from a case class.
		println("RDD: Schema inferred from case class.")
		var dataDF = sqlContext.createDataFrame(caseRDD)
		dataDF.printSchema()

		// Use the DataFrame to generate an RDD of Rows for the next demonstration
		// instead of manually building it up from raw data.
		val rowRDD = dataDF.rdd

		// Create a DataFrame from the RDD, specifying a schema.
		println("RDD: Schema programmatically specified.")
		dataDF = sqlContext.createDataFrame(rowRDD, buildSchema())
		dataDF.printSchema()

		// Create a DataFrame from a JSON source, inferring the schema from all rows.
		println("JSON: Schema inferred from all rows.")
		dataDF = sqlContext.read.json("data.json")
		dataDF.printSchema()

		// Create a DataFrame from a JSON source, specifying a schema.
		println("JSON: Schema programmatically specified.")
		dataDF = sqlContext.read.schema(buildSchema()).json("data.json")
		dataDF.printSchema()

		sc.stop()
	}

	/**
	 * Helper method to construct a Date for sample data.
	 */
	def buildDate(year:Int, month:Int, date:Int, hour:Int, min:Int) : Date = {
		val calendar = Calendar.getInstance()
		calendar.set(year, month, date, hour, min)
		return new Date(calendar.getTimeInMillis())
	}
	
	/**
 	* Build and return the sample data.
 	*/
 	def buildSampleData() : List[Record] = {
		val caseData = List(
			Record(
				"Alex",
				3,
				true,
				Map(
					"preferred_vet" -> "Dr. Smith",
					"preferred_appointment_day" -> "Monday"
				),
				buildDate(2015, 01, 01, 12, 00),
				List(
					 buildDate(2015, 02, 01, 11, 00),
					 buildDate(2015, 02, 02, 10, 45)
				) 
			),
			Record(
				"Beth",
				2,
				false,
				Map(
					"preferred_vet" -> "Dr. Travis"
				),
				buildDate(2013, 01, 01, 12, 00),
				List(
					 buildDate(2015, 01, 15, 12, 15),
					 buildDate(2015, 02, 01, 11, 15)
				)
			),
			Record(
				"Charlie",
				1,
				true,
				Map(),
				buildDate(2016, 05, 01, 12, 00),
				List()
			)
		)
		return caseData
	}
	
	/**
	 * Build and return a schema to use for the sample data.
	 */	
	 def buildSchema() : StructType = {
		val schema = StructType(
			Array(
				StructField("name", StringType, true), 
				StructField("num_pets", IntegerType, true),
				StructField("paid_in_full", BooleanType, true),
				StructField("preferences", MapType(StringType, StringType, true), true),
				StructField("registered_on", DateType, true),
				StructField("visits", ArrayType(TimestampType, true), true)
			)
		)
		return schema
	 }
}
// scalastyle:on println