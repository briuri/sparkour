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

import java.io.{File, FileInputStream};
import java.util.Properties;

/**
 * Loads a DataFrame from a relational database table over JDBC,
 * manipulates the data, and saves the results back to a table.
 */
object SUsingJDBC {
	def main(args: Array[String]) {
		val sparkConf = new SparkConf().setAppName("SUsingJDBC")
		val sc = new SparkContext(sparkConf)

		val sqlContext = new SQLContext(sc)
		
		// Load properties from file
		val dbProperties = new Properties
		dbProperties.load(new FileInputStream(new File("db-properties.flat")));
		val jdbcUrl = dbProperties.getProperty("jdbcUrl")
		
		println("A DataFrame loaded from the entire contents of a table over JDBC.")
		var where = "sparkour.people"
		val entireDF = sqlContext.read.jdbc(jdbcUrl, where, dbProperties)
		entireDF.printSchema()
		entireDF.show()
		
		println("Filtering the table to just show the males.")
		entireDF.filter("is_male = 1").show()
		
		println("Alternately, pre-filter the table for males before loading over JDBC.")
		where = "(select * from sparkour.people where is_male = 1) as subset"
		val malesDF = sqlContext.read.jdbc(jdbcUrl, where, dbProperties)
		malesDF.show()
		
		println("Use groupBy to show counts of males and females.")
		entireDF.groupBy("is_male").count().show()
		
		println("Update weights by 2 pounds (results in a new DataFrame with same column names)")
		val heavyDF = entireDF.withColumn("updated_weight_lb", entireDF("weight_lb") + 2)
		val updatedDF = heavyDF.select("id", "name", "is_male", "height_in", "updated_weight_lb")
			.withColumnRenamed("updated_weight_lb", "weight_lb")
		updatedDF.show()
		
		println("Save the updated data to a new table with JDBC")
		where = "sparkour.updated_people"
		updatedDF.write.mode("error").jdbc(jdbcUrl, where, dbProperties)
		
		println("Load the new table into a new DataFrame to confirm that it was saved successfully.")
		val retrievedDF = sqlContext.read.jdbc(jdbcUrl, where, dbProperties)
		retrievedDF.show()

		sc.stop()
	}
}
// scalastyle:on println
