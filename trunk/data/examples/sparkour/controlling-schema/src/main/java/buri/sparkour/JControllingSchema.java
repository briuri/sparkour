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

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.StructType;

import java.sql.Date;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;

/**
 * Demonstrates strategies for controlling the schema of a
 * DataFrame built from a JSON or RDD data source.
 */
public final class JControllingSchema {

        /**
         * Helper method to construct a Date for sample data.
         */
        public static Date buildDate(int year, int month, int date, int hour, int min) {
            Calendar calendar = Calendar.getInstance();
            calendar.set(year, month, date, hour, min);
            return (new Date(calendar.getTimeInMillis()));
        }

	public static void main(String[] args) throws Exception {
		SparkConf sparkConf = new SparkConf().setAppName("JControllingSchema");
		JavaSparkContext sc = new JavaSparkContext(sparkConf);
                SQLContext sqlContext = new SQLContext(sc);

                // Define raw data for an RDD, consisting of 3 rows of veterinary records
                List<Record> beanData = new ArrayList<>();
                Record record = new Record(
                    "Alex",
                    3,
                    true,
                    new HashMap<String, String>(),
                    buildDate(2015, 01, 01, 12, 00),
                    new ArrayList<Date>()
                );
                record.getPreferences().put("preferred_vet", "Dr. Smith");
                record.getPreferences().put("preferred_appointment_day", "Monday");
                record.getVisits().add(buildDate(2015, 02, 01, 11, 00));
                record.getVisits().add(buildDate(2015, 02, 02, 10, 45));
                beanData.add(record);
                record = new Record(
                    "Beth",
                    2,
                    false,
                    new HashMap<String, String>(),
                    buildDate(2013, 01, 01, 12, 00),
                    new ArrayList<Date>()
                );
                record.getPreferences().put("preferred_vet", "Dr. Travis");
                record.getVisits().add(buildDate(2015, 01, 15, 12, 15));
                record.getVisits().add(buildDate(2015, 02, 01, 11, 15));
                beanData.add(record);
                record = new Record(
                    "Charlie",
                    1,
                    true,
                    new HashMap<String, String>(),
                    buildDate(2016, 05, 01, 12, 00),
                    new ArrayList<Date>()
                );
                beanData.add(record);
                JavaRDD<Record> beanRDD = sc.parallelize(beanData);

                // Create a DataFrame from the RDD, inferring the schema from a case class.
                System.out.println("RDD: Schema inferred from bean class.");
                DataFrame dataDF = sqlContext.createDataFrame(beanRDD, Record.class);
                dataDF.printSchema();

                // Use the DataFrame to generate an RDD of Rows for the next demonstration
                // instead of manually building it up from raw data.
                JavaRDD<Row> rowRDD = dataDF.javaRDD();

                // Create a DataFrame from the RDD, specifying a schema.
                System.out.println("RDD: Schema programmatically specified.");
                StructType schema = new StructType(
                    new StructField[] {
                        DataTypes.createStructField("name", DataTypes.StringType, true),
                        DataTypes.createStructField("num_pets", DataTypes.IntegerType, true),
                        DataTypes.createStructField("paid_in_full", DataTypes.BooleanType, true),
                        DataTypes.createStructField("preferences", 
                            DataTypes.createMapType(DataTypes.StringType, DataTypes.StringType, true),
                            true),
                        DataTypes.createStructField("registered_on", DataTypes.DateType, true),
                        DataTypes.createStructField("visits",
                            DataTypes.createArrayType(DataTypes.TimestampType, true),
                            true)
                    }
                );
                dataDF = sqlContext.createDataFrame(rowRDD, schema);
                dataDF.printSchema();

                // Create a DataFrame from a JSON source, inferring the schema from all rows.
                System.out.println("JSON: Schema inferred from all rows.");
                dataDF = sqlContext.read().json("data.json");
                dataDF.printSchema();

                // Create a DataFrame from a JSON source, specifying a schema.
                System.out.println("JSON: Schema programmatically specified.");
                dataDF = sqlContext.read().schema(schema).json("data.json");
                dataDF.printSchema();

                               //

		sc.stop();
	}
}
