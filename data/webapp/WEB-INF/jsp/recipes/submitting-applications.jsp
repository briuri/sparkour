<%@ include file="../shared/header.jspf" %>
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-02-27">
	<h3>Synopsis</h3>
	<p>This tutorial takes you through the common steps involved in creating a Spark application and submitting
	it to a Spark cluster for execution. We write and submit a simple Python application and then review the 
	examples bundled with Apache Spark in other languages.</p>
			
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with Python and Apache Spark installed. If Python is not your
			normal language, you can use the running EC2 instance we created in <bu:rLink id="installing-ec2" />,
			which already has Python installed. If you have stopped and started the instance since the
			previous tutorial, you need to make note of its new dynamic Public IP address.</li> 
	</ol>
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will understand the steps required to write	Spark applications in a language of your choosing (using Python as an exemplar).</li>
		<li>You will understand how to bundle your application with all of its dependencies for submission.</li>
		<li>You will be able to submit applications to a Spark cluster (or Local mode) with the <span class="rCW">spark-submit</span> script.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Writing a Spark Application</a></li>
		<li><a href="#02">Bundling Dependencies</a></li>
		<li><a href="#03">Submitting the Application</a></li>
		<li><a href="#04">Spark Distribution Examples</a></li>
		<li><a href="#05">Using a Different Development Environment</a></li>
		<li><a href="#06">Conclusion</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Writing a Spark Application" />

<p>Our first Spark application is going to be written in Python. This isn't a value judgement on the other languages -- 
there are just fewer potential pitfalls to trip you up on your first attempt with Python. 
You should be able to follow this tutorial to completion even if you aren't very familiar with the
Python programming language.</p>

<p>Because our first application is in Python, the EC2 instance we created earlier is a perfect development
environment to use for this tutorial. Python is already installed as part of the Amazon Linux image and we installed
Spark earlier, so we can get right to work. Instructions for setting up other languages are included at the end of this tutorial.</p>

<h3>A Simple Python Application</h3>

<ol>
	<li><a href="${filesUrlBase}/submitting-applications.zip">Download</a> and unzip the example source code for this tutorial. Here's how you would do this on our EC2 instance:</li> 

	<bu:rCode lang="bash">
		# Download the submitting-applications source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/submitting-applications.zip
		
		# Unzip, creating /opt/sparkour/submitting-applications
		sudo unzip submitting-applications.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour
	</bu:rCode>
	
	<li>There are 3 files in this ZIP archive: <span class="rCW">wordcount.py</span>, <span class="rCW">dependency.py</span>, and <span class="rCW">poem.txt</span>. Open
		the <span class="rCW">wordcount.py</span> file in your favourite text editor. You can see a slightly modified version of the Word Count example included with 
		Apache Spark. When given a file, it counts up how many times each word appears in the file. This version has been modified to make the words lowercase first
		(so "The" and "the" share the same count), and then	display the results sorted with the most-used words at the top.</li>
		
	<bu:rCode lang="python">
		from __future__ import print_function
		
		import sys
		from operator import add
		from pyspark import SparkContext
		
		from dependency import sort_by_count
		
		"""
		    Process a text file and return a list of tuples showing
		    each word in the file and how many times that word appears.
		
		    Based on the Apache Spark example and modified with the following
		    changes:
		        Words are converted to lowercase before processing.
		        Output is shown in count order, descending.
		"""
		
		if __name__ == "__main__":
		    if len(sys.argv) != 2:
		        print("Usage: wordcount <file>", file=sys.stderr)
		        exit(-1)
		    sc = SparkContext(appName="PythonWordCount")
		    lines = sc.textFile(sys.argv[1], 1)
		    counts = lines.map(lambda x: x.lower()) \
		                  .flatMap(lambda x: x.split(' ')) \
		                  .map(lambda x: (x, 1)) \
		                  .reduceByKey(add)
		    output = sort_by_count(counts.collect())
		    for (word, count) in output:
		        print("%s: %i" % (word, count))
		    sc.stop()
	</bu:rCode>

	<li>Notice that the <span class="rCW">sort_by_count()</span> function comes from a different file, <span class="rCW">dependency.py</span>.
		This is a contrived example to make the application have a dependency. Open <span class="rCW">dependency.py</span> in a text editor
		and review the code, which just sorts the results returned from Spark for display.</li> 

	<bu:rCode lang="python">
		def sort_by_count(tuples):
		    """Sorts a list of string-integer tuples based on the integer in
		        descending order.
		
		        [('dog', 1), ('cat', 2)]
		        becomes
		        [('cat', 2), ('dog', 1)]"""
		    return sorted(tuples, key=lambda tuple: tuple[1], reverse=True)
	</bu:rCode>

	<li>If you're feeling adventurous, feel free to make other modifications to this simple application. However, we are more concerned with getting
	the application executed right now, and will start exploring the innards of the program in the next tutorial.</li>
