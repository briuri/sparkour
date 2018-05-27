<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noRMessage" value="<p>The SparkR library is designed to provide high-level APIs such as Spark DataFrames. Because the low-level Spark Core API was made private in Spark 1.4.0, no R examples are included in this tutorial.</p>" />

<bu:rOverview publishDate="2016-02-29">
	<h3>Synopsis</h3>
	<p>This tutorial explores Resilient Distributed Datasets (RDDs), Spark's primary low-level data structure which
	enables high performance data processing. We use simple programs (in Java, Python, or Scala) to create RDDs
	and experiment with the available transformations and actions from the Spark Core API. Finally, we explore the available
	Spark features for making your application more amenable to distributed processing.</p>
	
	<p>Because the Spark Core API is not exposed in the SparkR library, this tutorial does not include R examples.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />. You can opt to use the EC2 instance we 
			created in <bu:rLink id="installing-ec2" />. If you have stopped and started the instance since the
			previous tutorial, you need to make note of its new dynamic Public IP address.</li>
	</ol>
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will be able to write simple programs that use the Spark Core API to process simple datasets.</li>
		<li>You will understand how to improve the parallelization of your application through RDD persistence and shared variables.</li>
		<li>You will understand the resource constraints associated with distributed processing, such as shuffle operations and closures.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing RDDs</a></li>
		<li><a href="#02">Transformations and Actions</a></li>
		<li><a href="#03">Coding in a Distributed Way</a></li>
		<li><a href="#04">Conclusion</a></li>

	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Introducing RDDs" />

<p>An RDD is an immutable, fault-tolerant collection of objects, logically partitioned across a Spark cluster:</p>

<ul>
	<li><span class="rPN">immutable</span> means that an RDD does not change. When an operation is applied to the RDD, it results in the creation of a new RDD and not the modification
		of the original.</li>
	<li><span class="rPN">fault-tolerant</span> means that an RDD is never in an inconsistent state, even in the face of network and disk failures within the cluster. The
		data is guaranteed to be available and correct. If parts of the data become corrupted, the RDD is regenerated from the source data.</li>
	<li><span class="rPN">collection of objects</span> shows that an RDD is a very generalized data structure. Your RDD might include lists, dictionaries, tuples, or even more
		complex combinations of basic data types.</li>
	<li><span class="rPN">logically partitioned</span> means that the entirety of an RDD is broken down into the subsets of data required for each worker node to perform their assigned
		tasks.</li>
</ul>

<p>A benefit of Spark is that it does the majority of RDD housekeeping for you. You can create and manipulate an RDD based on your original data without needing to worry about which
worker has which partition or writing extra code to recover when a worker crashes unexpectedly. Advanced configuration options are available when you've reached the point where
tuning is required.</p>

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/working-rdds.zip">Download</a> and unzip the example source code for this tutorial. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on our EC2 instance:</li> 

	<bu:rCode lang="bash">
		# Download the working-rdds source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/working-rdds.zip
		
		# Unzip, creating /opt/sparkour/working-rdds
		sudo unzip working-rdds.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. A helper script,
		<span class="rCW">sparkour.sh</span> is included to compile, bundle, and submit applications in all languages.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/working-rdds
				./sparkour.sh java --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/working-rdds
				./sparkour.sh python --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Use shell script to submit source code
				cd /opt/sparkour/working-rdds
				./sparkour.sh r --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Use shell script to compile, bundle, and submit source code
				cd /opt/sparkour/working-rdds
				./sparkour.sh scala --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

</ol>

<h3>Creating an RDD</h3>

