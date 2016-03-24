<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-03-11">
	<h3>Synopsis</h3>
	<p>This recipe provides a straightforward introduction to the Spark DataFrames API, which builds upon the Spark Core API to
	increase developer productivity. We create a DataFrame from a JSON file (results from the 2016 Democratic Primary in Virginia) 
	and use the DataFrames API to transform the data and discover interesting
	characteristics about it. We then save our work to the local filesystem.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>Spark DataFrames were introduced in Spark <span class="rPN">1.3.0</span>. Any equal or higher version should work with this recipe.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">DataFrames Highlights</a></li>
		<li><a href="#02">Creating the DataFrame</a></li>
		<li><a href="#03">Transforming and Querying</a></li>
		<li><a href="#04">Saving the DataFrame</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="DataFrames Highlights" />

<p>Most Spark tutorials dive into Resilient Distributed Datasets (RDDs) right away, loading file data with the Spark Core API (via <span class="rCW">textFile()</span>),
and performing common transformations and actions on the raw data. In practice, you infrequently call on the Core API because Spark offers more useful abstractions at a higher level. 
The DataFrames API provides a tabular view of RDD data and allows you to use common relational database patterns without stringing together endless chains 
of low-level operators. (In math terms, where the Core API gives you <span class="rCW">add()</span> and allows you to put it in a loop to perform multiplication, 
the DataFrames API just provides <span class="rCW">multiply()</span> right out of the box).</p>
	
<p>DataFrames are optimized for distributed processing within Spark, and are also compatible with the DataFrame libraries offered in Python and R.
You can create a DataFrame from a variety of sources, such as existing RDDs, relational database tables, Apache Hive tables, JSON, Parquet, and text files.
With a schema that's either inferred from the data or specified as a configuration option, the data can immediately be traversed or transformed as a column-based table.</p>
			
<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/working-dataframes.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on an EC2 instance:</li> 

	<bu:rCode lang="bash">
		# Download the working-dataframes source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/working-dataframes.zip
		
		# Unzip, creating /opt/sparkour/working-dataframes
		sudo unzip working-dataframes.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. A helper script,
		<span class="rCW">sparkour.sh</span> is included to compile, bundle, and submit applications in all languages.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/working-dataframes
				./sparkour.sh java
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/working-dataframes
				./sparkour.sh python
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/working-dataframes
				./sparkour.sh r
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/working-dataframes
				./sparkour.sh scala
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>As a topical example dataset, we use the results of the March 2016 Virginia Primary Election for President. The file,
		<span class="rCW">loudoun_d_primary_results_2016.json</span>, is included with the source code and contains the results of the Democratic Primary
		across precincts in Loudoun County. (The original CSV source data was downloaded from the <a href="http://results.elections.virginia.gov/primary.html">Virginia Department
		of Elections</a>, trimmed down to one county, and converted to JSON with a <a href="https://code.urizone.net/svn/sparkour/trunk/data/workspaces/working-dataframes/python/csv_to_json.py">simple Python script</a>).
		</li>
</ol>

<bu:rSection anchor="02" title="Creating the DataFrame" />

<p>The <span class="rCW"><a href="https://spark.apache.org/docs/1.6.0/api/python/pyspark.sql.html#pyspark.sql.SQLContext">SQLContext</a></span> class is the entry point for
	the DataFrames API. This class exposes a <span class="rCW"><a href="https://spark.apache.org/docs/1.6.0/api/python/pyspark.sql.html#pyspark.sql.DataFrameReader">DataFrameReader</a></span>
	named <span class="rCW">read</span> which can be used to create a 
	<span class="rCW"><a href="https://spark.apache.org/docs/1.6.0/api/python/pyspark.sql.html#pyspark.sql.DataFrame">DataFrame</a></span> from existing data in supported formats. 
	Consistent with the Spark Core API, any command that takes a file path as a string can use protocols such as
	<span class="rCW">s3a://</span> or <span class="rCW">hdfs://</span> to point to files on external storage solutions. 
	You can also read from relational database tables via JDBC, as described in <bu:rLink id="using-jdbc" />.</p> 

