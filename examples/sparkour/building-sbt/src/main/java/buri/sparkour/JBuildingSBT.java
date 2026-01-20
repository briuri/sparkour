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
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.SparkSession;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

/**
 * A simple Java application with an external dependency to
 * demonstrate building and submitting as well as creating an
 * assembly JAR.
 */
public final class JBuildingSBT {

	public static void main(String[] args) throws Exception {
		SparkSession spark = SparkSession.builder().appName("JBuildingSBT").getOrCreate();
		JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());

		// Create a simple RDD containing 4 numbers.
		List<Integer> numbers = Arrays.asList(1, 2, 3, 4);
		JavaRDD<Integer> numbersListRdd = sc.parallelize(numbers);

		// Convert this RDD into CSV.
		CSVPrinter printer = new CSVPrinter(System.out, CSVFormat.DEFAULT);
		printer.printRecord(numbersListRdd.collect());

		spark.stop();
	}
}