<p>RDDs can be built from two forms of source data: existing in-memory collections in your application or external datasets. If you have data (such as
an array of numbers) already available in your application, you can use the <span class="rCW">SparkContext.parallelize()</span> function to create an RDD. 
You can optionally specify the number of partitions (sometimes called slices) as a parameter. This is useful when you want more control over how the job is broken down into tasks
within the cluster.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
	        // Create an array of 1000 random numbers between 0 and 50.
	        List<Integer> numbers = new ArrayList<>();
	        for (int i = 0; i < 1000; i++) {
	            numbers.add(ThreadLocalRandom.current().nextInt(0, 51));
	        }
	
	        // Create an RDD from the numbers array
	        JavaRDD<Integer> numbersListRdd = sc.parallelize(numbers);
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Create an array of 1000 random numbers between 0 and 50.
    		numbers = []
    		for x in range(1000):
        		numbers.append(random.randint(0, 50))
        		
    		# Create an RDD from the numbers array
    		numbersListRdd = spark.sparkContext.parallelize(numbers)
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noRMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
	        // Create an array of 1000 random numbers between 0 and 50.
	        val numbers = Seq.fill(1000)(Random.nextInt(50))
	
	        // Create an RDD from the numbers array
	        val numbersListRdd = spark.sparkContext.parallelize(numbers)
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<p>Alternately, you can create an RDD from an existing file stored elsewhere (such as on your local file system or in HDFS). The API supports several
types of files, including <span class="rCW">SequenceFiles</span> containing key-value pairs, and various Hadoop formats.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
	        // Create an RDD from a similar array on the local filesystem
	        JavaRDD<String> numbersFileRdd = sc.textFile("random_numbers.txt");
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
 			# Create an RDD from a similar array on the local filesystem
    		numbersFileRdd = spark.sparkContext.textFile("random_numbers.txt")
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noRMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
        	// Create an RDD from a similar array on the local filesystem
        	val numbersFileRdd = spark.sparkContext.textFile("random_numbers.txt")
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<bu:rSection anchor="02" title="Transformations and Actions" />

<p>Now that you have an RDD, you can perform data processing operations on the data. Operations are either <span class="rPN">transformations</span>, which
apply some function to an RDD, resulting in the creation of a new RDD, or <span class="rPN">actions</span>, which run some computation and return a value
to the driver running your application. 
Take a look at Spark's <a href="http://spark.apache.org/docs/latest/programming-guide.html#transformations">list of common transformations and actions</a> available
for your data processing needs. The API includes over 80 high-level operators, which greatly decreases the amount of low-level code you need to write to process data.
Here are simplified descriptions of a few key operators:</p>

<ul>
	<li><span class="rCW">map(func)</span>: Passes each element in the source RDD through a function. Setting code aside for a moment, if we had an array of numbers from 1 to 10, and we
		called <span class="rCW">map</span> with a function that subtracted 1 from each element, the result would be a new array of numbers from 0 to 9.</li>
	<li><span class="rCW">filter(func)</span>: Returns just the elements that make the function <span class="rCW">true</span>. If we had a list of barnyard animal types as strings,
		and we called <span class="rCW">filter</span> with a function that checked if an element was a "horse", the result would be a new, smaller list containing only horses.</li>
	<li><span class="rCW">flatMap(func)</span>: Like <span class="rCW">map</span>, but passing each element through a function might result in multiple values.
		If we had a list of 10 complete sentences each containing 4 words, and we called <span class="rCW">flatMap</span> with a function that tokenized each sentence based on whitespace,
		the result would be a list of 40 individual words.</li>
	<li><span class="rCW">reduce(func)</span>: Aggregates an RDD using a comparative function to reduce the RDD to specific elements. If we had an array of numbers, and we called
		<span class="rCW">reduce</span> with a function that compared 2 elements and always returned the higher one, the result would be an array containing just one value: the highest number.</li>
</ul>

<p>You'll notice that many of the operators take a function as a parameter. It may look unfamiliar if you come from a pure Java background and haven't been exposed
to functional programming. This simply allows you to define a stateless reusable function as a prototype that other parts of your code can call without dealing with
instantiation and other object-oriented overhead. A later recipe will cover Lambda Expressions in Java -- this will be a good way to get used to this programming mindset.</p> 

<p>A typical data processing workflow consists of several operators applied to an RDD in sequence. The path from the raw source data to the final action can be referred to
as a chain of operators. Let's create some chains to analyze our created RDDs. To make the example less abstract, pretend that the list of numbers we parallelized is actually a random sample of the number of books in 
1000 households in Chicago, and the file full of numbers is the same sampling in Houston.</p>

