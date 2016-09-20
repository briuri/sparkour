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

import org.apache.spark.sql.{SparkSession, functions}
/**
 * Performs a variety of DataFrames manipulations using raw SQL and
 * User-Defined Functions (UDFs).
 */
object SUsingSqlUdf {
	def main(args: Array[String]) {
		val spark = SparkSession.builder.appName("SUsingSqlUdf").getOrCreate()
	
		// Create a DataFrame based on the JSON results.
		val rawDF = spark.read.json("loudoun_d_primary_results_2016.json")

		// Register as a SQL-accessible table
		rawDF.createOrReplaceTempView("votes")

		println("Who was on the ballet?")
		// Get all distinct candidate names from the DataFrame
		var query = "SELECT DISTINCT candidate_name FROM votes"
		spark.sql(query).show()
	
		println("What order were candidates on the ballot?")
		// Get the ballot order and discard the many duplicates (all VA ballots are the same)
		// We also register this DataFrame as a table to reuse later.
		query = """SELECT DISTINCT candidate_name, candidate_ballot_order
			FROM votes ORDER BY candidate_ballot_order"""
		val orderDF = spark.sql(query)
		orderDF.createOrReplaceTempView("ordered_candidates")
		orderDF.show()

		println("What order were candidates on the ballot (in descriptive terms)?")
		// Load a reference table of friendly names for the ballot orders.
		val friendlyDF = spark.read.json("friendly_orders.json")
		friendlyDF.createOrReplaceTempView("ballot_order")
		// Join the tables so the results show descriptive text
		query = """SELECT oc.candidate_name, bo.friendly_name
			FROM ordered_candidates oc JOIN ballot_order bo
			ON oc.candidate_ballot_order = bo.candidate_ballot_order"""
		spark.sql(query).show()

		println("How many votes were cast?")
		// Orginal data is string-based. Create a UDF to cast as an integer.
		spark.udf.register("to_int", (x: String) => x.toInt)
		query = "SELECT SUM(to_int(total_votes)) AS sum_total_votes FROM votes"
		spark.sql(query).show()

		println("How many votes did each candidate get?")
		query = """SELECT candidate_name, SUM(to_int(total_votes)) AS sum_total_votes
			FROM votes GROUP BY candidate_name ORDER BY sum_total_votes DESC"""
		spark.sql(query).show()

		println("Which polling station had the highest physical turnout?")
		// All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
		query = """SELECT precinct_name, SUM(to_int(total_votes)) AS sum_total_votes
			FROM votes WHERE precinct_code NOT LIKE '##%'
			GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1"""
		spark.sql(query).show()

		spark.stop()
	}
}
// scalastyle:on println
