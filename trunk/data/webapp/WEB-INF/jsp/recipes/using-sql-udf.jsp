<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-03-26">
	<h3>Synopsis</h3>
	<p>This recipe demonstrates how to query Spark DataFrames with Structured Query Language (SQL). The SparkSQL library
	supports SQL as an alternate way to work with DataFrames that is compatible with the code-based approach discussed in
	the recipe, <bu:rLink id="working-dataframes" />.</p> 
		
	<h3>Prerequisites</h3>
	<ol>
		<li>You should have a basic understand of Spark DataFrames, as covered in <bu:rLink id="working-dataframes" />.</li>
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
		<li><a href="#01">SparkSQL Highlights</a></li>
		<li><a href="#02">Registering a Table</a></li>
		<li><a href="#03">Transforming and Querying the DataFrame</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="SparkSQL Highlights" />

<p>The DataFrames API provides a tabular view of data that allows you to use common relational database patterns  
at a higher abstraction than the low-level Spark Core API. A DataFrame can be manipulated using functions and methods
exposed in the Java, Python, R, and Scala programming languages, making them straightforward to work with for developers
familiar with those languages.</p>

<p>DataFrames can also be queried using SQL, which immediately broadens the potential user base of Apache Spark to
a wider audience of analysts and database administrators. Any series of operators that can be chained together in programming code
can also be represented as a SQL query, and the base set of keywords and operations can also be extended with User-Defined Functions (UDFs).</p>

<p>Benefits of SQL include the ability to use the same query across codebases in different programming languages, 
a clearer representation of your processing pipeline that may be closer to the mental model of a data analyst, and the ability to manage the
queries that you run separately from the source code of the application. On the other hand, using a code-based approach eliminates the need
for a future maintenance developer to know SQL, and exposes possible query syntax errors at compiling time rather than execution time.</p>
		
<p>The decision to use SQL or programming code to work with DataFrames can be a pragmatic one, based upon the skillsets of you and your expected users. 
You can even mix and match approaches at different points in your processing pipeline, provided that you keep the complementary sections consistent and readable.</p>
	
<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/using-sql-udf.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the using-sql-udf source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/using-sql-udf.zip
		
		# Unzip, creating /opt/sparkour/using-sql-udf
		sudo unzip using-sql-udf.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. 
		A helper script, <span class="rCW">sparkour.sh</span> is included to compile, bundle, and submit applications in all languages.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/using-sql-udf
				./sparkour.sh java
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/using-sql-udf
				./sparkour.sh python
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/using-sql-udf
				./sparkour.sh r
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/using-sql-udf
				./sparkour.sh scala
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>As a topical example dataset, we use the results of the March 2016 Virginia Primary Election for President. The file,
		<span class="rCW">loudoun_d_primary_results_2016.json</span>, is included with the source code and contains the results of the Democratic Primary
		across precincts in Loudoun County. We explored this dataset in <bu:rLink id="working-dataframes" /> and repeat the same
		processing tasks below. You can compare and contrast the source code between recipes to see how the code-based and the SQL-based approaches
		result in the same output.</li>
</ol>

<bu:rSection anchor="02" title="Registering a Table" />

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
				SQLContext sqlContext = new SQLContext(sc);
		
				// Create a DataFrame based on the JSON results.
				DataFrame rawDF = sqlContext.read().json("loudoun_d_primary_results_2016.json");
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    sqlContext = SQLContext(sc)
			
			    # Create a DataFrame based on the JSON results.
			    rawDF = sqlContext.read.json("loudoun_d_primary_results_2016.json")
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				sqlContext <- sparkRSQL.init(sc)
				
				# Create a DataFrame based on the JSON results.
				rawDF <- read.df(sqlContext, "loudoun_d_primary_results_2016.json", "json")					
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				val sqlContext = new SQLContext(sc)
			
				// Create a DataFrame based on the JSON results.
				val rawDF = sqlContext.read.json("loudoun_d_primary_results_2016.json")		
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>In order to execute SQL queries on this <span class="rCW">DataFrame</span>, we must register it within the SQLContext as a temporary table.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Register as a SQL-accessible table
				rawDF.registerTempTable("votes");
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Register as a SQL-accessible table
			    rawDF.registerTempTable("votes")
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# Register as a SQL-accessible table
				registerTempTable(rawDF, "votes")
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Register as a SQL-accessible table
				rawDF.registerTempTable("votes")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>Make sure that the name you assign to the temporary table is not a reserved SQL keyword. Spark will allow such a name, but
		this may lead to query syntax errors whose cause is not immediately apparent.</li>  
</ol>

