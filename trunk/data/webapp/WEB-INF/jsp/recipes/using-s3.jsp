<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noJavaMessage" value="There is no interactive shell available for Java." />

<bu:rOverview publishDate="2016-03-06">
	<h3>Synopsis</h3>
	<p>This recipe provides the steps needed to securely connect an Apache Spark cluster running on Amazon Elastic Compute Cloud (EC2) 
	to data stored in Amazon Simple Storage Service (S3). It contains instructions for both the classic <span class="rCW">s3n</span>
	protocol and the newer, but still maturing, <span class="rCW">s3a</span> protocol. Coordinating the versions of the various required
	libraries is the most difficult part -- writing application code for S3 is very straightforward.</p>

	<h3>Prerequisites</h3>
	<ol>
		<li>You need a working Spark cluster, as described in <bu:rLink id="spark-ec2" />.<ul>
			<li>For the <span class="rCW">s3n</span> protocol, the cluster must be configured with the <span class="rK">--copy-aws-credentials</span> parameter.</li>
			<li>For the <span class="rCW">s3a</span> protocol, the cluster must be configured with an Identity & Access Management (IAM) Role
				via <span class="rK">--instance-profile-name</span>.</li>
		</ul></li>
		<li>You need an access-controlled S3 bucket available for Spark consumption, as described in <bu:rLink id="configuring-s3" />.<ul>
			<li>For the <span class="rCW">s3n</span> protocol, the bucket must have a bucket policy granting access to the owner of the access keys.</li>
			<li>For the <span class="rCW">s3a</span> protocol, the IAM Role of the cluster instances must have a policy granting access to the bucket.</li>
		</ul></li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>Spark depends on Apache Hadoop and Amazon Web Services (AWS) for libraries that communicate with Amazon S3. 
			As such, <span class="rPN">any version</span> of Spark should work with this recipe.</li>
		<li>Apache Hadoop started supporting the <span class="rCW">s3n</span> protocol in version 0.18.0, so any recent version should suffice.
			The <span class="rCW">s3a</span> protocol was introduced in version 
			<a href="https://issues.apache.org/jira/browse/HADOOP-10400">2.6.0</a>, but is still maturing. 
			Several important issues were corrected in <a href="https://issues.apache.org/jira/browse/HADOOP-11571">2.7.0</a>,
			and even more are planned in the not-yet-released <a href="https://issues.apache.org/jira/browse/HADOOP-11694">2.8.0</a>. 
			You should consider <span class="rPN">2.7.0</span> to be the minimum recommended version.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">S3 Support in Spark</a></li>
		<li><a href="#02">Testing the Protocols</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="S3 Support in Spark" />

<p>There are no S3 libraries in the core Apache Spark project. Spark uses libraries from Hadoop to connect to S3, and the integration between Spark, Hadoop, and the 
AWS services is very much a work in progress. Hadoop offers 3 protocols for working with Amazon S3's REST API, and the protocol you select for your
application is a trade-off between maturity, security, and performance.</p>

<ol>
	<li>The <span class="rCW">s3</span> protocol is supported in Hadoop, but does not work with Apache Spark unless you are using the AWS version of Spark in Elastic MapReduce (EMR).
		We can safely ignore this protocol for now.</li>
	<li>The <span class="rCW">s3n</span> protocol is Hadoop's older protocol for connecting to S3. Implemented with a third-party library (JetS3t), it provides rudimentary support
	for files up to 5 GB in size and uses AWS secret API keys to run. This "shared secret" approach is brittle, and no longer the preferred best practice within AWS. It also conflates
	the concepts of users and roles, as the worker node communicating with S3 presents itself as the person tied to the access keys.</li>
	<li>The <span class="rCW">s3a</span> protocol is successor to <span class="rCW">s3n</span> but is not mature yet. Implemented directly on top of AWS APIs, it is faster, handles files up to
	5 TB in size, and supports authentication with Identity and Access Management (IAM) Roles. With IAM Roles, you assign an IAM Role to your worker nodes and then attach policies
	granting access to your S3 bucket. If you want to use this protocol with an older version of Hadoop, you might find success by downloading specific JAR files from a 2.7.x 
	distribution, as described in this recipe. For example, the Spark cluster created with the <span class="rCW">spark-ec2</span> script only supports 
	Hadoop 2.4 right now, so if you built your cluster with that script, additional JAR files are necessary.</li>
</ol>

