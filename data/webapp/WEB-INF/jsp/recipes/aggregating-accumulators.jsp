<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noRMessage" value="<p>Accumulators are not yet available in SparkR.</p>" />

<bu:rOverview publishDate="2016-05-07">
	<h3>Synopsis</h3>
	<p>This recipe explains how to use accumulators to aggregate results in a Spark application.
	Accumulators provide a safe way for multiple Spark workers to contribute information to
	a shared variable, which can then be read by the application driver.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>The example code used in this recipe is written for Spark <span class="rPN">2.0.x</span> or higher
			to take advantage of the latest Accumulator API changes.
			You may need to make modifications to use it on an older version of Spark.</li>	
		<li> The Python examples still uses the older API because PySpark did not support the new 
			<span class="rCW">AccumulatorV2</span> enhancements until Spark 2.1.0 
			(see the <a href="https://issues.apache.org/jira/browse/SPARK-16861">SPARK-16861</a> ticket). I will update
			this recipe soon -- you can track the progress of this work in the 
			<a href="https://ddmsence.atlassian.net/browse/SPARKOUR-24">SPARKOUR-24</a> ticket.</li>
		<li>The SparkR API does not yet support accumulators at all. You can track the progress of this work in the
			<a href="https://issues.apache.org/jira/browse/SPARK-6815">SPARK-6815</a> ticket.</li>  
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing Accumulators</a></li>
		<li><a href="#02">Using Accumulators</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Introducing Accumulators" />

<p>Accumulators are a built-in feature of Spark that allow multiple workers to write to a shared variable. 
When a job is submitted, Spark calculates a <span class="rPN">closure</span> consisting of all of the variables and methods required for a 
single executor to perform operations, and then sends that closure to each worker node. Without accumulators, each worker has its own
local copy of the variables in your application. This could lead to unexpected results if you are trying to aggregate data from all of the workers,
such as counting the number of failed records processed across the cluster.</p>

<p>Out of the box, Spark provides an accumulator that can aggregate numeric data, suitable for counting and sum use cases. You can also create custom 
accumulators for other data types. You should consider using accumulators under the following conditions:</p>

<ul>
	<li>You need to collect some simple data across all worker nodes as a side effect of normal Spark operations, such as statistics about the work being performed
		or errors encountered.</li>
	<li>The operation used to aggregate this data is both <a href="https://en.wikipedia.org/wiki/Associative_property">associative</a>
		and <a href="https://en.wikipedia.org/wiki/Commutative_property">commutative</a>. In a distributed processing pipeline, the order and grouping of
		the data contributed by each worker cannot be guaranteed.</li>
	<li>You do not need to read the data until all tasks have completed. Although any worker can write to an accumulator, only the application driver
		can see its value. Because of this, accumulators are not good candidates for monitoring task progress or 
		live statistics.</li>
</ul>

<p>Accumulators can be used in Spark transformations or actions, and obey the execution rules of the enclosing operation. 
Remember that transformations are "lazy" and not executed until your processing pipeline has reached an action. Because of this,
an accumulator employed inside a transformation is not actually touched until a subsequent action is triggered.</p>

<p>You should limit your use of accumulators to Spark actions for several reasons. For one, Spark guarantees that an accumulator 
employed in an action runs exactly one time, but no such guarantee covers accumulators in transformations. If a task fails for
a hardware reason and is then re-executed, you might get duplicate values (or no value at all) written to an accumulator inside a transformation.
Spark also employs <span class="rPN">speculative execution</span> (duplicating a task on a free worker in case a slow-running worker fails) which
could introduce duplicate accumulator data outside of an action.</p> 

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/aggregating-accumulators.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the aggregating-accumulators source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/aggregating-accumulators.zip
		
		# Unzip, creating /opt/sparkour/aggregating-accumulators
		sudo unzip aggregating-accumulators.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. 
		A helper script, <span class="rCW">sparkour.sh</span> is included to compile, bundle, and submit applications in all languages.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/aggregating-accumulators
				./sparkour.sh java --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/aggregating-accumulators
				./sparkour.sh python --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/aggregating-accumulators
				./sparkour.sh scala --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>The <span class="rCW">heights.json</span> file contains a very simple dataset of person names and heights in inches. Some of the values
		are questionable, possibly due to poor data entry or even poorer metric conversion. We use accumulators to get some statistics on
		the values that might be incorrect.</li>
	
	<bu:rCode lang="plain">
		{"name":"Alex","height":61}
		{"name":"Brian","height":64}
		{"name":"Charlene","height":85}
		{"name":"Donald","height":1}
		{"name":"Elizabeth","height":62}
		{"name":"Freddie","height":54}
		{"name":"Geraldine","height":56}
		{"name":"Hagrid","height":102}
	</bu:rCode>
