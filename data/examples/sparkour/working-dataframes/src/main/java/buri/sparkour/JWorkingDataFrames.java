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

package buri.sparkour;

import static org.apache.spark.sql.functions.*;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.Column;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.SQLContext;

/**
 * Performs a variety of DataFrames manipulations to show off the data
 * structure.
 */
public final class JWorkingDataFrames {

	public static void main(String[] args) throws Exception {
		SparkConf sparkConf = new SparkConf().setAppName("JWorkingDataFrames");
		JavaSparkContext sc = new JavaSparkContext(sparkConf);

		// Initialize the SQLContext
		SQLContext sqlContext = new SQLContext(sc);

		// Create a DataFrame based on the JSON results.
		DataFrame rawDF = sqlContext.read().json("loudoun_d_primary_results_2016.json");

		// Print the schema
		rawDF.printSchema();

		System.out.println("Who was on the ballet?");
		// Get all distinct candidate names from the DataFrame
		rawDF.select("candidate_name").distinct().show();

		System.out.println("What order were candidates on the ballot?");
		// Get the ballot order and discard the many duplicates (all VA ballots are the same)
		// Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
		DataFrame ballotDF = rawDF.select(rawDF.col("candidate_name"), rawDF.col("candidate_ballot_order"))
			.dropDuplicates().orderBy("candidate_ballot_order").persist();
		ballotDF.show();

		System.out.println("What order were candidates on the ballot (in descriptive terms)?");
		// Load a reference table of friendly names for the ballot orders.
		DataFrame friendlyDF = sqlContext.read().json("friendly_orders.json");
		// Join the tables so the results show descriptive text
		DataFrame joinedDF = ballotDF.join(friendlyDF, "candidate_ballot_order");
		// Hide the numeric column in the output.
		joinedDF.select(joinedDF.col("candidate_name"), joinedDF.col("friendly_name")).show();

		System.out.println("How many votes were cast?");
		// Orginal data is string-based. Create an integer version of the total
		// votes column.
		Column votesColumn = rawDF.col("total_votes").cast("int").alias("total_votes_int");
		// Get the integer-based votes column and sum all values together
		rawDF.select(votesColumn).groupBy().sum("total_votes_int").show();

		System.out.println("How many votes did each candidate get?");
		// Get just the candidate names and votes.
		DataFrame candidateDF = rawDF.select(rawDF.col("candidate_name"), votesColumn);
		// Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
		// Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
		DataFrame groupedDF = candidateDF.groupBy("candidate_name")
			.agg(sum("total_votes_int").alias("sum_column"));
		DataFrame summaryDF = groupedDF.orderBy(groupedDF.col("sum_column").desc()).persist();
		summaryDF.show();

		System.out.println("Which polling station had the highest physical turnout?");
		// All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
		// Spark's cast function converts these to "null".
		Column precinctColumn = rawDF.col("precinct_code").cast("int").alias("precinct_code_int");
		// Get the precinct name, integer-based code, and integer-based votes,
		// then filter on non-null codes.
		DataFrame pollingDF = rawDF.select(rawDF.col("precinct_name"), precinctColumn, votesColumn)
			.filter("precinct_code_int is not null");
		// Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
		// Then, show the max row.
		groupedDF = pollingDF.groupBy("precinct_name").agg(sum("total_votes_int").alias("sum_column"));
		groupedDF.orderBy(groupedDF.col("sum_column").desc()).limit(1).show();

		System.out.println("Saving overall candidate summary as a new JSON dataset.");
		summaryDF.write().mode("overwrite").json("target/json");

		sc.stop();
	}
}
