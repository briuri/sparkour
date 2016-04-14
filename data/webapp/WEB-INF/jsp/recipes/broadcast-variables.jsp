<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noRMessage" value="<p>The SparkR library is designed to provide high-level APIs such as Spark DataFrames. Because the low-level Spark Core API was made private as of Spark 1.4.0, broadcast variables are not available in R.</p>" />

<bu:rOverview publishDate="2016-04-14">
	<h3>Synopsis</h3>
	<p>This recipe explains how to use broadcast variables distribute immutable reference data across a Spark cluster. Using
		broadcast variables can improve performance by reducing the amount of network traffic and data serialization required 
		to execute your Spark application.</p>  
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>Broadcast variables existed in Spark as early as <span class="rPN">0.5.2</span>. Any modern version should work with this recipe.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Broadcast Highlights</a></li>
		<li><a href="#02">Using Broadcast Variables</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Broadcast Highlights" />

<p>Broadcast variables are a built-in feature of Spark that allow you to efficiently share read-only 
reference data across a Spark cluster. When a job is submitted, Spark calculates a 
<span class="rPN">closure</span> consisting of all of the variables and methods required for a 
single executor to perform operations, and then sends that closure to each worker node. 
Without broadcast variables, some shared data might end up serialized, pushed across the network,
and deserialized more times than necessary.</p>

<p>You should consider using broadcast variables under the following conditions:</p>

<ul>
	<li>You have read-only reference data that does not change throughout the life of your Spark application.</li>
	<li>The data is used across multiple stages of application execution and would benefit from being locally cached on the worker nodes.</li>
	<li>The data is small enough to fit in memory on your worker nodes, but large enough that the overhead of serializing and deserializing it
		multiple times is impacting your performance.</li>
</ul>

<p>Broadcast variables are implemented as simple wrappers around collections of simple data types, as shown in the example code below.
They are not intended to wrap around distributed data structures such as RDDs and DataFrames, but you can use the data in the broadcast variable
to construct a distributed data structure.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Data without broadcast variables
			int[] data = new int[] {1, 2, 3};
			System.out.println(data[0]);
			
			// Data as a broadcast variable
			Broadcast<int[]> broadcastVar = sc.broadcast(data);
			System.out.println(broadcastVar.value()[0]);
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			// Data without broadcast variables
			data = [1, 2, 3]
			print(data[0])
			
			// Data as a broadcast variable
			broadcastVar = sc.broadcast(data)
			print(broadcastVar.value[0])
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noRMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Data without broadcast variables
			val data = Array(1, 2, 3)
			println(data[0])
			
			// Data as a broadcast variable
			val broadcastVar = sc.broadcast(data)
			println(broadcastVar.value[0])
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/broadcast-variables.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the broadcast-variables source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/broadcast-variables.zip
		
		# Unzip, creating /opt/sparkour/broadcast-variables
		sudo unzip broadcast-variables.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. 
		A helper script, <span class="rCW">sparkour.sh</span> is included to compile, bundle, and submit applications in all languages.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/broadcast-variables
				./sparkour.sh java --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/broadcast-variables
				./sparkour.sh python --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/broadcast-variables
				./sparkour.sh scala --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>There are two JSON files included with the source code. <span class="rCW">us_states.json</span> contains reference data about
	US states, including their abbreviation, full name, and the regional classification provided by the US Census Bureau. For example,
	Alabama is considered to be in the <span class="rV">Southern</span> region.</li>
	
	<bu:rCode lang="plain">
		{"state": "AL", "name": "Alabama", "census_region": "South", "census_division": "East South Central"}
		{"state": "AK", "name": "Alaska", "census_region": "West", "census_division": "Pacific"}
		{"state": "AZ", "name": "Arizona", "census_region": "West", "census_division": "Mountain"}
		{"state": "AR", "name": "Arkansas", "census_region": "South", "census_division": "West South Central"}
		{"state": "CA", "name": "California", "census_region": "West", "census_division": "Pacific"}
	</bu:rCode>

	<li>The second JSON file, <span class="rCW">store_locations.json</span> contains the city, state, and zip code for the 475 Costco
	warehouses in the United States.</li>
	
	<bu:rCode lang="plain">
		{"city": "Montgomery", "state": "AL", "zip_code": "36117-7033"}
		{"city": "Mobile", "state": "AL", "zip_code": "36606"}
		{"city": "Huntsville", "state": "AL", "zip_code": "35801-5930"}
	</bu:rCode>
</ol>

<bu:rSection anchor="02" title="Using Broadcast Variables" />

<p>To demonstrate broadcast variables, we can do a simple analysis of our data files to determine 
how many stores are in each of the four US regions. We treat our state data as a read-only
lookup table and broadcast it to our Spark cluster, and then aggregate the store data as a 
<span class="rCW">DataFrame</span> to generate the counts. If you need a refresher on DataFrames,
the recipe, <bu:rLink id="working-dataframes" />, may be helpful. Alternately, you can simply focus
on the parts of the code related to broadcast variables for now.</p>
		
