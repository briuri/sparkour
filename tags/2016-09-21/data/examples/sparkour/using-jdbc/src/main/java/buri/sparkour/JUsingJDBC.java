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

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

/**
 * Loads a DataFrame from a relational database table over JDBC,
 * manipulates the data, and saves the results back to a table.
 */
public final class JUsingJDBC {

	public static void main(String[] args) throws Exception {
		SparkSession spark = SparkSession.builder().appName("JUsingJDBC").getOrCreate();

		// Load properties from file
		Properties dbProperties = new Properties();
		dbProperties.load(new FileInputStream(new File("db-properties.flat")));
		String jdbcUrl = dbProperties.getProperty("jdbcUrl");

		System.out.println("A DataFrame loaded from the entire contents of a table over JDBC.");
		String where = "sparkour.people";
		Dataset<Row> entireDF = spark.read().jdbc(jdbcUrl, where, dbProperties);
		entireDF.printSchema();
		entireDF.show();

		System.out.println("Filtering the table to just show the males.");
		entireDF.filter("is_male = 1").show();

		System.out.println("Alternately, pre-filter the table for males before loading over JDBC.");
		where = "(select * from sparkour.people where is_male = 1) as subset";
		Dataset<Row> malesDF = spark.read().jdbc(jdbcUrl, where, dbProperties);
		malesDF.show();

		System.out.println("Update weights by 2 pounds (results in a new DataFrame with same column names)");
		Dataset<Row> heavyDF = entireDF.withColumn("updated_weight_lb", entireDF.col("weight_lb").plus(2));
		Dataset<Row> updatedDF = heavyDF.select("id", "name", "is_male", "height_in", "updated_weight_lb")
			.withColumnRenamed("updated_weight_lb", "weight_lb");
		updatedDF.show();

		System.out.println("Save the updated data to a new table with JDBC");
		where = "sparkour.updated_people";
		updatedDF.write().mode("error").jdbc(jdbcUrl, where, dbProperties);

		System.out.println("Load the new table into a new DataFrame to confirm that it was saved successfully.");
		Dataset<Row> retrievedDF = spark.read().jdbc(jdbcUrl, where, dbProperties);
		retrievedDF.show();

		spark.stop();
	}
}