<ol>
	<li>In our application, we create a <span class="rCW">SQLContext</span> and then create a <span class="rCW">DataFrame</span> from
		a JSON file. The format of the JSON file requires that each line be an independent, well-formed JSON object
		(and lines should not end with a comma). Pretty-printed JSON objects need to be compressed to a single line.</li>
			
	<bu:rCode lang="plain">
		{"district_type": "Congressional", "last_name": "Clinton", "candidate_ballot_order": "1", "precinct_code": "###PROV", "referendumId": "", "total_votes": "9", "candidate_name": "Hillary Clinton", "locality_name": "LOUDOUN COUNTY", "office_ballot_order": "1", "party": "Democratic", "election_name": "2016 March Democratic Presidential Primary", "election_date": "2016-03-01 00:00:00.000", "precinct_name": "## Provisional", "null": [""], "locality_code": "107", "negative_votes": "", "office_name": "President", "candidateId": "124209128", "DESCRIPTION": "10th District", "districtId": "1085224094", "referendum_title": "", "officeId": "933838092", "in_precinct": "## Provisional", "election_type": "Primary"}
		{"district_type": "Congressional", "last_name": "O'Malley", "candidate_ballot_order": "2", "precinct_code": "###PROV", "referendumId": "", "total_votes": "0", "candidate_name": "Martin J. O'Malley", "locality_name": "LOUDOUN COUNTY", "office_ballot_order": "1", "party": "Democratic", "election_name": "2016 March Democratic Presidential Primary", "election_date": "2016-03-01 00:00:00.000", "precinct_name": "## Provisional", "null": [""], "locality_code": "107", "negative_votes": "", "office_name": "President", "candidateId": "1999936198", "DESCRIPTION": "10th District", "districtId": "1085224094", "referendum_title": "", "officeId": "933838092", "in_precinct": "## Provisional", "election_type": "Primary"}
		{"district_type": "Congressional", "last_name": "Sanders", "candidate_ballot_order": "3", "precinct_code": "###PROV", "referendumId": "", "total_votes": "11", "candidate_name": "Bernie Sanders", "locality_name": "LOUDOUN COUNTY", "office_ballot_order": "1", "party": "Democratic", "election_name": "2016 March Democratic Presidential Primary", "election_date": "2016-03-01 00:00:00.000", "precinct_name": "## Provisional", "null": [""], "locality_code": "107", "negative_votes": "", "office_name": "President", "candidateId": "673872380", "DESCRIPTION": "10th District", "districtId": "1085224094", "referendum_title": "", "officeId": "933838092", "in_precinct": "## Provisional", "election_type": "Primary"}
	</bu:rCode>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Initialize the SQLContext
				SQLContext sqlContext = new SQLContext(sc);
		
				// Create a DataFrame based on the JSON results.
				DataFrame rawDF = sqlContext.read().json("loudoun_d_primary_results_2016.json");
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Initialize the SQLContext
			    sqlContext = SQLContext(sc)
			
			    # Create a DataFrame based on the JSON results.
			    rawDF = sqlContext.read.json("loudoun_d_primary_results_2016.json")
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# Initialize the SQLContext
				sqlContext <- sparkRSQL.init(sc)
				
				# Create a DataFrame based on the JSON results.
				rawDF <- read.df(sqlContext, "loudoun_d_primary_results_2016.json", "json")					
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Initialize the SQLContext
				val sqlContext = new SQLContext(sc)
			
				// Create a DataFrame based on the JSON results.
				val rawDF = sqlContext.read.json("loudoun_d_primary_results_2016.json")		
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>The path specified in the above command could also be a directory, and the <span class="rCW">DataFrame</span> would be
		built from all files in that directory (but not in nested directories).</li>
	<li>We can now treat the data as a column-based table, performing queries and transformations as if
		the underlying data were in a relational database. By default, the 
		<span class="rCW">DataFrameReader</span> infers the schema of the data from the	data in the 
		first row of the file. In this case, the original data was all string-based, so the
		<span class="rCW">DataFrame</span> makes each column string-based. You can use <span class="rCW">printSchema()</span> to
		see the inferred schema of the data.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Print the schema
				rawDF.printSchema();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				# Print the schema
				rawDF.printSchema()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# Print the schema
				printSchema(rawDF)
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Print the schema
				rawDF.printSchema()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
			
	<bu:rCode lang="plain">
		root
		 |-- DESCRIPTION: string (nullable = true)
		 |-- candidateId: string (nullable = true)
		 |-- candidate_ballot_order: string (nullable = true)
		 |-- candidate_name: string (nullable = true)
		 |-- districtId: string (nullable = true)
		 |-- district_type: string (nullable = true)
		 |-- election_date: string (nullable = true)
		 |-- election_name: string (nullable = true)
		 |-- election_type: string (nullable = true)
		 |-- in_precinct: string (nullable = true)
		 |-- last_name: string (nullable = true)
		 |-- locality_code: string (nullable = true)
		 |-- locality_name: string (nullable = true)
		 |-- negative_votes: string (nullable = true)
		 |-- null: array (nullable = true)
		 |    |-- element: string (containsNull = true)
		 |-- officeId: string (nullable = true)
		 |-- office_ballot_order: string (nullable = true)
		 |-- office_name: string (nullable = true)
		 |-- party: string (nullable = true)
		 |-- precinct_code: string (nullable = true)
		 |-- precinct_name: string (nullable = true)
		 |-- referendumId: string (nullable = true)
		 |-- referendum_title: string (nullable = true)
		 |-- total_votes: string (nullable = true)
	</bu:rCode>