</ol>

<bu:rSection anchor="02" title="Bundling Dependencies" />

<p>When you submit an application to a Spark cluster, the cluster manager distributes the application code to each worker so it can be executed locally. This means
that all dependencies need to be included (except for Spark and Hadoop dependencies, which Spark already has copies of). There are three approaches for bundling
dependencies:</p>

<ol>
	<li>For Java and Scala applications, the Spark documentation recommends creating an <span class="rPN">assembly JAR</span> (or "uber" JAR) containing your
		application and all of the dependencies. This can be done with Scala's <span class="rCW">sbt</span> utility or Maven's <span class="rCW">shade</span> plugin.
		Creating an "uber" JAR is worthy of its own recipe (and the reason we're using Python to get started).</li>
	<li>For Java and Scala applications, you can also specify third-party JAR files with the <span class="rK">--jars</span> parameter in the <span class="rCW">spark-submit</span>
		script. This is simpler, but has a performance trade-off if many separate files are copied across the workers.</li>
	<li>For Python, you can use the <span class="rK">--py-files</span> parameter in the <span class="rCW">spark-submit</span> script and pass in 
		<span class="rCW">.zip</span>, <span class="rCW">.egg</span>, or <span class="rCW">.py</span> dependencies.</li>
	<li>For R, dependencies are added by configuring the <span class="rCW">SparkR</span> package.</li>
</ol>

<p>Both parameter-based approaches can accept a comma-separated list of simple file names. You can also use URL schemes such as <span class="rCW">ftp:</span> or
	<span class="rCW">hdfs:</span> to reference files stored elsewhere, or <span class="rCW">local:</span> to specify files that
	are already stored on the workers. See the documentation on <a href="http://spark.apache.org/docs/latest/submitting-applications.html">Advanced Dependency Management</a>
	for more details.</p>

<bu:rSection anchor="03" title="Submitting the Application" />

<ol>
	<li>It's time to submit our application. We'll run it in Local mode, which means that a brand new Spark engine spins up to execute the code, rather than relying
		upon an existing Spark cluster.</li>
	
	<bu:rCode lang="bash">
		# Submit our Python application in Spark Local mode
		cd /opt/sparkour/submitting-applications
		/opt/spark/bin/spark-submit \
			--py-files dependency.py \
			wordcount.py \
			poem.txt
	</bu:rCode>

	<li>As you can see, we called the <span class="rCW">spark-submit</span> script, which is the entry point for running applications in any of the supported languages.
		We use <span class="rK">--py-files</span>
		to include the extra Python file. On line 5 above, we specify the file containing the application itself. Everything after that (specifically, line 6) is 
		passed into the application as system arguments. Running this command should result in output that starts with the most commonly used words in the <span class="rCW">poem.txt</span>
		file (as well as plenty of logging output from Spark).</li> 

	<bu:rCode lang="plain">
		all: 5
		and: 5
		for: 5
		the: 5
		never: 4
		heart: 3
		give: 3
	</bu:rCode>

	<li>The <span class="rCW">spark-submit</span> script accepts the same parameters for configuring Local mode or specifying a Spark cluster as those we discussed in the previous
	recipe. If you had a Spark cluster up and running, you could submit the application to that master with this command:</li>

	<bu:rCode lang="bash">
		# Submit to a specific Spark cluster
		cd /opt/sparkour/submitting-applications
		/opt/spark/bin/spark-submit \
		    --master spark://ip-172-31-24-101:7077 \
			--py-files dependency.py \
			wordcount.py \
			poem.txt
	</bu:rCode>
</ol>

<p>Here are examples of how you would submit an application in each of the supported languages. For JAR-based
languages (Java and Scala), we would pass in an application JAR file instead of a Python file, and would also
need to supply a class name to run.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="bash">
			# Submit an arbitrary application in Local mode with 2 cores
			/opt/spark/bin/spark-submit \
				--master local[2] \
				--class buri.sparkour.ImaginaryApplication \
				bundledAssembly.jar \
				applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="bash">
			# Submit an arbitrary application in Spark Local mode
			/opt/spark/bin/spark-submit \
				--py-files dependency.egg \
				imaginaryApp.py \
				applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="bash">
			# Submit an arbitrary application in Local mode with max cores
			/opt/spark/bin/spark-submit \
				--master local[*] \
				--packages dependency \
				imaginaryApp.R \
				applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="bash">
			# Submit an arbitrary application in Spark Local mode
			/opt/spark/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--class buri.sparkour.ImaginaryApplication \
				bundledAssembly.jar \
				applicationArgs
		</bu:rCode>
	</bu:rTab>
</bu:rTabs>
	

	
</ol>

<h3>Deploy Modes</h3>

<p>The <span class="rCW">spark-submit</span> script accepts a <span class="rK">--deploy-mode</span> parameter which dictates how the driver is set up.
Recall from the previous recipe that the driver contains your application and relies upon the completed tasks of workers to successfully execute your code. It's best if
the driver is physically co-located near the workers to reduce any network latency.</p>

<ul>
	<li>If the location where you are running <span class="rCW">spark-submit</span> is sufficiently close to the cluster already, the <span class="rV">client</span> deploy mode
		simply places the driver on the same instance that the script was run. This is the default approach.</li>
	<li>If the <span class="rCW">spark-submit</span> location is very far from the cluster (e.g. your cluster is in another AWS region), you can reduce network latency
		by placing the driver on a node within the cluster with the <span class="rV">cluster</span> deploy mode.</li>
</ul>

<p>You can visualize these modes in the image below.</p>

<img src="${localImagesUrlBase}/deploy-modes.png" width="750" height="267" title="Different deploy modes can be used to reduce network latency." class="diagram border" />

<h3>Configuring spark-submit</h3>

<p>If you find yourself often reusing the same configuration parameters, you can create a <span class="rCW">conf/spark-defaults.conf</span> file in the Spark home directory of
your development environment. Properties explicitly set within a Spark application (on the <span class="rCW">SparkConf</span> object) have the highest priority, followed by 
properties passed into the <span class="rCW">spark-submit</span> script, and finally the defaults file.</p>

<p>Here is an example of setting the master URL in a defaults file. More detail on the <a href="http://spark.apache.org/docs/latest/configuration.html#available-properties">available properties</a>
can be found in the official documentation.</p>

<bu:rCode lang="plain">
	# Keys and values separated by whitespace. Comments are allowed.
	
	# Default to this master only if no master is explicitly set
	spark.master spark://ip-172-31-24-101:7077
</bu:rCode>

<bu:rSection anchor="04" title="Spark Distribution Examples" />

<p>Now that we have successfully submitted and executed a Python application, let's take a look at one of the Java examples included in the Spark distribution.</p>

<ol>
	<li>The source code for the <span class="rCW">JavaWordCount</span> application can be found in the <span class="rCW">org.apache.spark.examples</span> package. 
		You can view the source code, but be aware that this is just a reference copy. Any changes you make to it will not affect the already compiled application JAR.</li>
		
	<bu:rCode lang="bash">
		# Go to the Java examples directory
		cd /opt/spark/examples/src/main/java/
		
		# Go into the examples package
		cd org/apache/spark/examples
		
		# View the source code
		vi JavaWordCount.java
	</bu:rCode>

	<li>An assembly JAR file contains the compiled example classes and all of the necessary dependencies. If you look inside, you'll see tons of third-party classes.</li>

	<bu:rCode lang="bash">
		# Go to the assembly JAR directory
		cd /opt/spark/lib
		
		# Peek in the assembly JAR (it's big!)
		less spark-examples-1.6.0-hadoop2.6.0.jar
		# (hold down spacebar to skim down, or hit 'q' to exit)
	</bu:rCode>

	<li>To submit this application in Local mode, you use the <span class="rCW">spark-submit</span> script, just as we did with the Python application.</li>

	<bu:rCode lang="bash">
		# Submit the JavaWordCount application
		cd /opt/spark	
		./bin/spark-submit \
			--class org.apache.spark.examples.JavaWordCount \
			./lib/spark-examples-1.6.0-hadoop2.6.0.jar \
			README.md
	</bu:rCode>

	<li>Spark also includes a quality-of-life script that makes running Java and Scala examples simpler. Under the hood, this script ultimately calls <span class="rCW">spark-submit</span>.</li>

	<bu:rCode lang="bash">
		# Submit the JavaWordCount application with the run-example script.
		cd /opt/spark	
		./bin/run-example JavaWordCount README.md
	</bu:rCode>

	<li>The Scala examples follow these same patterns. You can find source code in the <span class="rCW">/opt/spark/examples/src/main/scala/</span> directory,
		and can submit the compiled JARs using the same scripts as in Java.</li>
		
	<li>Source code for the R examples can be found in <span class="rCW">/opt/spark/examples/src/main/r/</span>. These examples have no dependent packages, other than
		the basic <span class="rCW">SparkR</span> library.</li>
</ol>
 
<bu:rSection anchor="05" title="Using a Different Development Environment" />

<p>Spark imposes no special restrictions on where you can do your development. We have created a Python development environment
on our EC2 instance, and can easily configure the instance for other programming languages.</p>

<bu:rTabs>
	<bu:rTab index="1">	
		<p>If you intend to write any Spark applications with Java, you should consider updating to Java 8. This version
		of Java introduced <a href="https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html">Lambda Expressions</a>
		which reduce the pain of writing repetitive boilerplate code while making the resulting code more similar to
		Python or Scala code. The Amazon Linux AMI comes with Java 7, but it's easy to switch versions.</p>

		<bu:rCode lang="bash">
			# Install Java 8 JDK
			sudo yum install java-1.8.0-openjdk-devel.x86_64
			# (Hit 'y' to proceed)
			
			# Make Java 8 the default version on this instance
			sudo /usr/sbin/alternatives --config java
			# (Select the 1.8.0 option from the list that appears)
			
			# Remove Java 7
			sudo yum remove java-1.7.0-openjdk
			# (Hit 'y' to proceed)
			
			# Confirm that javac is now in the PATH
			javac -version
			# (Should display a version number)
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<p>The instance has Python pre-installed as part of the Amazon Linux image, so you do not need to do anything else.</p>
	</bu:rTab><bu:rTab index="3">
		<p>The R environment is available in the Amazon Linux package repository.</p>
		<bu:rCode lang="bash">
			# Install R
			sudo yum install R
			# (Hit 'y' to proceed)
			
			# Confirm that the R Shell is now installed
			R
		</bu:rCode>
		<bu:rCode lang="plain">
			> # Quit the shell
			> q()
			> # (Hit 'n' to quit without saving workspace)
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">	
		<p>Scala is not in the Amazon Linux package repository, and must be 
		downloaded separately.</p>
		
		<bu:rCode lang="bash">
			# Download Scala to the ec2-user's home directory
			cd ~
			wget http://downloads.lightbend.com/scala/2.11.7/scala-2.11.7.tgz
			
			# Unpack Spark in the /opt directory
			sudo tar zxvf scala-2.11.7.tgz -C /opt
			
			# Update permissions on installation
			sudo chown -R ec2-user:ec2-user /opt/scala-2.11.7
			
			# Create a symbolic link to make it easier to access
			sudo ln -fs /opt/scala-2.11.7 /opt/scala
			
			#Edit your bash profile to add environment variables
			vi ~/.bash_profile
		</bu:rCode>
		
		<p>To complete your installation, set the <span class="rCW">SCALA_HOME</span>
		environment variable so it takes effect when you login to the EC2 instance.</p>
		
		<bu:rCode lang="bash">
			# Insert these lines into your .bash_profile:
			SPARK_HOME=/opt/spark
			SCALA_HOME=/opt/scala
			PATH=$PATH:$HOME/.local/bin:$HOME/bin:$SPARK_HOME/bin:$SCALA_HOME/bin
			export SPARK_HOME
			export SCALA_HOME
			export PATH
			#Then exit the text editor and return to the command line.
		</bu:rCode>
		
		<p>You need to reload the environment variables (or logout and login again) so
		they take effect.</p>
		
		<bu:rCode lang="bash">
			# Reload environment variables
			source ~/.bash_profile
			
			# Confirm that scalac is now in the PATH.
			scalac -version
			# (Should display a version number)
		</bu:rCode>
	</bu:rTab>
</bu:rTabs>

<p>The Sparkour recipes will continue to use the EC2 instance as a development environment so that each recipe can start from the same baseline configuration.
However, you probably already have a development environment tuned just the way you like it, so you can use it instead if you prefer. You'll 
just need to get your build dependencies in order.</p>

<ol>
	<li>Regardless of which language you use, you'll need Apache Spark and a Java Runtime Environment (7 or higher) installed. These components allow you
		to submit your application to a Spark cluster (or run it in Local mode).</li>
	<li>You also need the development kit for your language. If developing for Spark 1.6.0, you would want a <i>minimum</i> of Java Development Kit (JDK) 7,
		Python 2.6, R 3.1, or Scala 2.10, respectively. You probably already have the development kit for your language installed in your development
		environment.</li>
	<li>Finally, you need to link or include the core Spark libraries with your application. If you are using an Integrated Development Environment (IDE) like 
		Eclipse or IntelliJ, the official Spark documentation provides instructions for 
		<a href="http://spark.apache.org/docs/latest/programming-guide.html#linking-with-spark">adding Spark dependencies in Maven</a>. If you don't use Maven, 
		you can manually track down the dependencies in your installed Spark directory:<ul>
			<li>Java and Scala dependencies can be found in <span class="rCW">lib</span>.</li>
			<li>Python dependencies can be found in <span class="rCW">python/pyspark</span>.</li>
			<li>R dependencies can be found in <span class="rCW">R/lib</span>.</li>
		</ul></li>
</ol>

<p>If your personal development environment (outside of EC2) does not already have the right components installed, you should be able to review the instructions
provided so far for the EC2 instance and adapt them to your unique environment.</p>

<bu:rSection anchor="06" title="Conclusion" />	

<p>You have now been exposed to the application lifecycle for applications that use Spark for data processing. It's time to stop poking around the edges of
Spark and actually use the Spark APIs to do something useful to data. In the next tutorial, <bu:rLink id="working-rdds" />, we dive into the Spark Core
API and work with some common transformations and actions. If you are done playing with Spark for now, make sure that you stop your EC2 instance 
so you don't incur unexpected charges.</p>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#linking-with-spark">Linking with Spark</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/quick-start.html">Self-Contained Applications</a> (in Java, Python, and Scala) in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/submitting-applications.html">Submitting Applications</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/configuration.html#dynamically-loading-spark-properties">Loading Default Configurations</a> in the Spark Programming Guide</li>
	</bu:rLinks>

	<bu:rChangeLog>
		<li>This tutorial hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>