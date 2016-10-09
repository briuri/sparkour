<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-03-24">
	<h3>Synopsis</h3>
	<p>This recipe shows how Spark DataFrames can be read from or written to relational database tables with 
	Java Database Connectivity (JDBC).</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You should have a basic understand of Spark DataFrames, as covered in <bu:rLink id="working-dataframes" />.
			If you're working in Java, you should understand that DataFrames are now represented by a <span class="rCW">Dataset[Row]</span> object.</li> 
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
		<li>You need administrative access to a relational database (such as mySQL, PostgreSQL, or Oracle).</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>The example code used in this recipe is written for Spark <span class="rPN">2.0.x</span> or higher.
			You may need to make modifications to use it on an older version of Spark.</li>
		<li>The examples in this recipe employ the mySQL Connector/J <span class="rPN">5.1.38</span> library to communicate with a mySQL database,
			but any relational database with a JVM-compatible connector library should suffice.</li> 
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Preparing the Database</a></li>
		<li><a href="#02">Reading from a Table</a></li>
		<li><a href="#03">Writing to a Table</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Preparing the Database" />

<p>The DataFrames API provides a tabular view of data that allows you to use common relational database patterns  
at a higher abstraction than the low-level Spark Core API. As a column-based abstraction, it is only fitting that a
DataFrame can be read from or written to a real relational database table. Spark provides built-in methods to simplify
this conversion over a JDBC connection.</p>

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/using-jdbc.zip">Download</a> and unzip the example source code for this recipe. 
		This ZIP archive contains source code in all supported languages.
		Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the using-jdbc source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/using-jdbc.zip
		
		# Unzip, creating /opt/sparkour/using-jdbc
		sudo unzip using-jdbc.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name.
		There is also a <span class="rCW">setup-mysql.sql</span> script that creates a test database, a test user, and a test table
		for use in this recipe. You will need to insert the IP address range of the Spark cluster that will be executing your application
		(as <span class="rK">&lt;subnetOfSparkCluster&gt;</span> on line 9 and 12). If you just plan on running in Local mode, your local IP address will suffice.
		You'll also need to create a password that the cluster can use to connect to the database (as <span class="rK">&lt;password&gt;</span> on line 9).
		
		
	<bu:rCode lang="sql">
		-- This SQL script should be run as a database user with permission to 
		-- create new databases, tables, and users.
		
		-- Create test database
		create database sparkour;
		
		-- Create a user representing your Spark cluster
		-- Use % as a wildcard when specifying an IP subnet, such as '123.456.78.%'
		create user 'sparkour'@'<subnetOfSparkCluster>' identified by '<password>';
		
		-- Add privileges for the Spark cluster
		grant create, delete, drop, insert, select, update on sparkour.* to 'sparkour'@'<subnetOfSparkCluster>';
		flush privileges;
		
		-- Create a test table of physical characteristics.
		use sparkour;
		create table people (
		  id int(10) not null auto_increment,
		  name char(50) not null,
		  is_male tinyint(1) not null,
		  height_in int(4) not null,
		  weight_lb int(4) not null,
		  primary key (id),
		  key (id)
		);
		
		-- Create sample data to load into a DataFrame
		insert into people values (null, 'Alice', 0, 60, 125);
		insert into people values (null, 'Brian', 1, 64, 131);
		insert into people values (null, 'Charlie', 1, 74, 183);
		insert into people values (null, 'Doris', 0, 58, 102);
		insert into people values (null, 'Ellen', 0, 66, 140);
		insert into people values (null, 'Frank', 1, 66, 151);
		insert into people values (null, 'Gerard', 1, 68, 190);
		insert into people values (null, 'Harold', 1, 61, 128);
	</bu:rCode>
	
	<li>Login to the command line interface for your relational database and execute this script. If you
		are using a different relational database, this script may require some modifications. Consult your 
		database documentation to translate the mySQL commands into a different SQL dialect as needed.</li>
	
	<li>There are two property files that you need to edit to include the database URL and password for your environment.
		<span class="rCW">db-properties.flat</span> is used by the Java and Scala examples, while <span class="rCW">db-properties.json</span>
		is used by the Python and R examples. Edit these files to point to your database.</li>
	
	<bu:rCode lang="plain">
		jdbcUrl=jdbc:mysql://<hostname>/sparkour
		user=sparkour
		password=<password>
	</bu:rCode>
	
	<bu:rCode lang="plain">
		{
		    "jdbcUrl": "jdbc:mysql://<hostname>/sparkour",
		    "user": "sparkour",
		    "password": "<password>"
		}
	</bu:rCode>
	
	<li>Your database documentation should describe the proper format of the URL. Here are some examples for common databases:</li>
	
	<bu:rCode lang="plain">
		jdbc:mysql://<hostname>:3306/sparkour
		jdbc:postgresql://<hostname>:5432/sparkour
		jdbc:sqlite:sparkour.db
		jdbc:oracle:thin:@<hostname>:1521:sparkour
	</bu:rCode>
	
	<li>Next, you should download a copy of the JDBC connector library used by your database to the <span class="rCW">lib</span>
		directory. Here are some examples for common databases:</li>
	
	<bu:rCode lang="plain">	
		wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
		wget http://central.maven.org/maven2/postgresql/postgresql/9.1-901-1.jdbc4/postgresql-9.1-901-1.jdbc4.jar
		wget http://central.maven.org/maven2/org/xerial/sqlite-jdbc/3.8.11.2/sqlite-jdbc-3.8.11.2.jar
		# Oracle now requires you to login to their portal to download the thin client JAR file.
	</bu:rCode>
	
	<li>If you plan to run these applications on a Spark cluster (as opposed to Local mode), you will need to download the JDBC
		connector library to each node in your cluster as well. You will also need to edit your <span class="rCW">$SPARK_HOME/conf/spark-defaults.conf</span>
		file to include the connector library in the necessary classpaths. For added security, the JDBC library must be loaded when the 
		cluster	is first started, so simply passing it in as an application dependency with <span class="rCW">--jars</span> 
		is insufficient.</li>
		
	<bu:rCode lang="plain">
		spark.driver.extraClassPath /someDirectoryOnClusterNode/mysql-connector-java-5.1.38.jar
		spark.executor.extraClassPath /someDirectoryOnClusterNode/mysql-connector-java-5.1.38.jar
	</bu:rCode>
	
	<li>You are now ready to run the example applications. A helper script, <span class="rCW">sparkour.sh</span> is 
	included to compile, bundle, and submit applications in all languages. If you want to run the application in Local mode,
	you will need to pass the JDBC library in with the <span class="rK">--driver-class-path</span> parameter. If you are
	submitting the application to a cluster with a <span class="rCW">spark-defaults.conf</span> file configured as shown in the
	previous step, specifying the <span class="rK">--master</span> is sufficient.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				cd /opt/sparkour/using-jdbc
				
				# Run in Local Mode
				./sparkour.sh java --driver-class-path lib/mysql-connector-java-5.1.38.jar
				
				# Run against a Spark cluster
				./sparkour.sh java --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				cd /opt/sparkour/using-jdbc
				
				# Run in Local Mode
				./sparkour.sh python --driver-class-path lib/mysql-connector-java-5.1.38.jar
				
				# Run against a Spark cluster
				./sparkour.sh python --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				cd /opt/sparkour/using-jdbc
				
				# Run in Local Mode
				./sparkour.sh r --driver-class-path lib/mysql-connector-java-5.1.38.jar
				
				# Run against a Spark cluster
				./sparkour.sh r --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				cd /opt/sparkour/using-jdbc
				
				# Run in Local Mode
				./sparkour.sh scala --driver-class-path lib/mysql-connector-java-5.1.38.jar
				
				# Run against a Spark cluster
				./sparkour.sh scala --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