</ol>

<bu:rSection anchor="03" title="Transforming and Querying the DataFrame" />

<ol>
	<li>Our first exploration into the data determines who the candidates on the ballot were, based
		on the unique names in the <span class="rK">candidate_name</span> field. If you're familiar
		with the SQL language, this is comparable to querying <span class="rCW">SELECT DISTINCT(candidate_name)
		FROM table</span>.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Who was on the ballet?");
				// Get all distinct candidate names from the DataFrame
				rawDF.select("candidate_name").distinct().show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Who was on the ballet?")
			    # Get all distinct candidate names from the DataFrame
			    rawDF.select("candidate_name").distinct().show()			
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Who was on the ballet?")
				# Get all distinct candidate names from the DataFrame
				print(collect(distinct(select(rawDF, "candidate_name"))))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Who was on the ballet?")
				// Get all distinct candidate names from the DataFrame
				rawDF.select("candidate_name").distinct().show()			
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<bu:rCode lang="plain">
	 	Who was on the ballet?
		+------------------+
		|    candidate_name|
		+------------------+
		|Martin J. O'Malley|
		|   Hillary Clinton|
		|    Bernie Sanders|
		+------------------+
	</bu:rCode>
	
	<li>If you are following the examples in multiple languages, notice the difference between the R
	code structure and the other languages. In Java, Python, and Scala, you create a chain of transformations
	and actions, and reading from left to right shows the sequential progression of commands. In R,
	you start with the nested <span class="rCW">select()</span> and apply operators to 
	the result of the nested command -- the operator chain here reads from the deepest level to the shallowest level.
	Both structures lead to the same output, but you may need to change your mindset to write in the "R way" if
	you are more familiar with the other languages.</li>
	
	<li>Next, let's see what order the candidates were printed on the ballots. In Virginia, every county
	uses the same ballot, so we only need one sampling and can safely discard the duplicates.</li>
	 
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("What order were candidates on the ballot?");
				// Get the ballot order and discard the many duplicates (all VA ballots are the same)
				// Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
				DataFrame ballotDF = rawDF.select(rawDF.col("candidate_name"), rawDF.col("candidate_ballot_order"))
					.dropDuplicates().orderBy("candidate_ballot_order").persist();
				ballotDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("What order were candidates on the ballot?")
			    # Get the ballot order and discard the many duplicates (all VA ballots are the same)
			    # Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
			    orderDF = rawDF.select(rawDF["candidate_name"], rawDF["candidate_ballot_order"]) \
			        .dropDuplicates().orderBy("candidate_ballot_order").persist()
			    orderDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("What order were candidates on the ballot?")
				# Get the ballot order and discard the many duplicates (all VA ballots are the same)
				# Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
				orderDF <- orderBy(distinct(select(rawDF, "candidate_name", "candidate_ballot_order")), "candidate_ballot_order")
				persist(orderDF, "MEMORY_ONLY")
				print(collect(orderDF))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("What order were candidates on the ballot?")
				// Get the ballot order and discard the many duplicates (all VA ballots are the same)
				// Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
				val orderDF = rawDF.select(rawDF("candidate_name"), rawDF("candidate_ballot_order")) 
					.dropDuplicates().orderBy("candidate_ballot_order").persist()
				orderDF.show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
		
	<bu:rCode lang="plain">
		What order were candidates on the ballot?
		+------------------+----------------------+
		|    candidate_name|candidate_ballot_order|
		+------------------+----------------------+
		|   Hillary Clinton|                     1|
		|Martin J. O'Malley|                     2|
		|    Bernie Sanders|                     3|
		+------------------+----------------------+
	</bu:rCode>
	
	<li>Most API calls require you to pass in one or more <span class="rCW">Column</span>s to work on. In
		some cases, you can simply pass in the string column name and Spark resolves the correct column.
		In other cases, you can reference a DataFrame's columns with this syntax:</li>
		
		<bu:rTabs>
			<bu:rTab index="1">
				<bu:rCode lang="java">
					dataFrame.col("column_name")
				</bu:rCode>
			</bu:rTab><bu:rTab index="2">
				<bu:rCode lang="python">
					# This is allowed, but may be deprecated in the future
					dataFrame.column_name
					
					# This is the preferred way
					dataFrame["column_name"]
				</bu:rCode>
			</bu:rTab><bu:rTab index="3">
				<bu:rCode lang="plain">
					dataFrame$column_name
				</bu:rCode>	
			</bu:rTab><bu:rTab index="4">
				<bu:rCode lang="scala">
					dataFrame("column_name")
				</bu:rCode>	
			</bu:rTab>
		</bu:rTabs>

	<li>To demonstrate a <span class="rCW">join</span> transformation, let's consider a contrived example.
		The previous query that showed the ballot order needs to be changed to show
		descriptive English text instead of numbers. We have a reference lookup table available in the file
		called <span class="rCW">friendly_orders.json</span> that we would like to use.</li>
		
	<bu:rCode lang="plain">
		{"candidate_ballot_order": "1", "friendly_name": "First on Ballot"}
		{"candidate_ballot_order": "2", "friendly_name": "In Middle of Ballot"}
		{"candidate_ballot_order": "3", "friendly_name": "Last on Ballot"}
	</bu:rCode>
	
	<li>We create a <span class="rCW">DataFrame</span> of this reference data and then use it to alter the output of our ballot order query.</li>
	 
	 <bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("What order were candidates on the ballot (in descriptive terms)?");
				// Load a reference table of friendly names for the ballot orders.
				DataFrame friendlyDF = sqlContext.read().json("friendly_orders.json");
				// Join the tables so the results show descriptive text
				DataFrame joinedDF = ballotDF.join(friendlyDF, "candidate_ballot_order");
				// Hide the numeric column in the output.
				joinedDF.select(joinedDF.col("candidate_name"), joinedDF.col("friendly_name")).show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("What order were candidates on the ballot (in descriptive terms)?")
			    # Load a reference table of friendly names for the ballot orders.
			    friendlyDF = sqlContext.read.json("friendly_orders.json")
			    # Join the tables so the results show descriptive text
			    joinedDF = orderDF.join(friendlyDF, "candidate_ballot_order")
			    # Hide the numeric column in the output.
			    joinedDF.select(joinedDF["candidate_name"], joinedDF["friendly_name"]).show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("What order were candidates on the ballot (in descriptive terms)?")
				# Load a reference table of friendly names for the ballot orders.
				friendlyDF <- read.df(sqlContext, "friendly_orders.json", "json")
				# Join the tables so the results show descriptive text
				joinedDF <- join(orderDF, friendlyDF, orderDF$candidate_ballot_order == friendlyDF$candidate_ballot_order)
				# Hide the numeric column in the output.
				print(collect(select(joinedDF, "candidate_name", "friendly_name")))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("What order were candidates on the ballot (in descriptive terms)?")
				// Load a reference table of friendly names for the ballot orders.
				val friendlyDF = sqlContext.read.json("friendly_orders.json")
				// Join the tables so the results show descriptive text
				val joinedDF = orderDF.join(friendlyDF, "candidate_ballot_order")
				// Hide the numeric column in the output.
				joinedDF.select(joinedDF("candidate_name"), joinedDF("friendly_name")).show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<bu:rCode lang="plain">
		What order were candidates on the ballot (in descriptive terms)?
		+------------------+-------------------+
		|    candidate_name|      friendly_name|
		+------------------+-------------------+
		|   Hillary Clinton|    First on Ballot|
		|Martin J. O'Malley|In Middle of Ballot|
		|    Bernie Sanders|     Last on Ballot|
		+------------------+-------------------+
	</bu:rCode>
	
	<li>You won't need joins for such a simple case unless you deliver analytic reports to a particularly
		pendantic executive. A more interesting case might join the <span class="rK">precinct_name</span>
		to geospatial location data or area income data to identify correlations.</li>
	
	<li>Next, let's try an aggregate query. To count the total votes, we must cast the column
		to numeric data and then take the sum of every cell. We assign an alias to the column
		after the cast to increase readability.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
					System.out.println("How many votes were cast?");
					// Orginal data is string-based. Create an integer version of the total
					// votes column.
					Column votesColumn = rawDF.col("total_votes").cast("int").alias("total_votes_int");
					// Get the integer-based votes column and sum all values together
					rawDF.select(votesColumn).groupBy().sum("total_votes_int").show();						
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("How many votes were cast?")
			    # Orginal data is string-based. Create an integer version of the total votes column.
			    votesColumn = rawDF["total_votes"].cast("int").alias("total_votes_int")
			    # Get the integer-based votes column and sum all values together
			    rawDF.select(votesColumn).groupBy().sum("total_votes_int").show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("How many votes were cast?")
				# Orginal data is string-based. Create an integer version of the total votes column.
				votesColumn <- alias(cast(rawDF$total_votes, "int"), "total_votes_int")
				# Get the integer-based votes column and sum all values together
				print(collect(sum(groupBy(select(rawDF, votesColumn)), "total_votes_int")))
   			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("How many votes were cast?")
				// Orginal data is string-based. Create an integer version of the total votes column.
				val votesColumn = rawDF("total_votes").cast("int").alias("total_votes_int")
				// Get the integer-based votes column and sum all values together
				rawDF.select(votesColumn).groupBy().sum("total_votes_int").show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<bu:rCode lang="plain">
		How many votes were cast?
		+--------------------+
		|sum(total_votes_int)|
		+--------------------+
		|               36149|
		+--------------------+
	</bu:rCode>
	
	<li>Grouping this vote count by <span class="rK">candidate_name</span> employs a similar pattern.
		We introduce <span class="rCW">orderBy()</span> to sort the results.</li> 
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("How many votes did each candidate get?");
				// Get just the candidate names and votes.
				DataFrame candidateDF = rawDF.select(rawDF.col("candidate_name"), votesColumn);
				// Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
				// Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
				DataFrame groupedDF = candidateDF.groupBy("candidate_name")
					.agg(sum("total_votes_int").alias("sum_column"));
				DataFrame summaryDF = groupedDF.orderBy(groupedDF.col("sum_column").desc()).persist();
				summaryDF.show();			
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("How many votes did each candidate get?")
			    # Get just the candidate names and votes.
			    candidateDF = rawDF.select(rawDF["candidate_name"], votesColumn)
			    # Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
			    # Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
			    summaryDF = candidateDF.groupBy("candidate_name").agg(func.sum("total_votes_int").alias("sum_column")) \
			        .orderBy("sum_column", ascending=False).persist()
			    summaryDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("How many votes did each candidate get?")
				# Get just the candidate names and votes.
				candidateDF <- select(rawDF, rawDF$candidate_name, votesColumn)
				# Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
				# Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
				groupedDF <- agg(groupBy(candidateDF, "candidate_name"), sum_column=sum(candidateDF$total_votes_int))
				summaryDF <- orderBy(groupedDF, desc(groupedDF$sum_column))
				persist(summaryDF, "MEMORY_ONLY")
				print(collect(summaryDF))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("How many votes did each candidate get?")
				// Get just the candidate names and votes.
				val candidateDF = rawDF.select(rawDF("candidate_name"), votesColumn)
				// Group by candidate name and sum votes. Assign an alias to the sum so we can order on that column.
				// Note the call to persist() -- we reuse this DataFrame later, so let's not execute it twice.
				val groupedDF = candidateDF.groupBy("candidate_name").agg(functions.sum("total_votes_int").alias("sum_column"))
				val summaryDF = groupedDF.orderBy(groupedDF("sum_column").desc).persist()
				summaryDF.show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<bu:rCode lang="plain">
		How many votes did each candidate get?
		+------------------+--------------------+
		|    candidate_name|sum(total_votes_int)|
		+------------------+--------------------+
		|   Hillary Clinton|               21180|
		|    Bernie Sanders|               14730|
		|Martin J. O'Malley|                 239|
		+------------------+--------------------+
	</bu:rCode>
	
	<li>For our final exploration, we see which precincts had the highest physical turnout. Virginia
		designates special theoretical precincts for absentee and provisional ballots, which
		can skew our results. So, we want to omit these precincts from our query. A glance
		at the data shows that the theoretical precincts have non-integer values for <span class="rK">precinct_code</span>.
		We can apply <span class="rCW">cast</span> to the <span class="rK">precinct_code</span> column
		and then filter out the rows containing non-integer codes.</li> 
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
		System.out.println("Which polling station had the highest physical turnout?");
		// All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
		// Spark's cast function converts these to "null".
		Column precinctColumn = rawDF.col("precinct_code").cast("int").alias("precinct_code_int");
		// Get the precinct name, integer-based code, and integer-based votes,
		// then filter on non-null codes.
		DataFrame pollingDF = rawDF.select(rawDF.col("precinct_name"), precinctColumn, votesColumn)
			.filter("precinct_code_int is not null");
		// Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
		// Then, show the max row.
		groupedDF = pollingDF.groupBy("precinct_name").agg(sum("total_votes_int").alias("sum_column"));
		groupedDF.orderBy(groupedDF.col("sum_column").desc()).limit(1).show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Which polling station had the highest physical turnout?")
			    # All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
			    # Spark's cast function converts these to "null".
			    precinctColumn = rawDF["precinct_code"].cast("int").alias("precinct_code_int")
			    # Get the precinct name, integer-based code, and integer-based votes, then filter on non-null codes.
			    pollingDF = rawDF.select(rawDF["precinct_name"], precinctColumn, votesColumn) \
			        .filter("precinct_code_int is not null")
			    # Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
			    # Then, show the max row.
			    pollingDF.groupBy("precinct_name").agg(func.sum("total_votes_int").alias("sum_column")) \
			        .orderBy("sum_column", ascending=False).limit(1).show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Which polling station had the highest physical turnout?")
				# All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
				# Spark's cast function converts these to "null".
				precinctColumn <- alias(cast(rawDF$precinct_code, "int"), "precinct_code_int")
				# Get the precinct name, integer-based code, and integer-based votes, then filter on non-null codes.
				pollingDF <- filter(select(rawDF, rawDF$precinct_name, precinctColumn, votesColumn), "precinct_code_int is not null")
				# Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
				# Then, show the max row.
				groupedDF <- agg(groupBy(pollingDF, "precinct_name"), sum_column=sum(pollingDF$total_votes_int))
				pollingDF <- limit(orderBy(groupedDF, desc(groupedDF$sum_column)), 1)
				print(collect(pollingDF))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Which polling station had the highest physical turnout?")
				// All physical precincts have a numeric code. Provisional/absentee precincts start with "###".
				// Spark's cast function converts these to "null".
				val precinctColumn = rawDF("precinct_code").cast("int").alias("precinct_code_int")
				// Get the precinct name, integer-based code, and integer-based votes, then filter on non-null codes.
				val pollingDF = rawDF.select(rawDF("precinct_name"), precinctColumn, votesColumn)
					.filter("precinct_code_int is not null")
				// Group by precinct name and sum votes. Assign an alias to the sum so we can order on that column.
				// Then, show the max row.
				val groupedPollDF = pollingDF.groupBy("precinct_name").agg(functions.sum("total_votes_int").alias("sum_column"))
				groupedPollDF.orderBy(groupedPollDF("sum_column").desc).limit(1).show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<bu:rCode lang="plain">
		Which polling station had the highest physical turnout?
		+-------------+--------------------+
		|precinct_name|sum(total_votes_int)|
		+-------------+--------------------+
		| 314 - LEGACY|                 652|
		+-------------+--------------------+
	</bu:rCode>