<ol>
	<li>First, let's assign the RDDs to new named variables so their function is clearer in the subsequent code. We also need to transform the Houston sample from its original format as a list of string lines into
	a list of integers. This requires one transformation to split the strings up at spaces, and another to convert each token into an integer.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
		        // 1000 Chicago residents: How many books do you own?
		        JavaRDD<Integer> chicagoRdd = numbersListRdd;
		
		        // 1000 Houston residents: How many books do you own?
		        // Must convert from string data to ints first
				JavaRDD<Integer> houstonRdd = numbersFileRdd.flatMap(x -> Arrays.asList(x.split(" ")).iterator())
					.map(x -> Integer.valueOf(x));

			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # 1000 Chicago residents: How many books do you own?
			    chicagoRdd = numbersListRdd
					    
			    # 1000 Houston residents: How many books do you own?
			    # Must convert from file's string data to integers first
			    houstonRdd = numbersFileRdd.flatMap(lambda x: x.split(' ')) \
					.map(lambda x: int(x))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
		        // 1000 Chicago residents: How many books do you own?
		        val chicagoRdd = numbersListRdd
		
		        // 1000 Houston residents: How many books do you own?
		        // Must convert from string data to ints first
		        val houstonRdd = numbersFileRdd.flatMap(x => x.split(' '))
					.map(x => x.toInt)
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>Now, let's analyze the Chicago RDD to see how many households own more than 30 books.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
		        // How many have more than 30 in Chicago?
		        Long moreThanThirty = chicagoRdd.filter(x -> x > 30).count();
		        System.out.println(String.format("%s Chicago residents have more than 30 books.", moreThanThirty));
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
			    # How many have more than 30 in Chicago?
			    moreThanThirty = chicagoRdd.filter(lambda x: x > 30).count()
			    print("{} Chicago residents have more than 30 books.".format(moreThanThirty))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
		        // How many have more than 30 in Chicago?
		        val moreThanThirty = chicagoRdd.filter(x => x > 30).count()
		        println(s"$moreThanThirty Chicago residents have more than 30 books.")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
 
	<li>Remember that transformations always return a new RDD rather than modifying the existing one. Spark is designed so that all transformations are "lazy", and not actually
		executed until an action requires it. This ensures that you can chain transformations together without worrying about overloading your cluster memory or disk with tons of interim RDDs.
		In the examples above, the Spark cluster does not actually execute any transformations until the cumulative chain is needed for the <span class="rCW">count()</span> call.<br /><br />
		Be aware that a parallelized RDD is based on the source data as it was when you first set up the chain of operators. Any changes to the source data after the <span class="rCW">parallelize()</span>
		call will not be reflected in future executions of the chain. However, file-based source data will include changes if the underlying file changed between executions.</li>	
	
	<li>Next, let's see what the maximum number of books is in any household across both cities. We combine the RDDs together, and 
		then use a max function with <span class="rCW">reduce()</span>.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
		        // What's the most number of books in either city?
		        Integer mostBooks = chicagoRdd.union(houstonRdd).reduce((x, y) -> Math.max(x, y));
		        System.out.println(String.format("%s is the most number of books owned in either city.", mostBooks));
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				# What's the most number of books in either city?
			    mostBooks = chicagoRdd.union(houstonRdd).reduce(lambda x, y: x if x > y else y)
			    print("{} is the most number of books owned in either city.".format(mostBooks))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
		        // What's the most number of books in either city?
		        val mostBooks = chicagoRdd.union(houstonRdd).reduce((x, y) => if (x > y) x else y)
		        println(s"$mostBooks is the most number of books owned in either city.")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>Finally, let's see how many total books were counted in our city polls. We combine the RDDs together and then use an add function with <span class="rCW">reduce()</span>. 
		In Python, the <span class="rCW">add</span> function is a built-in function we can import from the <span class="rCW">operator</span> package.</li>
			
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
		        // What's the total number of books in both cities?
		        Integer totalBooks = chicagoRdd.union(houstonRdd).reduce((x, y) -> x + y);
		        System.out.println(String.format("%s books in both cities.", totalBooks));
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				# What's the total number of books in both cities?
			    totalBooks = chicagoRdd.union(houstonRdd).reduce(add)
				print("{} books in both cities.".format(totalBooks))
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noRMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
		        // What's the total number of books in both cities?
		        val totalBooks = chicagoRdd.union(houstonRdd).reduce((x, y) => x + y)
		        println(s"$totalBooks books in both cities.")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>Feel free to modify this application to experiment with different Spark operators or functions.</li>
