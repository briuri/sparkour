<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noRMessage" value="<p>Because the low-level Spark Core API was made private in Spark 1.4.0, no RDD-based examples are included in this recipe.</p>" />

<bu:rOverview publishDate="2016-05-01">
	<h3>Synopsis</h3>
	<p>This recipe demonstrates different strategies for defining the schema of a DataFrame built from various data sources (using
	RDD and JSON as examples). Schemas can be inferred from metadata or the data itself, or programmatically specified in advance
	in your application.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You should have a basic understand of Spark DataFrames, as covered in <bu:rLink id="working-dataframes" />.
			If you're working in Java, you should understand that DataFrames are now represented by a <span class="rCW">Dataset[Row]</span> object.</li>
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>The example code used in this recipe is written for Spark <span class="rPN">2.0.0</span> or higher.
			You may need to make modifications to use it on an older version of Spark.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing DataFrame Schemas</a></li>
		<li><a href="#02">Creating a DataFrame Schema from an RDD</a></li>
		<li><a href="#03">Creating a DataFrame Schema from a JSON File</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Introducing DataFrame Schemas" />

<p>The <span class="rPN">schema</span> of a DataFrame controls the data that can appear in each column of that DataFrame. A schema 
provides informational detail such as the column name, the type of data in that column, and whether null or empty values are allowed
in the column. This information (especially the data types) makes it easier for your Spark application to interact with a DataFrame in
a consistent, repeatable fashion.</p>

<p>The schema for a new DataFrame is created at the same time as the DataFrame itself. Spark has 3 general strategies for creating
the schema:</p>

<ol>
	<li><span class="rPN">Inferred from Metadata</span>: If the data source already has a built-in schema (such as the database schema of a 
		JDBC data source, or the embedded metadata in a Parquet data source), Spark creates the DataFrame schema 
		based upon the built-in schema. JavaBeans and Scala case classes representing rows of the data can also be used as a hint to 
		generate the schema.</li>
	<li><span class="rPN">Inferred from Data</span>: If the data source does not have a built-in schema (such as a JSON file or
		a Python-based RDD containing Row objects), Spark tries to deduce the DataFrame schema based on the input data. This has 
		a performance impact, depending on the number of rows that need to be scanned to infer the schema.</li>
	<li><span class="rPN">Programmatically Specified</span>: The application can also pass in a pre-defined DataFrame schema, skipping 
		the schema inference step completely.</li>
</ol>

<p>The table below shows the different strategies available for various input formats and the supported programming languages. 
Note that RDD strategies are not available in R because RDDs are part of the low-level Spark Core API which is not exposed in 
the SparkR API.</p>

<table>
	<thead>
		<tr>
			<th>Input Format</th><th>Strategy</th>
			<th>Java</th><th>Python</th><th>R</th><th>Scala</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>JDBC</td><td>Inferred from Metadata</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td>
		</tr><tr>
			<td>JDBC</td><td>Inferred from Data</td>
			<td class="center"></td><td class="center"></td><td class="center"></td><td class="center"></td>
		</tr><tr>
			<td>JDBC</td><td>Programmatic</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td>
		</tr><tr>
			<td>JSON</td><td>Inferred from Metadata</td>
			<td class="center"></td><td class="center"></td><td class="center"></td><td class="center"></td>
		</tr><tr class="highlight">
			<td>JSON</td><td>Inferred from Data</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td>
		</tr><tr class="highlight">
			<td>JSON</td><td>Programmatic</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td>
		</tr><tr>
			<td>Parquet</td><td>Inferred from Metadata</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td>
		</tr><tr>
			<td>Parquet</td><td>Inferred from Data</td>
			<td class="center"></td><td class="center"></td><td class="center"></td><td class="center"></td>
		</tr><tr>
			<td>Parquet</td><td>Programmatic</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center">&#10003;</td>
		</tr><tr class="highlight">
			<td>RDD</td><td>Inferred from Metadata</td>
			<td class="center">&#10003;</td><td class="center"></td><td class="center"></td><td class="center">&#10003;</td>
		</tr><tr class="highlight">
			<td>RDD</td><td>Inferred from Data</td>
			<td class="center"></td><td class="center">&#10003;</td><td class="center"></td><td class="center"></td>
		</tr><tr class="highlight">
			<td>RDD</td><td>Programmatic</td>
			<td class="center">&#10003;</td><td class="center">&#10003;</td><td class="center"></td><td class="center">&#10003;</td>
		</tr>	
	</tbody>