</ol>

<bu:rSection anchor="02" title="Using Accumulators" />

<p>The example source code uses accumulators to provide some quick diagnostic information about the height dataset. 
We validate the data to count how many rows might be incorrect and then print out a simple string containing all of the
questionable values. (With a larger set of real data, this type of validation could be done more dynamically with statistical analysis or machine learning).</p>

<ol>
	<li>To count questionable rows, we use the built-in number-based accumulator, which supports addition with
		Integers, Doubles, Longs, and Floats.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Create an accumulator to count how many rows might be inaccurate.
				LongAccumulator heightCount = spark.sparkContext().longAccumulator();
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				# Create an accumulator to count how many rows might be inaccurate.
				heightCount = spark.sparkContext.accumulator(0)
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Create an accumulator to count how many rows might be inaccurate.
				val heightCount = spark.sparkContext.longAccumulator
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>To print out the questionable values, we create a custom accumulator that performs
		string concatenation. This is a contrived example to demonstrate the syntax, and
		should not be used in a real-world solution. It has multiple flaws, including the
		fact that it is not commutative ("a" + "b" is not the same as "b" + "a"), it
		has performance issues at scale, and it could grow very large (claiming the resources
		you need for your actual Spark processing).</li> 
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				/**
				 * A custom accumulator for string concatenation
				 *
				 * Contrived example -- see recipe for caveats. The built-in
				 * CollectionAccumulator does something similar but more elegantly.
				 */
				public class StringAccumulator extends AccumulatorV2<String, String> {
				
					private String _value = "";
				
					public StringAccumulator() {
						this("");
					}
				
					public StringAccumulator(String initialValue) {
						if (initialValue != null) {
							_value = initialValue;
						}
					}
				
					public void add(String value) {
						_value = value() + " " + value.trim();
					}
				
					public StringAccumulator copy() {
						return (new StringAccumulator(value()));
					}
				
					public boolean isZero() {
						return (value().length() == 0);
					}
				
					public void merge(AccumulatorV2<String, String> other) {
						add(other.value());
					}
				
					public void reset() {
						_value = "";
					}
				
					public String value() {
						return (_value);
					}
				}
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				# Create a custom accumulator for string concatenation
				# Contrived example -- see recipe for caveats.
				class StringAccumulatorParam(AccumulatorParam):
				    def zero(self, initialValue=""):
				        return ""
				
				    def addInPlace(self, s1, s2):
				        return s1.strip() + " " + s2.strip()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				/**
				 * A custom accumulator for string concatenation
				 *
				 * Contrived example -- see recipe for caveats. The built-in
				 * CollectionAccumulator does something similar but more elegantly.
				 */
				class StringAccumulator(private var _value: String) extends AccumulatorV2[String, String] {
				
					def this() {
						this("")
					}
				
					override def add(newValue: String): Unit = {
						_value = value + " " + newValue.trim
					}
				
					override def copy(): StringAccumulator = {
						new StringAccumulator(value) 
					}
				
					override def isZero(): Boolean = {
						value.length() == 0
					}
				
					override def merge(other: AccumulatorV2[String, String]): Unit = {
						add(other.value)
					}
				
					override def reset(): Unit = {
						_value = ""
					}
				
					override def value(): String = {
						_value
					}
				}
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>				
	
	<li>The Java and Scala custom accumulators extend from the new <span class="rCW">AccumulatorV2</span>
	abstract class, while the Python approach uses the older, deprecated <span class="rCW">AccumulatorParam</span>
	interface. With a custom accumulator defined, we can use it in our application.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Create an accumulator to store all questionable values.
				StringAccumulator heightValues = new StringAccumulator();
				spark.sparkContext().register(heightValues);
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create an accumulator to store all questionable values.
			    heightValues = spark.sparkContext.accumulator("", StringAccumulatorParam())
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Create an accumulator to store all questionable values.
				val heightValues = new StringAccumulator()
				spark.sparkContext.register(heightValues)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>	
	
	<li>Next, we define a function that takes a row from a Spark DataFrame and validates the <span class="rCW">height</span>
		field. If the height is less than 15 inches or greater than 84 inches, we suspect that the data might be invalid and
		record it to our accumulators.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// A function that checks for questionable values
				VoidFunction<Row> validate = new VoidFunction<Row>() {
					public void call(Row row) {
						Long height = row.getLong(row.fieldIndex("height"));
						if (height < 15 || height > 84) {
							heightCount.add(1);
							heightValues.add(String.valueOf(height));
						}
					}
				};
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				# Create a function that checks for questionable values.
				def validate(row):
				    height = row.height
				    if (height < 15 or height > 84):
				        heightCount.add(1)
				        heightValues.add(str(height))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// A function that checks for questionable values
				def validate(row: Row) = {
					val height = row.getLong(row.fieldIndex("height"))
					if (height < 15 || height > 84) {
						heightCount.add(1)
						heightValues.add(height.toString)
					}
				}
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>We then create a DataFrame containing our height data and validate it with the <span class="rCW">validate</span> function.
		A DataFrame is used instead of an RDD here to simplify the initialization boilerplate code. 
		If you are unfamiliar with DataFrames, you can learn more about them in <bu:rLink id="working-dataframes" />.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Create a DataFrame from a file of names and heights in inches.
				Dataset<Row> heightDF = spark.read().json("heights.json");
		
				// Validate the data with the function.
				heightDF.javaRDD().foreach(validate);
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Create a DataFrame from a file of names and heights in inches.
			    heightDF = spark.read.json("heights.json")
			
			    # Validate the data with the function.
			    heightDF.foreach(lambda x : validate(x))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Create a DataFrame from a file of names and heights in inches.
				val heightDF = spark.read.json("heights.json")
		
				// Validate the data with the function.
				heightDF.foreach(validate)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		
		
	<li>Because <span class="rCW">foreach</span> is a Spark action, we can trust that our accumulators
		have been written to after that line of code. We then print out the values to the console.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				// Show how many questionable values were found and what they were.
				System.out.println(String.format("%d rows had questionable values.", heightCount.value()));
				System.out.println(String.format("Questionable values: %s", heightValues.value()));
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # Show how many questionable values were found and what they were.
			    print("{} rows had questionable values.".format(heightCount.value))
			    print("Questionable values: {}".format(heightValues.value))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				// Show how many questionable values were found and what they were.
				println(s"${heightCount.value} rows had questionable values.")
				println(s"Questionable values: ${heightValues.value}")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>			
	
	<bu:rCode lang="plain">
		3 rows had questionable values.
		Questionable values: 102 85 1
	</bu:rCode>
	
	<li>The order of numbers may be different on different runs, because the order that the worker nodes write
		to the accumulators is not guaranteed. This is why it's important that you use accumulators for
		operations that are both associative and commutative, such as incrementing a counter, calculating a sum, or
		calculating a max value.</li> 
</ol>

<p>Experienced Spark developers might recognize that accumulators were not truly necessary to figure out which height values
might be questionable. The validation algorithm could just as easily been done with basic Spark transformations and actions,
resulting in a new DataFrame containing just the questionable rows.</p>

<p>A good rule of thumb to follow is to use accumulators
only for data you would consider to be a side effect of your main data processing application. For example, if
you are exploring a new dataset and need some simple diagnostics to further guide your data cleansing operations, accumulators
are very useful. However, if you are writing an application whose sole purpose is to test the quality of a dataset and the results are the whole point,
full-fledged Spark operations might be more appropriate.</p> 

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#accumulators">Accumulators</a> in the Spark Programming Guide</li>
		<li><a href="http://imranrashid.com/posts/Spark-Accumulators/">Spark Accumulators, What Are They Good For?</a></li>
		<li><bu:rLink id="working-dataframes" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>