</ol>

<bu:rSection anchor="03" title="Coding in a Distributed Way" />

<p>Spark data processing pipelines can be represented as a graph of transformations and actions without any infinite loops, 
known as a <a href="https://en.wikipedia.org/wiki/Directed_acyclic_graph">directed acyclic graph (DAG)</a>. The graph for our example application
is very simple, shown in the image below. We start with our raw source data (in grey) which we use to do 3 separate analyses of the data. 
Our code sets up a chain of transformations (in blue) which are not
acted upon until we reach an action step (in orange). We then print out the result of the action.</p>

<img src="${localImagesUrlBase}/dag.png" width="750" height="339" title="Spark processing can be modeled as a directed acyclic graph." class="diagram border" />

<p>By default, the entire chain of transformations (starting from the source data) is executed to compute a result for an action, even if some steps were previously
executed for an earlier action. As you can see from our graph, there are many transformation steps that are shared between our 3 analyses. 
We can explicitly identify steps that should be persisted or cached so they can be reused later.</p>

<p>For example, the RDD created by applying the <span class="rCW">union</span> operator is used in 2 separate analyses. We can refactor our application to persist this RDD,
so that Spark caches and reuses it later instead of recomputing every earlier step.</p>   

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Tell Spark to persist this RDD
			JavaRDD<Integer> unionRdd = chicagoRdd.union(houstonRdd).persist();
			
	        // What's the most number of books in either city?
	        Integer mostBooks = unionRdd.reduce((x, y) -> Math.max(x, y));
	        System.out.println(String.format("%s is the most number of books owned in either city.", mostBooks));
	        
	        // What's the total number of books in both cities?
	        Integer totalBooks = unionRdd.reduce((x, y) -> x + y);
	        System.out.println(String.format("%s books in both cities.", totalBooks));	        
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Tell Spark to persist this RDD
			unionRdd = chicagoRdd.union(houstonRdd).persist()
			
			# What's the most number of books in either city?
		    mostBooks = unionRdd.reduce(lambda x, y: x if x > y else y)
		    print("{} is the most number of books owned in either city.".format(mostBooks))
		    
			# What's the total number of books in both cities?
		    totalBooks = unionRdd.reduce(add)
			print("{} books in both cities.".format(totalBooks))
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noRMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Tell Spark to persist this RDD
			val unionRdd = chicagoRdd.union(houstonRdd).persist()
			
	        // What's the most number of books in either city?
	        val mostBooks = unionRdd.reduce((x, y) => if (x > y) x else y)
	        println(s"$mostBooks is the most number of books owned in either city.")
	        
			// What's the total number of books in both cities?
	        val totalBooks = unionRdd.reduce((x, y) => x + y)
	        println(s"$totalBooks books in both cities.")
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<p><span class="rCW">persist()</span> is a chainable call that we could have simply inserted into the <span class="rCW">mostBooks</span> chain. However, 
refactoring the code to insert a common variable in both chains makes our intent clear and results in better code readability.</p>
	
<p>You can optionally set a <span class="rPN">Storage Level</span> as a parameter to <span class="rCW">persist()</span> for more control over the caching strategy. Spark 
offers <a href="http://spark.apache.org/docs/latest/programming-guide.html#rdd-persistence">several strategies</a> with different trade-offs between resources and performance.
By default, Spark persists as much of the RDD in memory as possible, and recomputes the rest based on the chain of defined operators whenever the rest is needed. You can also 
serialize your in-memory RDDs as byte arrays or allow them to spill over onto disk. The best strategy to use depends on your data processing needs and the amount of memory, CPU, and disk
resources available in your cluster.</p>

<p>Spark periodically performs garbage collection on the least recently used RDDs in the cache (remember, they can always be regenerated based on the source data and the chain of operators). You
can also explicitly call <span class="rCW">unpersist()</span> when you no longer need the RDD.</p>

<h3>Closures and Shared Variables</h3>

