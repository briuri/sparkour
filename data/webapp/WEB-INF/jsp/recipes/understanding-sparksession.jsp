<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-09-24">
	<h3>Synopsis</h3>
	<p>This recipe introduces the new <span class="rCW">SparkSession</span> class from Spark 2.0, which provides a unified entry point
		for all of the various Context classes previously found in Spark 1.x. There is no hands-on work involved.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>There are no prerequisites for this recipe.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>The <span class="rCW">SparkSession</span> class was introduced in Spark <span class="rPN">2.0.0</span>.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing SparkSession</a></li>
		<li><a href="#01">Updating Spark 1.x Applications</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Introducing SparkSession" />

<p>The <span class="rCW">SparkSession</span> class is a new feature of Spark 2.0 which streamlines the number of configuration and helper classes 
you need to instantiate before writing Spark applications. <span class="rCW">SparkSession</span> provides a single entry point to perform many
operations that were previously scattered across multiple classes, and also provides accessor methods to these older classes for maximum compatibility.</p> 

<p>In interactive environments, such as the Spark Shell or interactive notebooks, a <span class="rCW">SparkSession</span> will already be created for you
in a variable named <span class="rCW">spark</span>. For consistency, you should use this name when you create one in your own application. 
You can create a new <span class="rCW">SparkSession</span> through a Builder pattern which uses a "fluent interface" style of coding to build a new object by chaining
methods together. Spark properties can be passed in, as shown in these examples:</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			import org.apache.spark.sql.SparkSession;
			
			SparkSession spark = SparkSession.builder()
				.master("local[*]")
				.config("spark.driver.cores", 1)
				.appName("JUnderstandingSparkSession")
				.getOrCreate();
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			from pyspark.sql import SparkSession
			
		    spark = SparkSession.builder
		    	.master("local[*]")
		    	.config("spark.driver.cores", 1)
		    	.appName("understanding_sparksession")
		    	.getOrCreate()
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>The SparkR library doesn't use the "fluent interface" style. Simply pass parameters into the function.</p>
		<bu:rCode lang="plain">
			sparkR.session(
				master="local[*]",
				sparkConfig=list(spark.driver.cores=1),
				appName="understandingSparkSession"
			)
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			import org.apache.spark.sql.SparkSession
			
			val spark = SparkSession.builder
				.master("local[*]")
				.config("spark.driver.cores", 1)
				.appName("SUnderstandingSparkSession")
				.getOrCreate()
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<p>At the end of your application, calling <span class="rCW">stop()</span> on the <span class="rCW">SparkSession</span> will implicitly stop any nested Context classes.</p>
 
<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			spark.stop();
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			spark.stop()
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>In R, you call <span class="rCW">stop()</span> on the <span class="rCW">sparkR</span> object, rather than the session.</p>
		<bu:rCode lang="plain">
			sparkR.stop()
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			spark.stop()
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<bu:rSection anchor="02" title="Updating Spark 1.x Applications" />

<p>The developers of Spark 2.0 maintained backwards compatibility with Spark 1.x when they introduced <span class="rCW">SparkSession</span>, so all of your
existing code should still work in Spark 2.0. When you are ready to modernize your code, you should understand the relationships between the older classes and
<span class="rCW">SparkSession</span>.</p>

<h3>SparkConf</h3>

<p>Previously, this class was required to initialize configuration properties used by the <span class="rCW">SparkContext</span>, as well as set runtime properties
while an application was running. Now, all initialization occurs through the <span class="rCW">SparkSession</span> builder class. You will still use this class
(via the <span class="rCW">conf</span> accessor) to set runtime properties, but do not need to manually create it.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Spark 1.6
			SparkConf sparkConf = new SparkConf().setMaster("local[*]");
			sparkConf.set("spark.files", "file.txt"); 
			
			// Spark 2.x
			SparkSession spark = SparkSession.builder().master("local[*]").getOrCreate();
			spark.conf().set("spark.files", "file.txt"); 
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Spark 1.6
			sparkConf = SparkConf().setMaster("local[*]")
			sparkConf.set("spark.files", "file.txt")
			
			# Spark 2.x
		    spark = SparkSession.builder.master("local[*]").getOrCreate()
		    spark.conf.set("spark.files", "file.txt")
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>In R, you change properties by reinitializing the entire session.</p>
		
		<bu:rCode lang="plain">
			# Spark 1.6
			sparkR.init(master="local[*]")
			sparkR.init(master="local[*]", sparkEnvir=list(spark.files="file.txt"))
			
			# Spark 2.x
			sparkR.session(master="local[*]")
			sparkR.session(master="local[*]", sparkConfig=list(spark.files="file.txt"))
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Spark 1.6
			val sparkConf = new SparkConf().setMaster("local[*]")
			sparkConf.set("spark.files", "file.txt")
			
			// Spark 2.x
			val spark = SparkSession.builder.master("local[*]").getOrCreate()
			spark.conf.set("spark.files", "file.txt")
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<h3>SparkContext and JavaSparkContext</h3>