</ol>

<h3>java.sql.SQLException: No suitable driver found for &lt;jdbcUrl&gt;</h3>

<p>If you encounter this error while running your application, then your JDBC library cannot be found by the node running the application.
If you're running in Local mode, make sure that you have used the <span class="rK">--driver-class-path</span> parameter. If a Spark cluster
is involved, make sure that each cluster member has a copy of library, and that each node of the cluster has been restarted since you
modified the <span class="rCW">spark-defaults.conf</span> file.</p>

<bu:rSection anchor="02" title="Reading from a Table" />

<ol>
	<li>First, we load our database properties from our properties file. As a best practice,
		never hardcode your database password into the source code file -- store the value in
		a separate file that is not version-controlled.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Load properties from file
				Properties dbProperties = new Properties();
				dbProperties.load(new FileInputStream(new File("db-properties.flat")));
				String jdbcUrl = dbProperties.getProperty("jdbcUrl");
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Load properties from file
			    with open('db-properties.json') as propertyFile:
			        properties = json.load(propertyFile)
			    jdbcUrl = properties["jdbcUrl"]
			    dbProperties = {
			        "user" : properties["user"],
			        "password" : properties["password"]
			    }
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# Load properties from file
				properties <- fromJSON(file="db-properties.json")
				jdbcUrl <- paste(properties["jdbcUrl"], "?user=", properties["user"], "&password=", properties["password"], sep="")					
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Load properties from file
				val dbProperties = new Properties
				dbProperties.load(new FileInputStream(new File("db-properties.flat")));
				val jdbcUrl = dbProperties.getProperty("jdbcUrl")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>We use Spark's <span class="rCW"><a href="https://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrameReader">DataFrameReader</a></span>
		to connect to the database and load all of the table data into a <span class="rCW"><a href="https://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrame">DataFrame</a></span>.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("A DataFrame loaded from the entire contents of a table over JDBC.");
				String where = "sparkour.people";
				Dataset<Row> entireDF = spark.read().jdbc(jdbcUrl, where, dbProperties);
				entireDF.printSchema();
				entireDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("A DataFrame loaded from the entire contents of a table over JDBC.")
			    where = "sparkour.people"
			    entireDF = spark.read.jdbc(jdbcUrl, where, properties=dbProperties)
			    entireDF.printSchema()
			    entireDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("A DataFrame loaded from the entire contents of a table over JDBC.")
				where <- "sparkour.people"
				entireDF <- read.jdbc(url=jdbcUrl, tableName=where)
				printSchema(entireDF)
				print(collect(entireDF))					
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("A DataFrame loaded from the entire contents of a table over JDBC.")
				var where = "sparkour.people"
				val entireDF = spark.read.jdbc(jdbcUrl, where, dbProperties)
				entireDF.printSchema()
				entireDF.show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		
		
	<bu:rCode lang="plain">
		A DataFrame loaded from the entire contents of a table over JDBC.
		root
		 |-- id: integer (nullable = false)
		 |-- name: string (nullable = false)
		 |-- is_male: boolean (nullable = false)
		 |-- height_in: integer (nullable = false)
		 |-- weight_lb: integer (nullable = false)
		
		+---+-------+-------+---------+---------+
		| id|   name|is_male|height_in|weight_lb|
		+---+-------+-------+---------+---------+
		|  1|  Alice|  false|       60|      125|
		|  2|  Brian|   true|       64|      131|
		|  3|Charlie|   true|       74|      183|
		|  4|  Doris|  false|       58|      102|
		|  5|  Ellen|  false|       66|      140|
		|  6|  Frank|   true|       66|      151|
		|  7| Gerard|   true|       68|      190|
		|  8| Harold|   true|       61|      128|
		+---+-------+-------+---------+---------+
	</bu:rCode>
	
	<li>Once the <span class="rCW">DataFrame</span> has loaded, it is detached from the underlying
		database table. At this point, you can interact with the <span class="rCW">DataFrame</span>
		normally, without worrying about the original table. Here, we filter the data to only show
		males.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Filtering the table to just show the males.");
				entireDF.filter("is_male = 1").show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Filtering the table to just show the males.")
			    entireDF.filter("is_male = 1").show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Filtering the table to just show the males.")
				print(collect(filter(entireDF, "is_male = 1")))				
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Filtering the table to just show the males.")
				entireDF.filter("is_male = 1").show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		

	<bu:rCode lang="plain">
		Filtering the table to just show the males.
		+---+-------+-------+---------+---------+
		| id|   name|is_male|height_in|weight_lb|
		+---+-------+-------+---------+---------+
		|  2|  Brian|   true|       64|      131|
		|  3|Charlie|   true|       74|      183|
		|  6|  Frank|   true|       66|      151|
		|  7| Gerard|   true|       68|      190|
		|  8| Harold|   true|       61|      128|
		+---+-------+-------+---------+---------+
	</bu:rCode>
	
	<li>Alternately, we could have filtered the data <i>before</i>
		loading it into the <span class="rCW">DataFrame</span>. The
		<span class="rCW">where</span> variable we used to pass in a table
		name could also be an arbitrary SQL subquery. The subquery should
		be enclosed in parentheses and assigned an alias with the <span class="rCW">as</span>
		SQL keyword. Pre-filtering 
		is useful to reduce the Spark cluster resources needed for your
		data processing, especially if you know up front that you don't
		need to use the entire table.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Alternately, pre-filter the table for males before loading over JDBC.");
				where = "(select * from sparkour.people where is_male = 1) as subset";
				Dataset<Row> malesDF = spark.read().jdbc(jdbcUrl, where, dbProperties);
				malesDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Alternately, pre-filter the table for males before loading over JDBC.")
			    where = "(select * from sparkour.people where is_male = 1) as subset"
			    malesDF = spark.read.jdbc(jdbcUrl, where, properties=dbProperties)
			    malesDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Alternately, pre-filter the table for males before loading over JDBC.")
				where <- "(select * from sparkour.people where is_male = 1) as subset"
				malesDF <- read.jdbc(url=jdbcUrl, tableName=where)
				print(collect(malesDF))			
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Alternately, pre-filter the table for males before loading over JDBC.")
				where = "(select * from sparkour.people where is_male = 1) as subset"
				val malesDF = spark.read.jdbc(jdbcUrl, where, dbProperties)
				malesDF.show()				
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		

	<bu:rCode lang="plain">
		Alternately, pre-filter the table for males before loading over JDBC.
		+---+-------+-------+---------+---------+
		| id|   name|is_male|height_in|weight_lb|
		+---+-------+-------+---------+---------+
		|  2|  Brian|   true|       64|      131|
		|  3|Charlie|   true|       74|      183|
		|  6|  Frank|   true|       66|      151|
		|  7| Gerard|   true|       68|      190|
		|  8| Harold|   true|       61|      128|
		+---+-------+-------+---------+---------+
	</bu:rCode>
	