<p>S3 can be incorporated into your Spark application wherever a string-based file path is accepted in the code. An example of each protocol (using the bucket name, 
<span class="rCW">sparkour-data</span>) is shown below.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			// Initialize the session
			SparkSession spark = SparkSession.builder().appName("JUsingS3").getOrCreate();
			JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());
			
	        // Create an RDD from a file in the working directory
	        JavaRDD<String> localRdd = sc.textFile("random_numbers.txt");
	        
	        // Create an RDD from a file in S3 using the s3n protocol
	        JavaRDD<String> s3nRdd = sc.textFile("s3n://sparkour-data/random_numbers.txt");
	        
	        // Create an RDD from a file in S3 using the s3a protocol
	        JavaRDD<String> s3aRdd = sc.textFile("s3a://sparkour-data/random_numbers.txt");
	        
	        // Save data to S3 using the s3n protocol
	        localRdd.saveAsTextFile("s3n://sparkour-data/output-path/");
	        
	        // Save data to S3 using the s3a protocol
	        localRdd.saveAsTextFile("s3a://sparkour-data/output-path/");
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			# Initialize the session
			spark = SparkSession.builder.appName("using_s3").getOrCreate()
			
 			# Create an RDD from a file in the working directory
    		localRdd = spark.sparkContext.textFile("random_numbers.txt")
    		
    		# Create an RDD from a file in S3 using the s3n protocol
    		s3nRdd = spark.sparkContext.textFile("s3n://sparkour-data/random_numbers.txt")
    		
    		# Create an RDD from a file in S3 using the s3a protocol
    		s3aRdd = spark.sparkContext.textFile("s3a://sparkour-data/random_numbers.txt")
    		
    		# Save data to S3 using the s3n protocol
	        localRdd.saveAsTextFile("s3n://sparkour-data/output-path/")
	        
	        # Save data to S3 using the s3a protocol
	        localRdd.saveAsTextFile("s3a://sparkour-data/output-path/")
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="plain">
			# Create a SparkR DataFrame from a local text file
			localRdd <- read.df(sqlContext, "data.json")
			
			# Create a SparkR DataFrame from a file in S3 using the s3n protocol
			s3nRdd <- read.df(sqlContext, "s3n://sparkour-data/data.json")
			
			# Create a SparkR DataFrame from a file in S3 using the s3a protocol
			s3aRdd <- read.df(sqlContext, "s3a://sparkour-data/data.json")
			
			# Save as Parquet file using the s3n protocol
			write.df(localRdd, "s3n://sparkour-data/data.parquet")
			
			# Save as Parquet file using the s3a protocol
			write.df(localRdd, "s3a://sparkour-data/data.parquet")			
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			// Initialize the session
			val spark = SparkSession.builder.appName("SUsingS3").getOrCreate()
			
	        // Create an RDD from a file in the working directory
        	val localRdd = sc.textFile("random_numbers.txt")
        	
        	// Create an RDD from a file in S3 using the s3n protocol
        	val s3nRdd = sc.textFile("s3n://sparkour-data/random_numbers.txt")
        	
        	// Create an RDD from a file in S3 using the s3a protocol
        	val s3aRdd = sc.textFile("s3a://sparkour-data/random_numbers.txt")
        	
    		# Save data to S3 using the s3n protocol
	        localRdd.saveAsTextFile("s3n://sparkour-data/output-path/")
	        
	        # Save data to S3 using the s3a protocol
	        localRdd.saveAsTextFile("s3a://sparkour-data/output-path/")
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<p>Some Spark tutorials show AWS access keys hardcoded into the file paths. This is a horribly insecure approach and should never be done. Use exported environment variables or IAM Roles instead,
as described in <bu:rLink id="configuring-s3" />.</p>

<h3>Advanced Configuration</h3>

<p>The Hadoop libraries expose <a href="https://hadoop.apache.org/docs/stable/hadoop-aws/tools/hadoop-aws/index.html">additional configuration properties</a>
for more fine-grained control of S3. To maximize your security, you should not use any of the Authentication properties that require you to write secret keys
to a properties file.</p>

<bu:rSection anchor="02" title="Testing the Protocols" />

<p>The simplest way to confirm that your Spark cluster is handling S3 protocols correctly is to point a Spark interactive shell 
at the cluster and run a simple chain of operators. You can either start up an interactive shell on your development environment 
or SSH into the master node of the cluster. You should have already tested your authentication credentials, as described in 
<bu:rLink id="configuring-s3" />, so you can focus any troubleshooting efforts solely on the Spark and Hadoop side of the equation.</p> 