</ol>

<bu:rSection anchor="04" title="Saving the DataFrame" />

<p>We used <span class="rCW">persist()</span> to optimize the operator chain for each of our data manipulations.
We can also save the data more permanently using a <span class="rCW">DataFrameWriter</span>.
The <span class="rCW"><a href="https://spark.apache.org/docs/1.6.0/api/python/pyspark.sql.html#pyspark.sql.DataFrame">DataFrame</a></span> class 
exposes a <span class="rCW"><a href="https://spark.apache.org/docs/1.6.0/api/python/pyspark.sql.html#pyspark.sql.DataFrameWriter">DataFrameWriter</a></span>
named <span class="rCW">write</span> which can be used to save a <span class="rCW">DataFrame</span>. There are four available write modes which can be specified, with 
<span class="rV">error</span> being the default:</p>
<ol>
	<li><span class="rV">append</span>: Add this data to the end of any data already at the target location.</li>
	<li><span class="rV">overwrite</span>: Erase any existing data at the target location and replace with this data.</li>
	<li><span class="rV">ignore</span>: Silently skip this command if any data already exists at the target location.</li>
	<li><span class="rV">error</span>: Throw an exception if any data already exists at the target location.</li>
</ol>

<p>You can also write to relational database tables via JDBC, as described in <bu:rLink id="using-jdbc" />.</p>

<ol>
	<li>In our application, we save one of our generated DataFrames as JSON data. The string-based
	path in this command points to a directory, not a filename.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Saving overall candidate summary as a new JSON dataset.");
				summaryDF.write().mode("overwrite").json("target/json");		
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Saving overall candidate summary as a new JSON dataset.")
			    summaryDF.write.json("target/json", mode="overwrite")		
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Saving overall candidate summary as a new JSON dataset.")
				write.df(summaryDF, path="target/json", source="json", mode="overwrite")		
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Saving overall candidate summary as a new JSON dataset.")
				summaryDF.write.mode("overwrite").json("target/json")		
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>If you look in the <span class="rCW">target/json</span> directory after running the application, you'll see a
		separate JSON file for each row of the <span class="rCW">DataFrame</span>, along with a <span class="rCW">_SUCCESS</span>
		indicator file.</li>
		
	<li>You can now use this directory as a file path to create a new <span class="rCW">DataFrame</span> for
	further analysis, or pass the data to another tool or programming lanaguage in your data pipeline.</li>
</ol>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/sql-programming-guide.html">Spark DataFrames</a> in the Spark Programming Guide</li>
		<li><bu:rLink id="using-jdbc" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>