</table>

<p>The source code for this recipe covers the strategies in the highlighted table rows.</p>	

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/controlling-schema.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the controlling-schema source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/controlling-schema.zip
		
		# Unzip, creating /opt/sparkour/controlling-schema
		sudo unzip controlling-schema.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. A helper script,
		<span class="rCW">sparkour.sh</span> is included to compile, bundle, and submit applications in all languages.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/controlling-schema
				./sparkour.sh java
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/controlling-schema
				./sparkour.sh python
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/controlling-schema
				./sparkour.sh r
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/controlling-schema
				./sparkour.sh scala
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>To demonstrate RDD strategies, we build up some sample data from raw data types. The sample data consists of
		 notional records from a veterinary clinic's appointment system, and uses several different data types
		 (a string, a number, a boolean, a map, a date, and a list).</li>
		 
	<bu:rTabs>
		<bu:rTab index="1">
			<p>The JavaBean class for our sample data is found in <span class="rCW">Record.java</span>. JavaBeans must
			have get and set methods for each field, and the class must implement the <span class="rCW">Serializable</span>
			interface. The accessor methods are omitted here for brevity's sake.</p>
			<bu:rCode lang="java">
				/**
				 * JavaBean for a veterinary record.
				 */
				public final class Record implements Serializable {
					private String _name;
					private long _numPets;
					private boolean _paidInFull;
					private Map<String, String> _preferences;
					private Date _registeredOn;
					private List<Date> _visits;
				}
			</bu:rCode>
			
			<p>The <span class="rCW">JControllingSchema.java</span> file contains the code
			that builds the sample data.</p>
			<bu:rCode lang="java">	
				/**
				 * Helper method to construct a Date for sample data.
				 */
				private static Date buildDate(int year, int month, int date, int hour, int min) {
					Calendar calendar = Calendar.getInstance();
					calendar.set(year, month, date, hour, min);
					return (new Date(calendar.getTimeInMillis()));
				}
				
				/**
				 * Build and return the sample data.
				 */
				private static List<Record> buildSampleData() {
					List<Record> beanData = new ArrayList<>();
					Record record = new Record(
						"Alex",
						3,
						true,
						new HashMap<String, String>(),
						buildDate(2015, 1, 1, 12, 0),
						new ArrayList<Date>());
					record.getPreferences().put("preferred_vet", "Dr. Smith");
					record.getPreferences().put("preferred_appointment_day", "Monday");
					record.getVisits().add(buildDate(2015, 2, 1, 11, 0));
					record.getVisits().add(buildDate(2015, 2, 2, 10, 45));
					beanData.add(record);
					record = new Record(
						"Beth",
						2,
						false,
						new HashMap<String, String>(),
						buildDate(2013, 1, 1, 12, 0),
						new ArrayList<Date>());
					record.getPreferences().put("preferred_vet", "Dr. Travis");
					record.getVisits().add(buildDate(2015, 1, 15, 12, 15));
					record.getVisits().add(buildDate(2015, 2, 1, 11, 15));
					beanData.add(record);
					record = new Record(
						"Charlie",
						1,
						true,
						new HashMap<String, String>(),
						buildDate(2016, 5, 1, 12, 0),
						new ArrayList<Date>());
					beanData.add(record);
					return (beanData);
				}
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<p>Although it was previously possible to compose your data with a list of raw Python dictionaries,
			this approach has now been deprecated in favour of using a list of 
			<a href="https://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.Row">Row</a>
			objects. Because a Row can contain an arbitrary number of named fields, it should be straightforward
			to convert your Python dictionary into a Row object.</p>
			<bu:rCode lang="python">
				def build_sample_data():
				    """Build and return the sample data."""
				    data = [
				        Row(
				            name="Alex",
				            num_pets=3,
				            paid_in_full=True,
				            preferences={
				                "preferred_vet": "Dr. Smith",
				                "preferred_appointment_day": "Monday"
				            },
				            registered_on=datetime.datetime(2015, 1, 1, 12, 0),
				            visits=[
				                datetime.datetime(2015, 2, 1, 11, 0),
				                datetime.datetime(2015, 2, 2, 10, 45),
				            ],
				        ),
				        Row(
				            name="Beth",
				            num_pets=2,
				            paid_in_full=False,
				            preferences={
				                "preferred_vet": "Dr. Travis",
				            },
				            registered_on=datetime.datetime(2013, 1, 1, 12, 0),
				            visits=[
				                datetime.datetime(2015, 1, 15, 12, 15),
				                datetime.datetime(2015, 2, 1, 11, 15),
				            ],
				        ),
				        Row(
				            name="Charlie",
				            num_pets=1,
				            paid_in_full=True,
				            preferences={},
				            registered_on=datetime.datetime(2016, 5, 1, 12, 0),
				            visits=[],
				        ),
				    ]
				    return data
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
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
				
				/**
				 * Helper method to construct a Date for sample data.
				 */
				def buildDate(year:Int, month:Int, date:Int, hour:Int, min:Int) : Date = {
					val calendar = Calendar.getInstance()
					calendar.set(year, month, date, hour, min)
					new Date(calendar.getTimeInMillis())
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
							buildDate(2015, 1, 1, 12, 0),
							List(
								 buildDate(2015, 2, 1, 11, 0),
								 buildDate(2015, 2, 2, 10, 45)
							) 
						),
						Record(
							"Beth",
							2,
							false,
							Map(
								"preferred_vet" -> "Dr. Travis"
							),
							buildDate(2013, 1, 1, 12, 0),
							List(
								 buildDate(2015, 1, 15, 12, 15),
								 buildDate(2015, 2, 1, 11, 15)
							)
						),
						Record(
							"Charlie",
							1,
							true,
							Map(),
							buildDate(2016, 5, 1, 12, 0),
							List()
						)
					)
					caseData
				}
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>The <span class="rCW">data.json</span> file contains the same sample data, but in JSON format.</li>
		 
	<bu:rCode lang="plain">
		{"name":"Alex","num_pets":3,"paid_in_full":true,"preferences":{"preferred_appointment_day":"Monday","preferred_vet":"Dr. Smith"},"registered_on":"2015-01-01","visits":["2015-02-01 11:00:00.0","2015-02-02 10:45:00.0"]}
		{"name":"Beth","num_pets":2,"paid_in_full":false,"preferences":{"preferred_vet":"Dr. Travis"},"registered_on":"2013-01-01","visits":["2015-01-15 12:15:00.0","2015-02-01 11:15:00.0"]}
		{"name":"Charlie","num_pets":1,"paid_in_full":true,"preferences":{},"registered_on":"2016-05-01","visits":[]}
	</bu:rCode>
	
