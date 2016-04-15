/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package buri.sparkour;

import java.util.List;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.broadcast.Broadcast;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql.types.StructType;

/**
 * Uses a broadcast variable to generate summary information
 * about a list of store locations.
 */
public final class JBroadcastVariables {

	public static void main(String[] args) throws Exception {
		SparkConf sparkConf = new SparkConf().setAppName("JBroadcastVariables");
		JavaSparkContext sc = new JavaSparkContext(sparkConf);
		SQLContext sqlContext = new SQLContext(sc);

		// Register state data and schema as broadcast variables
                DataFrame localDF = sqlContext.read().json("us_states.json");
		Broadcast<List<Row>> broadcastStateData = sc.broadcast(localDF.collectAsList());
                Broadcast<StructType> broadcastSchema = sc.broadcast(localDF.schema());

		// Create a DataFrame based on the store locations.
		DataFrame storesDF = sqlContext.read().json("store_locations.json");

		// Create a DataFrame of US state data with the broadcast variables.
		DataFrame stateDF = sqlContext.createDataFrame(broadcastStateData.value(), broadcastSchema.value());

		// Join the DataFrames to get an aggregate count of stores in each US Region
		System.out.println("How many stores are in each US region?");
		DataFrame joinedDF = storesDF.join(stateDF, "state").groupBy("census_region").count();
		joinedDF.show();

		sc.stop();
	}
}
