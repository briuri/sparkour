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

import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.sql.SparkSession;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Performs a variety of RDD manipulations to show off the data structure.
 */
public final class JWorkingRDDs {

	public static void main(String[] args) throws Exception {
		SparkSession spark = SparkSession.builder().appName("JWorkingRDDs").getOrCreate();

		// Create an array of 1000 random numbers between 0 and 50.
		List<Integer> numbers = new ArrayList<>();
		for (int i = 0; i < 1000; i++) {
			numbers.add(ThreadLocalRandom.current().nextInt(0, 51));
		}

		// Create an RDD from the numbers array
		JavaRDD<Integer> numbersListRdd = spark.sparkContext().parallelize(numbers);

		// Create an RDD from a similar array on the local filesystem
		JavaRDD<String> numbersFilesRdd = spark.sparkContext().textFile("random_numbers.txt");

		// 1000 Chicago residents: How many books do you own?
		JavaRDD<Integer> chicagoRdd = numbersListRdd;

		// 1000 Houston residents: How many books do you own?
		// Must convert from string data to ints first
		JavaRDD<Integer> houstonRdd = numbersFilesRdd.flatMap(x -> Arrays.asList(x.split(" ")))
													 .map(x -> Integer.valueOf(x));
		
		// How many have more than 30 in Chicago?
		Long moreThanThirty = chicagoRdd.filter(x -> x > 30).count();
		System.out.println(String.format("%s Chicago residents have more than 30 books.", moreThanThirty));

		// What's the most number of books in either city?
		Integer mostBooks = chicagoRdd.union(houstonRdd).reduce((x, y) -> Math.max(x, y));
		System.out.println(String.format("%s is the most number of books owned in either city.", mostBooks));

		// What's the total number of books in both cities?
		Integer totalBooks = chicagoRdd.union(houstonRdd).reduce((x, y) -> x + y);
		System.out.println(String.format("%s books in both cities.", totalBooks));

		spark.stop();
	}
}