</ol>

<bu:rSection anchor="03" title="Writing to a Table" />

<p>The <span class="rCW"><a href="https://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrame">DataFrame</a></span> class 
exposes a <span class="rCW"><a href="https://spark.apache.org/docs/latest/api/python/pyspark.sql.html#pyspark.sql.DataFrameWriter">DataFrameWriter</a></span>
named <span class="rCW">write</span> which can be used to save a <span class="rCW">DataFrame</span> as a database table (even if the
DataFrame didn't originate from that database). There are four available write modes which can be specified, with 
<span class="rV">error</span> being the default:</p>
<ol>
	<li><span class="rV">append</span>: INSERT this data into an existing table with the same schema as the DataFrame.</li>
	<li><span class="rV">overwrite</span>: DROP the table and then CREATE it using the schema of the DataFrame. Finally, INSERT rows from the DataFrame.</li>
	<li><span class="rV">ignore</span>: Silently do nothing if the table already contains data or if something prevents INSERT from working.</li>	
	<li><span class="rV">error</span>: Throw an exception if the table already contains data.</li>
</ol>
<p>The underlying behavior of the write modes is a bit finicky. You should consider using only <span class="rV">error</span> mode and creating
new copies of existing tables until you are very confident about the expected behavior of the other modes. In particular, it's important to note that
all write operations involve the INSERT SQL statement, so there is no way to use the <span class="rCW">DataFrameWriter</span> to UPDATE existing rows.</p>

<p>To demonstrate writing to a table with JDBC, let's start with our <span class="rCW">people</span> table.
It turns out that the source data was improperly measured, and everyone in the table is actually 2 pounds
heavier than the data suggests. We load the data into a DataFrame, add 2 pounds to every weight
value, and then save the new data into a new database table. Remember that Spark RDDs (the low-level data
structure underneath the DataFrame) are immutable, so these operations will involve making new DataFrames
rather than updating the existing one.</p>

<ol>
	<li>The data transformation is a chain of operators that adds a new column,
		<span class="rK">updated_weight_lb</span>, creates a new DataFrame that includes the new column
		but not the old <span class="rK">weight_lb</span> column, and finally renames the new column with the old name.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Update weights by 2 pounds (results in a new DataFrame with same column names)");
				Dataset<Row> heavyDF = entireDF.withColumn("updated_weight_lb", entireDF.col("weight_lb").plus(2));
				Dataset<Row> updatedDF = heavyDF.select("id", "name", "is_male", "height_in", "updated_weight_lb")
					.withColumnRenamed("updated_weight_lb", "weight_lb");
				updatedDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Update weights by 2 pounds (results in a new DataFrame with same column names)")
			    heavyDF = entireDF.withColumn("updated_weight_lb", entireDF["weight_lb"] + 2)
			    updatedDF = heavyDF.select("id", "name", "is_male", "height_in", "updated_weight_lb") \
			        .withColumnRenamed("updated_weight_lb", "weight_lb")
			    updatedDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Update weights by 2 pounds (results in a new DataFrame with same column names)")
				heavyDF <- withColumn(entireDF, "updated_weight_lb", entireDF$weight_lb + 2)
				selectDF = select(heavyDF, "id", "name", "is_male", "height_in", "updated_weight_lb")
				updatedDF <- withColumnRenamed(selectDF, "updated_weight_lb", "weight_lb")
				print(collect(updatedDF))		
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Update weights by 2 pounds (results in a new DataFrame with same column names)")
				val heavyDF = entireDF.withColumn("updated_weight_lb", entireDF("weight_lb") + 2)
				val updatedDF = heavyDF.select("id", "name", "is_male", "height_in", "updated_weight_lb")
					.withColumnRenamed("updated_weight_lb", "weight_lb")
				updatedDF.show()			
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>				 
	
	<bu:rCode lang="plain">
		Update weights by 2 pounds (results in a new DataFrame with same column names)
		+---+-------+-------+---------+---------+
		| id|   name|is_male|height_in|weight_lb|
		+---+-------+-------+---------+---------+
		|  1|  Alice|  false|       60|      127|
		|  2|  Brian|   true|       64|      133|
		|  3|Charlie|   true|       74|      185|
		|  4|  Doris|  false|       58|      104|
		|  5|  Ellen|  false|       66|      142|
		|  6|  Frank|   true|       66|      153|
		|  7| Gerard|   true|       68|      192|
		|  8| Harold|   true|       61|      130|
		+---+-------+-------+---------+---------+
	</bu:rCode>

	<li>We now create a new table called <span class="rCW">updated_people</span> to save the modified data,
		and then load that table into a new DataFrame to confirm that the new table was created successfully.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Save the updated data to a new table with JDBC");
				where = "sparkour.updated_people";
				updatedDF.write().mode("error").jdbc(jdbcUrl, where, dbProperties);
		
				System.out.println("Load the new table into a new DataFrame to confirm that it was saved successfully.");
				Dataset<Row> retrievedDF = spark.read().jdbc(jdbcUrl, where, dbProperties);
				retrievedDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Save the updated data to a new table with JDBC")
			    where = "sparkour.updated_people"
			    updatedDF.write.jdbc(jdbcUrl, where, properties=dbProperties, mode="error")
			
			    print("Load the new table into a new DataFrame to confirm that it was saved successfully.")
			    retrievedDF = spark.read.jdbc(jdbcUrl, where, properties=dbProperties)
			    retrievedDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Save the updated data to a new table with JDBC")
				where <- "sparkour.updated_people"
				write.jdbc(updatedDF, jdbcUrl, tableName=where)
				
				print("Load the new table into a new DataFrame to confirm that it was saved successfully.")
				retrievedDF <- read.jdbc(url=jdbcUrl, tableName=where)
				print(collect(retrievedDF))		
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
					println("Save the updated data to a new table with JDBC")
					where = "sparkour.updated_people"
					updatedDF.write.mode("error").jdbc(jdbcUrl, where, dbProperties)
					
					println("Load the new table into a new DataFrame to confirm that it was saved successfully.")
					val retrievedDF = spark.read.jdbc(jdbcUrl, where, dbProperties)
					retrievedDF.show()		
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		
	
	<bu:rCode lang="plain">
		Save the updated data to a new table with JDBC INSERT statements
		Load the new table into a new DataFrame to confirm that it was saved successfully.
		+---+-------+-------+---------+---------+
		| id|   name|is_male|height_in|weight_lb|
		+---+-------+-------+---------+---------+
		|  1|  Alice|  false|       60|      127|
		|  2|  Brian|   true|       64|      133|
		|  3|Charlie|   true|       74|      185|
		|  4|  Doris|  false|       58|      104|
		|  5|  Ellen|  false|       66|      142|
		|  6|  Frank|   true|       66|      153|
		|  7| Gerard|   true|       68|      192|
		|  8| Harold|   true|       61|      130|
		+---+-------+-------+---------+---------+
	</bu:rCode>
		
	<li>Because this operation is running in <span class="rCW">error</span> mode,
		the <span class="rCW">updated_people</span> table cannot already exist. You
		will need to drop the table in the database if you want to run the application
		more than once.</li>
	
	<bu:rCode lang="sql">
		DROP TABLE sparkour.updated_people
	</bu:rCode>
</ol>

<h3>org.apache.spark.sql.execution.datasources.jdbc.DefaultSource does not allow create table as select.</h3>

<p>You may encounter this error when trying to write to a JDBC table with R's <span class="rCW">write.df()</span> function
in Spark 1.6 or lower. You will need to upgrade to Spark 2.0.x to write to tables in R.</p> 

<h3>Schema Variations</h3>

<p>If you compare the schemas of the two tables, you'll notice slight differences.</p>

<bu:rCode lang="plain">
	mysql> desc people;
	+-----------+------------+------+-----+---------+----------------+
	| Field     | Type       | Null | Key | Default | Extra          |
	+-----------+------------+------+-----+---------+----------------+
	| id        | int(10)    | NO   | PRI | NULL    | auto_increment |
	| name      | char(50)   | NO   |     | NULL    |                |
	| is_male   | tinyint(1) | NO   |     | NULL    |                |
	| height_in | int(4)     | NO   |     | NULL    |                |
	| weight_lb | int(4)     | NO   |     | NULL    |                |
	+-----------+------------+------+-----+---------+----------------+
	5 rows in set (0.00 sec)
	
	mysql> desc updated_people;
	+-----------+---------+------+-----+---------+-------+
	| Field     | Type    | Null | Key | Default | Extra |
	+-----------+---------+------+-----+---------+-------+
	| id        | int(11) | NO   |     | NULL    |       |
	| name      | text    | NO   |     | NULL    |       |
	| is_male   | bit(1)  | NO   |     | NULL    |       |
	| height_in | int(11) | NO   |     | NULL    |       |
	| weight_lb | int(11) | NO   |     | NULL    |       |
	+-----------+---------+------+-----+---------+-------+
	5 rows in set (0.00 sec)
</bu:rCode>

<p>When a DataFrame is loaded from a table, its schema is inferred from the table's 
schema, which may result in an imperfect match when the DataFrame is written back to the database.
Most noticeable in our example is the loss of the database index sequence, the primary key,
and the changes to the datatypes of each column.</p>

<p>These differences may cause some write modes to fail in unexpected ways. It's best to consider JDBC read/write operations to be one-way operations that should not
use the same database table as both the source and the target, <i>unless</i> the table was originally generated by Spark from the same <span class="rCW">DataFrame</span>.</p>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/sql-programming-guide.html#jdbc-to-other-databases">JDBC to Other Databases</a> in the Spark Programming Guide</li>
		<li><bu:rLink id="working-dataframes" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>