<ol>
	<li>Start the shell. Your secret keys or IAM Role should already be configured within the cluster.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /> Here is how you would run an application with the <span class="rCW">spark-submit</span> script.</p>
			<bu:rCode lang="bash">
				# Submit an application to a Spark cluster	
				$SPARK_HOME/bin/spark-submit \
					--master spark://ip-172-31-24-101:7077 \
					--class buri.sparkour.ImaginaryApplication bundledAssembly.jar applicationArgs
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">		
				# Start the shell, pointing at a Spark cluster	
				$SPARK_HOME/bin/pyspark --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">				
				# Start the shell, pointing at a Spark cluster	
				$SPARK_HOME/bin/sparkR --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">				
				# Start the shell, pointing at a Spark cluster
				$SPARK_HOME/bin/spark-shell --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>Once the shell has started, pull a file from your S3 bucket and run a simple action on it. 
		Remember that transformations are lazy, so simply calling <span class="rCW">textFile()</span> 
		on a file path does not actually do anything until a subsequent action. Use either <span class="rCW">s3n</span> or <span class="rCW">s3a</span>
		as a path prefix, depending on which protocol your cluster is configured for.</li>
				
	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /> Here is how you would run this test inside an application.</p>
			<bu:rCode lang="java">
				// s3n Test
				JavaRDD<String> textFile = sc.textFile("s3n://sparkour-data/myfile.txt");
				System.out.println(textFile.count());
				textFile.saveAsTextFile("s3n://sparkour-data/s3n-output-path/");
				
				// s3a Test
				JavaRDD<String> textFile2 = sc.textFile("s3a://sparkour-data/myfile.txt");
				System.out.println(textFile2.count());
				textFile2.saveAsTextFile("s3a://sparkour-data/s3a-output-path/");
			</bu:rCode>			
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				>>> # s3n Test
				>>> textFile = sc.textFile("s3n://sparkour-data/myfile.txt")
				>>> textFile.count()
				>>> textFile.saveAsTextFile("s3n://sparkour-data/s3n-output-path/")
				
				>>> # s3a Test
				>>> textFile = sc.textFile("s3a://sparkour-data/myfile.txt")
				>>> textFile.count()
				>>> textFile.saveAsTextFile("s3a://sparkour-data/s3a-output-path/")
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<p>The low-level Spark Core API containing <span class="rCW">textFile()</span> is not available in R, so we
			try to create a DataFrame instead. You should upload 
			<a href="${filesUrlBase}/using-s3-dataframe.json">a simple JSON dataset</a> to your S3 bucket for use in this test.</p>
			<bu:rCode lang="plain">
				> # s3n Test
				> people <- read.df("s3n://sparkour-data/using-s3-dataframe.json", "json")
				> head(people)
				> write.df(people, "s3n://sparkour-data/using-s3-dataframe.s3n.parquet")
				
				> # s3a Test
				> people <- read.df("s3a://sparkour-data/using-s3-dataframe.json", "json")
				> head(people)
				> write.df(people, "s3a://sparkour-data/using-s3-dataframe.s3a.parquet")
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				scala> # s3n Test
				scala> val textFile = sc.textFile("s3n://sparkour-data/myfile.txt")
				scala> textFile.count()
				scala> textFile.saveAsTextFile("s3n://sparkour-data/s3n-output-path/")
				
				scala> # s3a Test
				scala> val textFile = sc.textFile("s3a://sparkour-data/myfile.txt")
				scala> textFile.count()
				scala> textFile.saveAsTextFile("s3a://sparkour-data/s3a-output-path/")
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>After the code executes, check the S3 bucket via the AWS Management Console. You should see the newly saved file in the bucket. If the code ran successfully, you
		are ready to use S3 in your real application.</li>
	<li>If the code fails, it will likely fail for one of the reasons described below.</li>
</ol>

<h3>No FileSystem for scheme: s3n</h3>

<bu:rCode lang="plain">
	java.io.IOException: No FileSystem for scheme: s3n
</bu:rCode>

<p>This message appears when dependencies are missing from your Apache Spark distribution.
If you see this error message, you can use the <span class="rK">--packages</span>
parameter and Spark will use Maven to locate the missing dependencies and distribute them
to the cluster. Alternately, you can use <span class="rK">--jars</span> if you manually downloaded the dependencies already.
These parameters also works on the <span class="rCW">spark-submit</span> script.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<p><c:out value="${noJavaMessage}" escapeXml="false" /> Here is how you would run an application with the <span class="rCW">spark-submit</span> script.</p>
		<bu:rCode lang="bash">
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--packages com.amazonaws:aws-java-sdk-pom:1.10.34,org.apache.hadoop:hadoop-aws:2.7.2 \
				--class buri.sparkour.ImaginaryApplication bundledAssembly.jar applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="bash">
			$SPARK_HOME/bin/pyspark --master spark://ip-172-31-24-101:7077 \
				--packages com.amazonaws:aws-java-sdk-pom:1.10.34,org.apache.hadoop:hadoop-aws:2.7.2
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="bash">
			$SPARK_HOME/bin/sparkR --master spark://ip-172-31-24-101:7077 \
				--packages com.amazonaws:aws-java-sdk-pom:1.10.34,org.apache.hadoop:hadoop-aws:2.7.2
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="bash">
			$SPARK_HOME/bin/spark-shell --master spark://ip-172-31-24-101:7077 \
				--packages com.amazonaws:aws-java-sdk-pom:1.10.34,org.apache.hadoop:hadoop-aws:2.7.2
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<h3>Class org.apache.hadoop.fs.s3a.S3AFileSystem not found</h3>