<bu:rSection anchor="03" title="Transforming and Querying the DataFrame" />

<ol>
	<li>Our first exploration into the data determines who the candidates on the ballot were, based
		on the unique names in the <span class="rK">candidate_name</span> field. 
		With a code-based approach, we would create a chain of operators on the DataFrame to
		<span class="rCW">select()</span> the <span class="rK">candidate_name</span> and then apply the
		<span class="rCW">distinct()</span> transformation to eliminate duplicates. With SQL,
		we can simply run the query, <span class="rCW">SELECT DISTINCT(candidate_name)
		FROM votes</span>. Notice that SQL queries are executed through the 
		<span class="rCW">SQLContext</span> and not the <span class="rCW">DataFrame</span> itself.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Who was on the ballet?");
				// Get all distinct candidate names from the DataFrame
				String query = "SELECT DISTINCT candidate_name FROM votes";
				sqlContext.sql(query).show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Who was on the ballet?")
			    # Get all distinct candidate names from the DataFrame
			    query = "SELECT DISTINCT candidate_name FROM votes"
			    sqlContext.sql(query).show()		
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("Who was on the ballet?")
				# Get all distinct candidate names from the DataFrame
				query <- "SELECT DISTINCT candidate_name FROM votes"
				print(collect(sql(sqlContext, query)))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Who was on the ballet?")
				// Get all distinct candidate names from the DataFrame
				var query = "SELECT DISTINCT candidate_name FROM votes"
				sqlContext.sql(query).show()		
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
		
	<li>Next, let's see what order the candidates were printed on the ballots. In Virginia, every county
	uses the same ballot, so we only need one sampling and can safely discard the duplicates.</li>
	 
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("What order were candidates on the ballot?");
				// Get the ballot order and discard the many duplicates (all VA ballots are the same)
				// We also register this DataFrame as a table to reuse later.
				query = "SELECT DISTINCT candidate_name, candidate_ballot_order "
					+ "FROM votes ORDER BY candidate_ballot_order";
				DataFrame orderDF = sqlContext.sql(query);
				orderDF.registerTempTable("ordered_candidates");
				orderDF.show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("What order were candidates on the ballot?")
			    # Get the ballot order and discard the many duplicates (all VA ballots are the same)
			    # We also register this DataFrame as a table to reuse later.
			    query = """SELECT DISTINCT candidate_name, candidate_ballot_order
			        FROM votes ORDER BY candidate_ballot_order"""
			    orderDF = sqlContext.sql(query)
			    orderDF.registerTempTable("ordered_candidates")
			    orderDF.show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("What order were candidates on the ballot?")
				# Get the ballot order and discard the many duplicates (all VA ballots are the same)
				# We also register this DataFrame as a table to reuse later.
				query <- paste("SELECT DISTINCT candidate_name, candidate_ballot_order",
				    "FROM votes ORDER BY candidate_ballot_order", sep=" ")
				orderDF <- sql(sqlContext, query)
				registerTempTable(orderDF, "ordered_candidates")
				print(collect(orderDF))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("What order were candidates on the ballot?")
				// Get the ballot order and discard the many duplicates (all VA ballots are the same)
				// We also register this DataFrame as a table to reuse later.
				query = """SELECT DISTINCT candidate_name, candidate_ballot_order
					FROM votes ORDER BY candidate_ballot_order"""
				val orderDF = sqlContext.sql(query)
				orderDF.registerTempTable("ordered_candidates")
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
				friendlyDF.registerTempTable("ballot_order");
				// Join the tables so the results show descriptive text
				query = "SELECT oc.candidate_name, bo.friendly_name "
					+ "FROM ordered_candidates oc JOIN ballot_order bo "
					+ "ON oc.candidate_ballot_order = bo.candidate_ballot_order";
				sqlContext.sql(query).show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("What order were candidates on the ballot (in descriptive terms)?")
			    # Load a reference table of friendly names for the ballot orders.
			    friendlyDF = sqlContext.read.json("friendly_orders.json")
			    friendlyDF.registerTempTable("ballot_order")
			    # Join the tables so the results show descriptive text.
			    query = """SELECT oc.candidate_name, bo.friendly_name
			        FROM ordered_candidates oc JOIN ballot_order bo 
			        ON oc.candidate_ballot_order = bo.candidate_ballot_order""" 
			    sqlContext.sql(query).show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				print("What order were candidates on the ballot (in descriptive terms)?")
				# Load a reference table of friendly names for the ballot orders.
				friendlyDF <- read.df(sqlContext, "friendly_orders.json", "json")
				registerTempTable(friendlyDF, "ballot_order")
				# Join the tables so the results show descriptive text
				query <- paste("SELECT oc.candidate_name, bo.friendly_name",
				    "FROM ordered_candidates oc JOIN ballot_order bo",
				    "ON oc.candidate_ballot_order = bo.candidate_ballot_order", sep=" ")
				print(collect(sql(sqlContext, query)))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("What order were candidates on the ballot (in descriptive terms)?")
				// Load a reference table of friendly names for the ballot orders.
				val friendlyDF = sqlContext.read.json("friendly_orders.json")
				friendlyDF.registerTempTable("ballot_order")
				// Join the tables so the results show descriptive text
				query = """SELECT oc.candidate_name, bo.friendly_name
					FROM ordered_candidates oc JOIN ballot_order bo
					ON oc.candidate_ballot_order = bo.candidate_ballot_order"""
				sqlContext.sql(query).show()
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
	
	<li>Next, let's try an aggregate query. To count the total votes, we must cast the column
		to numeric data and then take the sum of every cell. The DataFrame API has a <span class="rCW">cast()</span>
		operator which we can use without SQL. Alternately, we can create a UDF that
		converts a String into an Integer, and then use that UDF in a SQL query:</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("How many votes were cast?");
				// Orginal data is string-based. Create a UDF to cast as an integer.
				sqlContext.udf().register("to_int", (String x) -> Integer.valueOf(x), DataTypes.IntegerType);
				query = "SELECT SUM(to_int(total_votes)) AS sum_total_votes FROM votes";
				sqlContext.sql(query).show();				
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("How many votes were cast?")
			    # Orginal data is string-based. Create a UDF to cast as an integer.
			    sqlContext.udf.register("to_int", lambda x: int(x))
			    query = "SELECT SUM(to_int(total_votes)) AS sum_total_votes FROM votes"
			    sqlContext.sql(query).show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<p>Unfortunately, SparkR does not yet support UDFs, so this example still uses
			<span class="rCW">cast()</span>. You can track the progress of this
			work in the <a href="https://issues.apache.org/jira/browse/SPARK-6817">SPARK-6817</a> ticket.</p>
			<bu:rCode lang="plain">
				print("How many votes were cast?")
				# Orginal data is string-based. Create an integer version of the total votes column.
				# Because UDFs are not yet supported in SparkR, we cast the column first, then run SQL.
				votesColumn <- alias(cast(rawDF$total_votes, "int"), "total_votes_int")
				votesDF <- withColumn(rawDF, "total_votes_int", cast(rawDF$total_votes, "int"))
				registerTempTable(votesDF, "votes_int")
				# Get the integer-based votes column and sum all values together
				query <- "SELECT SUM(total_votes_int) AS sum_total_votes FROM votes_int"
				print(collect(sql(sqlContext, query)))
   			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("How many votes were cast?")
				// Orginal data is string-based. Create a UDF to cast as an integer.
				sqlContext.udf.register("to_int", (x: String) => x.toInt)
				query = "SELECT SUM(to_int(total_votes)) AS sum_total_votes FROM votes"
				sqlContext.sql(query).show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<bu:rCode lang="plain">
		How many votes were cast?
		+---------------+
		|sum_total_votes|
		+---------------+
		|        36149.0|
		+---------------+
	</bu:rCode>
			
	<li>Grouping the vote count by <span class="rK">candidate_name</span> employs a similar pattern.
		We reuse our UDF and use <span class="rCW">ORDER BY</span> to sort the results.</li> 
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				println("How many votes did each candidate get?")
				query = """SELECT candidate_name, SUM(to_int(total_votes)) AS sum_total_votes
					FROM votes GROUP BY candidate_name ORDER BY sum_total_votes DESC"""
				sqlContext.sql(query).show()		
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("How many votes did each candidate get?")
			    query = """SELECT candidate_name, SUM(to_int(total_votes)) AS sum_total_votes
			        FROM votes GROUP BY candidate_name ORDER BY sum_total_votes DESC"""
			    sqlContext.sql(query).show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<p>Since SparkR does not yet support UDFs, we use the <span class="rCW">votes_int</span>
				temporary table created in the previous transformation.</p>
			<bu:rCode lang="plain">
				print("How many votes did each candidate get?")
				query <- paste("SELECT candidate_name, SUM(total_votes_int) AS sum_total_votes",
				    "FROM votes_int GROUP BY candidate_name ORDER BY sum_total_votes DESC", sep=" ")
				print(collect(sql(sqlContext, query)))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("How many votes did each candidate get?")
				query = """SELECT candidate_name, SUM(to_int(total_votes)) AS sum_total_votes
					FROM votes GROUP BY candidate_name ORDER BY sum_total_votes DESC"""
				sqlContext.sql(query).show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<bu:rCode lang="plain">
		How many votes did each candidate get?
		+------------------+---------------+
		|    candidate_name|sum_total_votes|
		+------------------+---------------+
		|   Hillary Clinton|        21180.0|
		|    Bernie Sanders|        14730.0|
		|Martin J. O'Malley|          239.0|
		+------------------+---------------+
	</bu:rCode>

	<li>For our final exploration, we see which precincts had the highest physical turnout. Virginia
		designates special theoretical precincts for absentee and provisional ballots, which
		can skew our results. So, we want to omit these precincts from our query. A glance
		at the data shows that the theoretical precincts have non-integer values for <span class="rK">precinct_code</span>.
		We can filter these with a SQL <span class="rCW">LIKE</span> query.</li> 
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				System.out.println("Which polling station had the highest physical turnout?");
				// All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
				query = "SELECT precinct_name, SUM(to_int(total_votes)) AS sum_total_votes "
					+ "FROM votes WHERE precinct_code NOT LIKE '##%' "
					+ "GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1";
				sqlContext.sql(query).show();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    print("Which polling station had the highest physical turnout?")
			    # All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
			    query = """SELECT precinct_name, SUM(to_int(total_votes)) AS sum_total_votes
			        FROM votes WHERE precinct_code NOT LIKE '##%'
			        GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1"""
			    sqlContext.sql(query).show()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<p>Since SparkR does not yet support UDFs, we use the <span class="rCW">votes_int</span>
				temporary table created in the previous transformation.</p>
			<bu:rCode lang="plain">
				print("Which polling station had the highest physical turnout?")
				# All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
				query <- paste("SELECT precinct_name, SUM(total_votes_int) AS sum_total_votes",
				    "FROM votes_int WHERE precinct_code NOT LIKE '##%'",
				    "GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1", sep=" ")
				print(collect(sql(sqlContext, query)))
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				println("Which polling station had the highest physical turnout?")
				// All physical precincts have a numeric code. Provisional/absentee precincts start with "##".
				query = """SELECT precinct_name, SUM(to_int(total_votes)) AS sum_total_votes
					FROM votes WHERE precinct_code NOT LIKE '##%'
					GROUP BY precinct_name ORDER BY sum_total_votes DESC LIMIT 1"""
				sqlContext.sql(query).show()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<bu:rCode lang="plain">
		Which polling station had the highest physical turnout?
		+-------------+---------------+
		|precinct_name|sum_total_votes|
		+-------------+---------------+
		| 314 - LEGACY|          652.0|
		+-------------+---------------+
	</bu:rCode>
	
	<li>If you are comparing this source code to the source code in <bu:rLink id="working-dataframes" />, you'll notice
		that the syntax of the SQL approach is much more readable and understandable, especially for aggregate queries.</li>
