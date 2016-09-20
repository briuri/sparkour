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

import org.apache.spark.Accumulator;
import org.apache.spark.api.java.function.VoidFunction;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SQLContext;

/**
 * Uses accumulators to provide statistics on potentially incorrect data.
 */
public final class JAggregatingAccumulators {

	public static void main(String[] args) throws Exception {
		SparkSession spark = SparkSession.builder().appName("JAggregatingAccumulators").getOrCreate();

		// Create an accumulator to count how many rows might be inaccurate.
		Accumulator<Integer> heightCount = spark.accumulator(0);

		// Create an accumulator to store all questionable values.
		Accumulator<String> heightValues = spark.accumulator("", new StringAccumulatorParam());

		// A function that checks for questionable values
		VoidFunction<Row> validate = new VoidFunction<Row>() {
			public void call(Row row) {
				Long height = row.getLong(row.fieldIndex("height"));
				if (height < 15 || height > 84) {
					heightCount.add(1);
					heightValues.add(String.valueOf(height));
				}
			}
		};

		// Create a DataFrame from a file of names and heights in inches.
		DataFrame heightDF = sqlContext.read().json("heights.json");

		// Validate the data with the function.
		heightDF.javaRDD().foreach(validate);

		// Show how many questionable values were found and what they were.
		System.out.println(String.format("%d rows had questionable values.", heightCount.value()));
		System.out.println(String.format("Questionable values: %s", heightValues.value()));

		spark.stop();
	}
}