<bu:rCode lang="plain">
	java.lang.ClassNotFoundException: Class org.apache.hadoop.fs.s3a.S3AFileSystem not found
</bu:rCode>

<p>This message appears when dependencies are missing from your Apache Spark distribution.
<p>If you see this error message, you should download a recent Hadoop 2.7.x distribution and 
unzip it in your development environment to get the necessary JAR files. This workaround requires
a specific, older version of an AWS JAR (1.7.4) that might not be available in the EC2 Maven Repository, 
so the <span class="rK">--packages</span> parameter is not a good solution. 
Instead, we use <span class="rK">--jars</span> to point to our manually downloaded dependencies.
This parameter also works on the <span class="rCW">spark-submit</span> script.</p>
	
<bu:rTabs>
	<bu:rTab index="1">
		<p><c:out value="${noJavaMessage}" escapeXml="false" /> Here is how you would run an application with the <span class="rCW">spark-submit</span> script.</p>
		<bu:rCode lang="bash">
			# Set environment variables for readability
			export HADOOP_HOME=/opt/hadoop-2.7.2
			export LIB_PATH=share/hadoop/tools/lib
			
			# Submit an application with extra JAR dependencies
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--jars $HADOOP_HOME/$LIB_PATH/aws-java-sdk-1.7.4.jar,$HADOOP_HOME/$LIB_PATH/hadoop-aws-2.7.2.jar \
				--class buri.sparkour.ImaginaryApplication bundledAssembly.jar applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="bash">
			# Set environment variables for readability
			export HADOOP_HOME=/opt/hadoop-2.7.2
			export LIB_PATH=share/hadoop/tools/lib
			
			# Run shell with extra JAR dependencies 
			$SPARK_HOME/bin/pyspark --master spark://ip-172-31-24-101:7077 \
				--jars $HADOOP_HOME/$LIB_PATH/aws-java-sdk-1.7.4.jar,$HADOOP_HOME/$LIB_PATH/hadoop-aws-2.7.2.jar
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="bash">
			# Set environment variables for readability
			export HADOOP_HOME=/opt/hadoop-2.7.2
			export LIB_PATH=share/hadoop/tools/lib
			
			# Run shell with extra JAR dependencies
			$SPARK_HOME/bin/sparkR --master spark://ip-172-31-24-101:7077 \
				--jars $HADOOP_HOME/$LIB_PATH/aws-java-sdk-1.7.4.jar,$HADOOP_HOME/$LIB_PATH/hadoop-aws-2.7.2.jar
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="bash">
			# Set environment variables for readability
			export HADOOP_HOME=/opt/hadoop-2.7.2
			export LIB_PATH=share/hadoop/tools/lib
			
			# Run shell with extra JAR dependencies
			$SPARK_HOME/bin/spark-shell --master spark://ip-172-31-24-101:7077 \
				--jars $HADOOP_HOME/$LIB_PATH/aws-java-sdk-1.7.4.jar,$HADOOP_HOME/$LIB_PATH/hadoop-aws-2.7.2.jar
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>


<h3>AWS Error Message: One or more objects could not be deleted</h3>

<bu:rCode lang="plain">
	com.amazonaws.services.s3.model.MultiObjectDeleteException: 
		Status Code: 0, AWS Service: null, AWS Request ID: null, AWS Error Code: null, 
		AWS Error Message: One or more objects could not be deleted, S3 Extended Request ID: null
</bu:rCode>

<p>This message occurs when your IAM Role does not have the proper permissions to delete objects in the S3 bucket. When you write to S3,
several temporary files are saved during the task. These files are deleted once the write operation is complete, so your EC2 instance
must have the <span class="rCW">s3:Delete*</span> permission added to its IAM Role policy, as shown in <bu:rLink id="configuring-s3" anchor="#s3a-config" />.</p>
		
<bu:rFooter>
	<bu:rLinks>
		<li><a href="https://wiki.apache.org/hadoop/AmazonS3">Amazon S3</a> in the Hadoop Wiki</li>
		<li><a href="https://hadoop.apache.org/docs/stable/hadoop-aws/tools/hadoop-aws/index.html">Available Configuration Options for Hadoop-AWS</a></li>
		<li><bu:rLink id="s3-vpc-endpoint" /></li>
		<!--
			https://github.com/apache/hadoop/blob/trunk/hadoop-tools/hadoop-aws/src/site/markdown/tools/hadoop-aws/index.md
			http://stackoverflow.com/questions/30385981/how-to-access-s3a-files-from-apache-spark
			http://deploymentzone.com/2015/12/20/s3a-on-spark-on-aws-ec2/
		-->	
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>