</ol>

<h3>Using UDFs without SQL</h3>

<p>UDFs are not unique to SparkSQL. You can also define them as named functions and insert them into a chain of operators without 
using SQL. The contrived example below shows how we would define and use a UDF directly in the code.</li>
	
<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			import static org.apache.spark.sql.functions.udf;
			import org.apache.spark.sql.types.DataTypes;
			import org.apache.spark.sql.UserDefinedFunction;
			
			// Define the UDF
			UserDefinedFunction udfUppercase = udf((String string) -> string.toUpperCase(), DataTypes.StringType);

			// Convert a whole column to uppercase with a UDF.
			newDF = oldDF.withColumn("name_upper", udfUppercase(oldDF.col("name")));
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			from pyspark.sql.types import StringType
			from pyspark.sql.functions import udf

			# Define the UDF
			def uppercase(string):
				return string.upper()
			udf_uppercase = udf(uppercase, StringType())
			
			# Convert a whole column to uppercase with a UDF.
			newDF = oldDF.withColumn("name_upper", udf_uppercase("name"))
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<p>Unfortunately, SparkR does not yet support UDFs. You can track the progress of this
			work in the <a href="https://issues.apache.org/jira/browse/SPARK-6817">SPARK-6817</a> ticket.</p>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			import org.apache.spark.sql.functions.udf

			// Define the UDF
			def udfUppercase = udf((string: String) => string.toUpperCase())

			// Convert a whole column to uppercase with a UDF.
			newDF = oldDF.withColumn("name_upper", udfUppercase(oldDF("name")))
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>		
		
<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/sql-programming-guide.html">Spark DataFrames</a> in the Spark Programming Guide</li>
		<li><bu:rLink id="working-dataframes" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>