<p>You will continue to use these classes (via the <span class="rCW">sparkContext</span> accessor) to perform operations that require the Spark Core API, such as working with accumulators,
broadcast variables, or low-level RDDs. However, you will not need to manually create it.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Spark 1.6
			SparkConf sparkConf = new SparkConf();
			JavaSparkContext sc = new JavaSparkContext(sparkConf);
			sc.textFile("README.md", 4);
			
			// Spark 2.x
			SparkSession spark = SparkSession.builder().getOrCreate();
			JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());
			sc.textFile("README.md", 4); 
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Spark 1.6
			sparkConf = SparkConf()
			sc = SparkContext(conf=sparkConf)
			sc.textFile("README.md", 4)
			
			# Spark 2.x
		    spark = SparkSession.builder.getOrCreate()
		    sc = spark.sparkContext
		    sc.textFile("README.md", 4)
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>The low-level Spark Core API is not exposed in SparkR.</p>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Spark 1.6
			val sparkConf = new SparkConf()
			val sc = new SparkContext(sparkConf)
			sc.textFile("README.md", 4)
			
			// Spark 2.x
			val spark = SparkSession.builder.getOrCreate()
			val sc = spark.sparkContext 
			sc.textFile("README.md", 4)
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<h3>SQLContext</h3>

<p>The <span class="rCW">SQLContext</span> is completely superceded by <span class="rCW">SparkSession</span>. Most Dataset and DataFrame 
operations are directly available in <span class="rCW">SparkSession</span>. Operations related to table and database metadata are now encapsulated in a Catalog
(via the <span class="rCW">catalog</span> accessor).</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Spark 1.6
			SparkConf sparkConf = new SparkConf();
			JavaSparkContext sc = new JavaSparkContext(sparkConf);
			SQLContext sqlContext = new SQLContext(sc);
			DataFrame df = sqlContext.read().json("data.json");
			DataFrame tables = sqlContext.tables();
						
			// Spark 2.x
			SparkSession spark = SparkSession.builder().getOrCreate();
			Dataset<Row> df = spark.read().json("data.json");
			Dataset<Row> tables = spark.catalog().listTables(); 
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Spark 1.6
			sparkConf = SparkConf()
			sc = SparkContext(conf=sparkConf)
			sqlContext = SQLContext(sc)
			df = sc.read.json("data.json")
			tables = sc.tables()
			
			# Spark 2.x
		    spark = SparkSession.builder.getOrCreate()
		    df = spark.read.json("data.json")
		    tables = spark.catalog.listTables()
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>SparkR does not use a Catalog.</p>
		<bu:rCode lang="plain">
			# Spark 1.6
			sc <- sparkR.init()
			sqlContext <- sparkRSQL.init(sc)
			df <- read.df(sqlContext, "data.json", "json")
			tables <- tables(sqlContext)
									
			# Spark 2.x
			sparkR.session()
			df <- read.df("data.json", "json")
			tables <- tables()
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Spark 1.6
			val sparkConf = new SparkConf()
			val sc = new SparkContext(sparkConf)
			val sqlContext = new SQLContext(sc)
			val df = sqlContext.read.json("data.json")
			val tables = sqlContext.tables()
			
			// Spark 2.x
			val spark = SparkSession.builder.getOrCreate()
			val df = spark.read.json("data.json")
			val tables = spark.catalog.listTables()
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<h3>HiveContext</h3>

<p>The <span class="rCW">HiveContext</span> is completely superceded by <span class="rCW">SparkSession</span>. You will need enable Hive support
when you create your <span class="rCW">SparkSession</span> and include the necessary Hive library dependencies in your classpath.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Spark 1.6
			SparkConf sparkConf = new SparkConf();
			JavaSparkContext sc = new JavaSparkContext(sparkConf);
			HiveContext hiveContext = new HiveContext(sc);
			DataFrame df = hiveContext.sql("SELECT * FROM hiveTable");
						
			// Spark 2.x
			SparkSession spark = SparkSession.builder().enableHiveSupport().getOrCreate();
			Dataset<Row> df = spark.sql("SELECT * FROM hiveTable");
			
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Spark 1.6
			sparkConf = SparkConf()
			sc = SparkContext(conf=sparkConf)
			hiveContext = HiveContext(sc)
			df = hiveContext.sql("SELECT * FROM hiveTable")
			
			# Spark 2.x
		    spark = SparkSession.builder.enableHiveSupport().getOrCreate()
			df = spark.sql("SELECT * FROM hiveTable")

		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>SparkR does not use a Catalog.</p>
		<bu:rCode lang="plain">
			# Spark 1.6
			sc <- sparkR.init()
			hiveContext <- sparkRHive.init(sc)
			df <- sql(hiveContext, "SELECT * FROM hiveTable")
			
			# Spark 2.x
			sparkR.session(enableHiveSupport=TRUE)
			df <- sql("SELECT * FROM hiveTable")
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Spark 1.6
			val sparkConf = new SparkConf()
			val sc = new SparkContext(sparkConf)
			val hiveContext = new HiveContext(sc)
			val df = hiveContext.sql("SELECT * FROM hiveTable")
			
			// Spark 2.x
			val spark = SparkSession.builder.enableHiveSupport().getOrCreate()
			val df = spark.sql("SELECT * FROM hiveTable")
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="https://spark.apache.org/docs/2.0.0/api/java/org/apache/spark/sql/SparkSession.html">SparkSession</a> in the Java API Documentation</li>
		<li><a href="https://spark.apache.org/docs/2.0.0/api/python/pyspark.sql.html#pyspark.sql.SparkSession">SparkSession</a> in the Python API Documentation</li>
		<li><a href="https://spark.apache.org/docs/2.0.0/api/R/sparkR.session.html">SparkSession</a> in the R API Documentation</li>
		<li><a href="https://spark.apache.org/docs/2.0.0/api/scala/index.html#org.apache.spark.sql.SparkSession">SparkSession</a> in the Scala API Documentation</li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>