</ol>

<bu:rSection anchor="02" title="Creating a DataFrame Schema from an RDD" />

<p>The algorithm for creating a schema from an RDD data source varies depending on the programming language that you use.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<ul>
			<li><span class="rPN">Inferred from Metadata</span>: If your input RDD contains instances of JavaBeans, Spark uses 
				the <span class="rK">beanClass</span> as a definition to infer the schema.</li>  
			<li><span class="rPN">Inferred from Data</span>: This strategy is not available in Java.</li>
			<li><span class="rPN">Programmatically Specified</span>: If your input RDD contains 
				<a href="http://spark.apache.org/docs/latest/api/java/index.html#org.apache.spark.sql.Row">Row</a> instances, you
				can specify a <span class="rK">schema</span>.</li>
		</ul>
	</bu:rTab><bu:rTab index="2">
		<ul>
			<li><span class="rPN">Inferred from Metadata</span>: This strategy is not available in Python.</li>  
			<li><span class="rPN">Inferred from Data</span>: Spark examines the raw data to infer a schema. By default,
				a schema is created based upon the first row of the RDD. If there are null values in the first row, the
				first 100 rows are used instead to account for sparse data. You can specify a <span class="rK">samplingRatio</span> (0 < <span class="rV">samplingRatio</span> <= 1.0) 
				to base the inference on a random sampling of rows in the RDD. You can also pass in a list of column names as 
				<span class="rK">schema</span> to help direct the inference steps.</li> 
			<li><span class="rPN">Programmatically Specified</span>: If your input RDD contains 
				<a href="https://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.Row">Row</a> instances, you
				can specify a <span class="rK">schema</span>.</li>
		</ul>
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noRMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<ul>
			<li><span class="rPN">Inferred from Metadata</span>: If your input RDD contains instances of case classes, Spark uses 
				the case class definition to infer the schema.</li>  
			<li><span class="rPN">Inferred from Data</span>: This strategy is not available in Scala.</li>
			<li><span class="rPN">Programmatically Specified</span>: If your input RDD contains 
				<a href="http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.Row">Row</a> instances, you
				can specify a <span class="rK">schema</span>.</li>
		</ul>
	</bu:rTab>