<ol>
	<li>First, we register the state data as a broadcast variable. We use our
		<span class="rCW">SQLContext</span> to read in the JSON file as a DataFrame
		and then convert it into a simple list of <span class="rCW">Rows</span>.
		Finally, we wrap the list of rows in a broadcast variable.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				SQLContext sqlContext = new SQLContext(sc);
		
				// Register state data as a broadcast variable
				Broadcast<List<Row>> broadcastStateData = sc
					.broadcast(sqlContext.read().json("us_states.json").collectAsList());
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    sqlContext = SQLContext(sc)
			    
			    # Register state data as a broadcast variable
			    broadcastStateData = sc.broadcast(sqlContext.read.json("us_states.json").collect())
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				val sqlContext = new SQLContext(sc)
		
				// Register state data as a broadcast variable
				val broadcastStateData = sc.broadcast(sqlContext.read.json("us_states.json").collectAsList())
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>Next, we build a <span class="rCW">DataFrame</span> for the store data, and another
		for the state data. Instead of directly referencing the wrapped data, we use
		the <span class="rCW">value</span> of the broadcast variable. This conceals
		the complexity of the distributed way in which Spark broadcasts the data to every worker
		node.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<p>In order to convert a list of <span class="rCW">Rows</span> 
				back into a <span class="rCW">DataFrame</span>, we must also
				provide a schema for the raw data. In this case, each column in the
				state data is a string, and no column is nullable.</p>
			<bu:rCode lang="java">
				// Create a DataFrame based on the store locations.
				DataFrame storesDF = sqlContext.read().json("store_locations.json");
		
				// Create a DataFrame of US state data with the broadcast variable.
				StructType schema = DataTypes.createStructType(
					new StructField[] { 
						DataTypes.createStructField("census_division", DataTypes.StringType, false),
						DataTypes.createStructField("census_region", DataTypes.StringType, false),
						DataTypes.createStructField("name", DataTypes.StringType, false),
						DataTypes.createStructField("state", DataTypes.StringType, false) 
					}
				);
				DataFrame stateDF = sqlContext.createDataFrame(broadcastStateData.value(), schema);
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create a DataFrame based on the store locations.
			    storesDF = sqlContext.read.json("store_locations.json")
			
			    # Create a DataFrame of US state data with the broadcast variable.
			    stateDF = sqlContext.createDataFrame(broadcastStateData.value)
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<p>In order to convert a list of <span class="rCW">Rows</span> 
			back into a <span class="rCW">DataFrame</span>, we must also
			provide a schema for the raw data. In this case, each column in the
			state data is a string, and no column is nullable</p>
			<bu:rCode lang="scala">
				// Create a DataFrame based on the store locations.
				val storesDF = sqlContext.read.json("store_locations.json")
				
				// Create a DataFrame of US state data with the broadcast variable.
				val schema = StructType(
					Array(
						StructField("census_division", StringType, false),
						StructField("census_region", StringType, false),
						StructField("name", StringType, false),
						StructField("state", StringType, false)
					)
				)
				val stateDF = sqlContext.createDataFrame(broadcastStateData.value, schema)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		
	
	<li>Finally, we join the <span class="rCW">DataFrames</span> with an aggregate
		query to calculate the counts.</li>
				
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Join the DataFrames to get an aggregate count of stores in each US Region
				System.out.println("How many stores are in each US region?");
				DataFrame joinedDF = storesDF.join(stateDF, "state").groupBy("census_region").count();
				joinedDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Join the DataFrames to get an aggregate count of stores in each US Region
			    print("How many stores are in each US region?")
			    joinedDF = storesDF.join(stateDF, "state").groupBy("census_region").count()
			    joinedDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Join the DataFrames to get an aggregate count of stores in each US Region
				println("How many stores are in each US region?")
				val joinedDF = storesDF.join(stateDF, "state").groupBy("census_region").count()
				joinedDF.show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>There is no broadcast-specific code in the previous step. However, when you
		execute the application, you should see that Spark is handling the broadcast:</li>
		
	<bu:rCode lang="plain">
		INFO BlockManagerInfo: Added broadcast_2_piece0 in memory on 172.31.24.101:39947 (size: 19.3 KB, free: 511.1 MB)
		INFO SparkContext: Created broadcast 2 from collect at /opt/examples/sparkour/broadcast-variables/src/main/python/broadcast_variables.py:38
	</bu:rCode>
	
	<li>The final output of the application should look like this:</li>
	
	<bu:rCode lang="plain">
		How many stores are in each US region?
		+-------------+-----+
		|census_region|count|
		+-------------+-----+
		|         West|  222|
		|        South|  117|
		|    Northeast|   59|
		|      Midwest|   77|
		+-------------+-----+
	</bu:rCode>	 
</ol>
		
<bu:rFooter>
	<bu:rLinks>
		<li><a href="https://spark.apache.org/docs/latest/programming-guide.html#broadcast-variables">Broadcast Variables</a> in the Spark Programming Guide</li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>