<p>If you've ever had to implement a multithreaded application, you know that it's dangerous to make assumptions about what variables are visible (and in what scope) across the parallel threads.
An application that seems to work fine locally may exhibit hard-to-troubleshoot behaviors when run in parallel. This pitfall doesn't go away in Spark, and is particularly dangerous if you tend to do all
of your testing in Local mode.</p>

<p>When a job is submitted, Spark calculates a <span class="rPN">closure</span> consisting of all of the variables and methods required for a single executor to perform operations on an RDD,
and then sends that closure to each worker node. In Local mode, there is only one executor, so the same closure is shared across your application. 
When this same application is run in parallel on a cluster, each worker has a separate closure and their own copies of variables and methods. 
A common example of a potential issue is creating a counter variable in your application and incrementing it. 
In Local mode, the counter accurately updates based on the work done in the local threads. On a cluster, however,
each worker has its own copy of the counter.</p>

<p>Spark provides a helpful set of shared variables to ensure that you can safely code in a distributed way.</p>  

<ul>
	<li><span class="rPN">Broadcast variables</span> are read-only variables that are efficiently delivered to worker nodes and cached for use on many tasks. Broadcast variables are implemented
		as wrappers around arbitrary data, making it easy to use them in lieu of directly calling on the wrapped local data. These are explored in the recipe,
		<bu:rLink id="broadcast-variables" />.</li>
	<li><span class="rPN">Accumulators</span> are shared, writeable variables that allow safe, parallel writing. Worker nodes can write to the accumulator without any special precautions, and the
		driver containing the application can read the current value. The simplest accumulator might be an incremental counter, but custom accumulators allow you to do things like
		concatenating a string from tokens provided by each worker node. Accumulators are explored in the recipe, <bu:rLink id="aggregating-accumulators" />.</li>
</ul> 

<h3>Shuffle Operations</h3>

<p>When you create an RDD, the data is logically partitioned and distributed across the cluster. However, some transformations and actions may result in a new RDD for which the old partitioning no longer
makes sense. In these situations, the entirety of the data needs to be repartitioned and distributed for optimal task execution. This operation, known as a <span class="rPN">shuffle</span> involves
both network and disk operations as well as data serialization, so it is complex and costly. Examples of operations that trigger a shuffle include
<span class="rCW">coalesce</span>, <span class="rCW">groupByKey</span>, and <span class="rCW">join</span>.</p>

<p>Initially, you should just be aware that some operations are more costly than others. When the time comes to profile or tune your workload, there are 
<a href="http://spark.apache.org/docs/latest/configuration.html#shuffle-behavior">configuration properties</a> available to make shuffle operations more manageable.</p>

<bu:rSection anchor="04" title="Conclusion" />	

<p>Congratulations! You have now programmed a simple application against the Spark Core API to process small datasets. The patterns and practices from this tutorial apply across
all of the Spark components (e.g. Spark SQL and MLlib). In practice, you will probably end up using the high-level Spark components more often than the Core API.</p>

<p>This is the final sequential tutorial, and you are now ready to dive into one of the more targeted recipes that focus on specific
aspects of Spark use. The recipe, <bu:rLink id="working-dataframes" />, is a good next step to consider.
If you are done playing with Spark for now, make sure that you stop your EC2 instance so you don't incur unexpected charges. If you no longer need your EC2 instance,
make sure to terminate it so you also stop incurring charges for the attached EBS Volume.</p>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/api.html">Spark API Documentation</a></li>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#resilient-distributed-datasets-rdds">Resilient Distributed Datasets</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#transformations">Transformations and Actions</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#rdd-persistence">RDD Persistence</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#shared-variables">Shared Variables</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#shuffle-operations">Shuffle Operations</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#understanding-closures-a-nameclosureslinka">Understanding Closures</a> in the Spark Programming Guide</li>	
		<li><a href="https://www.cs.berkeley.edu/~matei/papers/2012/nsdi_spark.pdf">Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing</a></li>
		<li><a href="https://databricks.com/blog/2016/07/14/a-tale-of-three-apache-spark-apis-rdds-dataframes-and-datasets.html">A Tale of Three Apache Spark APIs: RDDs, DataFrames, and Datasets</a></li>
		<li><bu:rLink id="broadcast-variables" /></li>
		<li><bu:rLink id="aggregating-accumulators" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>