</bu:rTabs>

<ol>
	<li>The first demonstration in the example source code shows how a schema
	can be inferred from the metadata (in Java/Scala) or data (in Python).</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Create an RDD with sample data.
				JavaRDD<Record> beanRDD = sc.parallelize(buildSampleData());
		
				// Create a DataFrame from the RDD, inferring the schema from a bean class.
				System.out.println("RDD: Schema inferred from bean class.");
				Dataset<Row> dataDF = spark.createDataFrame(beanRDD, Record.class);
				dataDF.printSchema();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create an RDD with sample data.
			    dataRDD = sc.parallelize(build_sample_data())
			
			    # Create a DataFrame from the RDD, inferring the schema from the first row.
			    print("RDD: Schema inferred from first row.")
			    dataDF = spark.createDataFrame(dataRDD, samplingRatio=None)
			    dataDF.printSchema()
			
			    # Create a DataFrame from the RDD, inferring the schema from a sampling of rows.
			    print("RDD: Schema inferred from random sample.")
			    dataDF = spark.createDataFrame(dataRDD, samplingRatio=0.6)
			    dataDF.printSchema()		
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Create an RDD with sample data.
				var caseRDD = sc.parallelize(buildSampleData())
		
				// Create a DataFrame from the RDD, inferring the schema from a case class.
				println("RDD: Schema inferred from case class.")
				var dataDF = spark.createDataFrame(caseRDD)
				dataDF.printSchema()			
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>We use <span class="rCW">printSchema()</span> to show the resultant
		schema in each case.</li>
			
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="plain">
				RDD: Schema inferred from bean class.
				root
				 |-- name: string (nullable = true)
				 |-- numPets: long (nullable = false)
				 |-- paidInFull: boolean (nullable = false)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registeredOn: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: date (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="plain">
				RDD: Schema inferred from first row.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: timestamp (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
				
				RDD: Schema inferred from random sample.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: timestamp (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				RDD: Schema inferred from case class.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = false)
				 |-- paid_in_full: boolean (nullable = false)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: date (containsNull = true)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>If we already know the schema we want to use in advance,
		we can define it in our application using the classes from the
		<span class="rCW">org.apache.spark.sql.types</span> package. The
		<span class="rCW">StructType</span> is the schema class, and it 
		contains a <span class="rCW">StructField</span> for each column
		of data. Each <span class="rCW">StructField</span> provides
		the column name, preferred data type, and whether null values
		are allowed. Spark provides built-in support of a variety of
		data types (e.g. String, Binary, Boolean, Date, Timestamp, Decimal, 
		Double, Float, Byte, Integer, Long, Short, Array, and Map).</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				/**
				 * Build and return a schema to use for the sample data.
				 */	
				private static StructType buildSchema() {
					StructType schema = new StructType(
						new StructField[] {
							DataTypes.createStructField("name", DataTypes.StringType, true),
							DataTypes.createStructField("num_pets", DataTypes.IntegerType, true),
							DataTypes.createStructField("paid_in_full", DataTypes.BooleanType, true),
							DataTypes.createStructField("preferences", 
								DataTypes.createMapType(DataTypes.StringType, DataTypes.StringType, true), true),
							DataTypes.createStructField("registered_on", DataTypes.DateType, true),
							DataTypes.createStructField("visits", 
								DataTypes.createArrayType(DataTypes.TimestampType, true), true) });
					return (schema);
				}
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				def build_schema():
				    """Build and return a schema to use for the sample data."""
				    schema = StructType(
				        [
				            StructField("name", StringType(), True),
				            StructField("num_pets", IntegerType(), True),
				            StructField("paid_in_full", BooleanType(), True),
				            StructField("preferences", MapType(StringType(), StringType(), True), True),
				            StructField("registered_on", DateType(), True),
				            StructField("visits", ArrayType(TimestampType(), True), True),
				        ]
				    )
				    return schema
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				schema <- structType(
				    structField("name", "string", TRUE),
				    structField("num_pets", "integer", TRUE),
				    structField("paid_in_full", "boolean", TRUE),
				    structField("preferences", "map<string,string>", TRUE),
				    structField("registered_on", "date", TRUE),
				    structField("visits", "array<timestamp>", TRUE)
				)			
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
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
					schema
				 }
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		
		
	<li>We can now pass this schema in as a parameter.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<p>This operation is intended for a Row-based RDD. Rather
			than build one from scratch, we'll just convert the JavaBean
			RDD we used in the previous demonstration.</p>
			<bu:rCode lang="java">
				// Use the DataFrame to generate an RDD of Rows for the next demonstration
				// instead of manually building it up again from raw data.
				JavaRDD<Row> rowRDD = dataDF.javaRDD();
		
				// Create a DataFrame from the RDD, specifying a schema.
				System.out.println("RDD: Schema programmatically specified.");
				dataDF = spark.createDataFrame(rowRDD, buildSchema());
				dataDF.printSchema();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create a DataFrame from the RDD, specifying a schema.
			    print("RDD: Schema programmatically specified.")
			    dataDF = spark.createDataFrame(dataRDD, schema=build_schema())
			    dataDF.printSchema()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<p>This operation is intended for a Row-based RDD. Rather
			than build one from scratch, we'll just convert the case class
			RDD we used in the previous demonstration.</p>
			<bu:rCode lang="scala">
				// Use the DataFrame to generate an RDD of Rows for the next demonstration
				// instead of manually building it up from raw data.
				val rowRDD = dataDF.rdd
		
				// Create a DataFrame from the RDD, specifying a schema.
				println("RDD: Schema programmatically specified.")
				dataDF = spark.createDataFrame(rowRDD, buildSchema())
				dataDF.printSchema()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>As you can see in the output, the data types we specified were used. 
	For example, Spark cast our <span class="rCW">num_pets</span> field from
	a long to an integer.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="plain">
				RDD: Schema programmatically specified.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="plain">
				RDD: Schema programmatically specified.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				RDD: Schema programmatically specified.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
</ol>

<bu:rSection anchor="03" title="Creating a DataFrame Schema from a JSON File" />

<p>JSON files have no built-in schema, so schema inference is based upon a scan of a sampling of data rows. Given the potential
performance impact of this operation, you should consider programmatically specifying a schema if possible.</p>

<ol>
	<li>No special code is needed to infer a schema from a JSON file. However, you can specify a
	<span class="rK">samplingRatio</span> (0 < <span class="rV">samplingRatio</span> <= 1.0) to
	limit the number of rows sampled. By default, all rows are be sampled (<span class="rV">1.0</span>).</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Create a DataFrame from a JSON source, inferring the schema from all rows.
				System.out.println("JSON: Schema inferred from all rows.");
				dataDF = spark.read().option("samplingRatio", "1.0").json("data.json");
				dataDF.printSchema();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create a DataFrame from a JSON source, inferring the schema from all rows.
			    print("JSON: Schema inferred from all rows.")
			    dataDF = spark.read.option("samplingRatio", 1.0).json("data.json")
			    dataDF.printSchema()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# Create a DataFrame from a JSON source, inferring the schema from all rows.
				print("JSON: Schema inferred from all rows.")
				dataDF <- read.df("data.json", "json", samplingRatio = "1.0")
				printSchema(dataDF)
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Create a DataFrame from a JSON source, inferring the schema from all rows.
				println("JSON: Schema inferred from all rows.")
				dataDF = spark.read.option("samplingRatio", "1.0").json("data.json")
				dataDF.printSchema()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>We use <span class="rCW">printSchema()</span> to show the resultant
		schema in each case.</li>
			
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="plain">
				JSON: Schema inferred from all rows.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: struct (nullable = true)
				 |    |-- preferred_appointment_day: string (nullable = true)
				 |    |-- preferred_vet: string (nullable = true)
				 |-- registered_on: string (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: string (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="plain">				
				JSON: Schema inferred from all rows.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: struct (nullable = true)
				 |    |-- preferred_appointment_day: string (nullable = true)
				 |    |-- preferred_vet: string (nullable = true)
				 |-- registered_on: string (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: string (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">				
				[1] "JSON: Schema inferred from all rows."
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: struct (nullable = true)
				 |    |-- preferred_appointment_day: string (nullable = true)
				 |    |-- preferred_vet: string (nullable = true)
				 |-- registered_on: string (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: string (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				JSON: Schema inferred from all rows.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: long (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: struct (nullable = true)
				 |    |-- preferred_appointment_day: string (nullable = true)
				 |    |-- preferred_vet: string (nullable = true)
				 |-- registered_on: string (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: string (containsNull = true)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>To avoid the inference step completely, we can specify a schema. The code pattern you see below can easily
		be applied to any input format supported within a DataFrameReader (e.g. JDBC and Parquet).</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Create a DataFrame from a JSON source, specifying a schema.
				System.out.println("JSON: Schema programmatically specified.");
				dataDF = spark.read().schema(buildSchema()).json("data.json");
				dataDF.printSchema();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create a DataFrame from a JSON source, specifying a schema.
			    print("JSON: Schema programmatically specified.")
			    dataDF = spark.read.json("data.json", schema=build_schema())
			    dataDF.printSchema()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# Create a DataFrame from a JSON source, specifying a schema.
				print("JSON: Schema programmatically specified.")
				schema <- structType(
				    structField("name", "string", TRUE),
				    structField("num_pets", "integer", TRUE),
				    structField("paid_in_full", "boolean", TRUE),
				    structField("preferences", "map<string,string>", TRUE),
				    structField("registered_on", "date", TRUE),
				    structField("visits", "array<timestamp>", TRUE)
				)
				dataDF <- read.df("data.json", "json", schema)
				printSchema(dataDF)
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Create a DataFrame from a JSON source, specifying a schema.
				println("JSON: Schema programmatically specified.")
				dataDF = spark.read.schema(buildSchema()).json("data.json")
				dataDF.printSchema()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>As you can see in the output, the data types we specified were used. 
	For example, Spark cast our <span class="rCW">registered_on</span> field from
	a timestamp to a date.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="plain">
				JSON: Schema programmatically specified.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="plain">				
				JSON: Schema programmatically specified.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">				
				[1] "JSON: Schema programmatically specified."
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				JSON: Schema programmatically specified.
				root
				 |-- name: string (nullable = true)
				 |-- num_pets: integer (nullable = true)
				 |-- paid_in_full: boolean (nullable = true)
				 |-- preferences: map (nullable = true)
				 |    |-- key: string
				 |    |-- value: string (valueContainsNull = true)
				 |-- registered_on: date (nullable = true)
				 |-- visits: array (nullable = true)
				 |    |-- element: timestamp (containsNull = true)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

</ol>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/sql-programming-guide.html#inferring-the-schema-using-reflection">Inferring the Schema Using Reflection</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/sql-programming-guide.html#programmatically-specifying-the-schema">Programmatically Specifying the Schema</a> in the Spark Programming Guide</li>
		<li><a href="https://docs.oracle.com/javase/tutorial/javabeans/">Trail: JavaBeans</a> in the Java Documentation</li>
		<li><a href="http://docs.scala-lang.org/tutorials/tour/case-classes.html">Case Classes</a> in the Scala Documentation</li> 
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>