<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-02-27">
	<h3>Synopsis</h3>
	<p>This tutorial takes you through the common steps involved in creating a Spark application and submitting
	it to a Spark cluster for execution. We write and submit a simple application and then review the 
	examples bundled with Apache Spark.</p>
			
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with Apache Spark installed, as described in 
			<bu:rLink id="installing-ec2" anchor="#03" />. You can opt to use the EC2 instance we 
			created in that tutorial. If you have stopped and started the instance since the
			previous tutorial, you need to make note of its new dynamic Public IP address.</li> 
	</ol>
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will understand the steps required to write	Spark applications in a language of your choosing.</li>
		<li>You will understand how to bundle your application with all of its dependencies for submission.</li>
		<li>You will be able to submit applications to a Spark cluster (or Local mode) with the <span class="rCW">spark-submit</span> script.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Installing a Programming Language</a></li>
		<li><a href="#02">Writing a Spark Application</a></li>
		<li><a href="#03">Bundling Dependencies</a></li>
		<li><a href="#04">Submitting the Application</a></li>
		<li><a href="#05">Spark Distribution Examples</a></li>
		<li><a href="#06">Conclusion</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Installing a Programming Language" />

<p>Spark imposes no special restrictions on where you can do your development.
The Sparkour recipes will continue to use the EC2 instance created in a previous tutorial as a development environment,
so that each recipe can start from the same baseline configuration.
However, you probably already have a development environment tuned just the way you like it, so you can use it instead if you prefer. You'll 
just need to get your build dependencies in order.</p>

<ol>
	<li>Regardless of <a href="/recipes/spark-nutshell/#05">which language you use</a>, you'll need Apache Spark and a Java Runtime Environment (7 or higher) installed. These components allow you
		to submit your application to a Spark cluster (or run it in Local mode).</li>
	<li>You also need the development kit for your language. If developing for Spark 2.x, you would want a <i>minimum</i> of Java Development Kit (JDK) 7,
		Python 2.6, R 3.1, or Scala 2.11, respectively. You probably already have the development kit for your language installed in your development
		environment.</li>
	<li>Finally, you need to link or include the core Spark libraries with your application. If you are using an Integrated Development Environment (IDE) like 
		Eclipse or IntelliJ, the official Spark documentation provides instructions for 
		<a href="http://spark.apache.org/docs/latest/programming-guide.html#linking-with-spark">adding Spark dependencies in Maven</a>. If you don't use Maven, 
		you can manually track down the dependencies in your installed Spark directory:<ul>
			<li>Java and Scala dependencies can be found in <span class="rCW">jars</span> (or <span class="rCW">lib</span> for Spark 1.6).</li>
			<li>Python dependencies can be found in <span class="rCW">python/pyspark</span>.</li>
			<li>R dependencies can be found in <span class="rCW">R/lib</span>.</li>
		</ul></li>
</ol>

<p>Python is pre-installed on our EC2 instance as part of the Amazon Linux distribution, so no further work is needed to use that language. Instructions for configuring
the EC2 instance to use other programming languages are shown beolw. If your personal development environment (outside of EC2) does not already have the right 
components installed, you should be able to review these instructions and adapt them to your unique environment.</p>

<bu:rTabs>
	<bu:rTab index="1">	
		<p>If you intend to write any Spark applications with Java, you should consider updating to Java 8 or higher. This version
		of Java introduced <a href="https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html">Lambda Expressions</a>
		which reduce the pain of writing repetitive boilerplate code while making the resulting code more similar to
		Python or Scala code. Sparkour Java examples employ Lambda Expressions heavily, and Java 7 support may go away in Spark 2.x. 
		The Amazon Linux AMI comes with Java 7, but it's easy to switch versions:</p>

		<bu:rCode lang="bash">
			# Install Java 8 JDK
			sudo yum install java-1.8.0-openjdk-devel.x86_64
			# (Hit 'y' to proceed)
			
			# Make Java 8 the default version on this instance
			sudo /usr/sbin/alternatives --config java
			# (Select the 1.8.0 option from the list that appears)
			
			# Optionally remove Java 7
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
		downloaded separately. You should use the same version of Scala that was
		used to build your copy of Apache Spark. In the case of <span class="rPN">Spark 2.3.0 Pre-built for Hadoop 2.7 and later</span>,
		this would be a <span class="rPN">2.11.x</span> version, and <i>not</i> a 2.10.x version unless you have explicitly
		built Spark for 2.10.x from the source code.</p>
		<p>At this time, no versions of Spark support Scala 2.12.x. You can track the progress on this work in the
		<a href="https://issues.apache.org/jira/browse/SPARK-14220">SPARK-14220</a> ticket.</p>
		
		<bu:rCode lang="bash">
			# Download Scala to the ec2-user's home directory
			cd ~
			wget http://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.tgz
			
			# Unpack Spark in the /opt directory
			sudo tar zxvf scala-2.11.12.tgz -C /opt
			
			# Update permissions on installation
			sudo chown -R ec2-user:ec2-user /opt/scala-2.11.12
			
			# Create a symbolic link to make it easier to access
			sudo ln -fs /opt/scala-2.11.12 /opt/scala
			
			#Edit your bash profile to add environment variables
			vi ~/.bash_profile
		</bu:rCode>
		
		<p>To complete your installation, set the <span class="rCW">SCALA_HOME</span>
		environment variable so it takes effect when you login to the EC2 instance.</p>
		
		<bu:rCode lang="bash">
			# Insert these lines into your .bash_profile:
			export SCALA_HOME=/opt/scala
			PATH=$PATH:$SCALA_HOME/bin
			export PATH
			# Then exit the text editor and return to the command line.
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

<p>These instructions do not cover Java and Scala build tools (such as Maven and SBT) which simplify the compiling and bundling
steps of the development lifecycle. Build tools are covered in <bu:rLink id="building-maven" /> and <bu:rLink id="building-sbt" />.</p> 

<bu:rSection anchor="02" title="Writing a Spark Application" />

<ol>
	<li><a href="${filesUrlBase}/submitting-applications.zip">Download</a> and unzip the example source code for this tutorial. This ZIP archive contains source code in all
		supported languages. Here's how you would do this on our EC2 instance:</li> 

	<bu:rCode lang="bash">
		# Download the submitting-applications source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/submitting-applications.zip
		
		# Unzip, creating /opt/sparkour/submitting-applications
		sudo unzip submitting-applications.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour
	</bu:rCode>
	
	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name. Locate the source code for
		your programming language and open the file in a text editor.</li>
		
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="java">
				package buri.sparkour;
				
				import org.apache.spark.sql.SparkSession;
				
				/**
				 * A simple application which merely initializes the spark session,
				 * for the purposes of demonstrating how to submit an application to
				 * Spark for execution.
				 */
				public final class JSubmittingApplications {
				
					public static void main(String[] args) throws Exception {
						SparkSession spark = SparkSession.builder().appName("JSubmittingApplications").getOrCreate();
				
						System.out.println("You are using Spark " + spark.version());
						
						spark.stop();
					}
				}
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				from __future__ import print_function
				
				from pyspark.sql import SparkSession
				
				"""
				    A simple application which merely initializes the spark session,
				    for the purposes of demonstrating how to submit an application to
				    Spark for execution.
				"""
				if __name__ == "__main__":
					spark = SparkSession.builder.appName("submitting_applications").getOrCreate()
				
				    print("You are using Spark " + spark.version);
				    
				    spark.stop()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				# A simple application which merely initializes the spark session,
				# for the purposes of demonstrating how to submit an application to
				# Spark for execution.
				
				library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
				sparkR.session()
				
				print("The SparkR session has initialized successfully.")
				
				sparkR.stop()
			</bu:rCode>	
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				package buri.sparkour
				
				import org.apache.spark.sql.SparkSession
				
				/**
				 * A simple application which merely initializes the spark session,
				 * for the purposes of demonstrating how to submit an application to
				 * Spark for execution.
				 */
				object SSubmittingApplications {
					def main(args: Array[String]) {
						val spark = SparkSession.builder.appName("SSubmittingApplications").getOrCreate()
				
						println("You are using Spark " + spark.version)
						
						spark.stop()
					}
				}
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>		
		
	<li>The application is decidedly uninteresting, merely initializing a <span class="rCW">SparkSession</span>, printing a message, and stopping the <span class="rCW">SparkContext</span>.
	We are more concerned with getting the application executed right now, and will create more compelling programs in the next tutorial.</li>
</ol>

<bu:rSection anchor="03" title="Bundling Dependencies" />

<p>When you submit an application to a Spark cluster, the cluster manager distributes the application code to each worker so it can be executed locally. This means
that all dependencies need to be included (except for Spark and Hadoop dependencies, which the workers already have copies of). There are multiple approaches for bundling
dependencies, depending on your programming language:</p>

<bu:rTabs>
	<bu:rTab index="1">
		<p>The Spark documentation recommends creating an <span class="rPN">assembly JAR</span> (or "uber" JAR) containing your
		application and all of the dependencies. You can also use the <span class="rK">--packages</span> parameter with a comma-separated list of Maven dependency IDs
		and Spark will download and distribute the libraries from a Maven repository. Finally, you can also specify a comma-separated list of third-party JAR files with the 
		<span class="rK">--jars</span> parameter in the <span class="rCW">spark-submit</span> script.
		Avoiding the assembly JAR is simpler, but has a performance trade-off if many separate files are copied across the workers.</p>
	</bu:rTab><bu:rTab index="2">
		<p>You can use the <span class="rK">--py-files</span> parameter in the <span class="rCW">spark-submit</span> script and pass in 
		<span class="rCW">.zip</span>, <span class="rCW">.egg</span>, or <span class="rCW">.py</span> dependencies.</p>
	</bu:rTab><bu:rTab index="3">
		<p>You can load additional libraries when you initialize the <span class="rCW">SparkR</span> package in your R script.</p>
	</bu:rTab><bu:rTab index="4">
		<p>The Spark documentation recommends creating an <span class="rPN">assembly JAR</span> (or "uber" JAR) containing your
		application and all of the dependencies. You can also use the <span class="rK">--packages</span> parameter with a comma-separated list of Maven dependency IDs
		and Spark will download and distribute the libraries from a Maven repository. Finally, you can also specify a comma-separated list of third-party JAR files with the 
		<span class="rK">--jars</span> parameter in the <span class="rCW">spark-submit</span> script.
		Avoiding the assembly JAR is simpler, but has a performance trade-off if many separate files are copied across the workers.</p>
	</bu:rTab>
</bu:rTabs>

<p>In the case of the <span class="rK">--py-files</span> or <span class="rK">--jars</span> parameters, you can also use URL schemes such as <span class="rCW">ftp:</span> or
<span class="rCW">hdfs:</span> to reference files stored elsewhere, or <span class="rCW">local:</span> to specify files that
are already stored on the workers. See the documentation on <a href="http://spark.apache.org/docs/latest/submitting-applications.html#advanced-dependency-management">Advanced Dependency Management</a>
for more details.</p>

<p>The simple application in this tutorial has no dependencies besides Spark itself. We cover the creation of an assembly JAR in 
<bu:rLink id="building-maven" /> and <bu:rLink id="building-sbt" />.</p>

<bu:rSection anchor="04" title="Submitting the Application" />

<p>Here are examples of how you would submit an application in each of the supported languages. For JAR-based
languages (Java and Scala), we would pass in an application JAR file and a class name. For interpreted languages,
we just need the top-level module or script name. Everything after the expected <span class="rCW">spark-submit</span> arguments are passed into the application itself.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="bash">
			# Submit an application to a Spark cluster
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--class buri.sparkour.ImaginaryApp \
				bundledAssembly.jar \
				applicationArgs
				
			# Submit an application with Maven package dependencies
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--packages groupId:artifactId:version \
				--class buri.sparkour.ImaginaryApp \
				imaginaryApp.jar \
				applicationArgs
				
			# Submit an application with JAR dependencies
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--jars dependency.jar \
				--class buri.sparkour.ImaginaryApp \
				imaginaryApp.jar \
				applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="bash">
			# Submit an application to a Spark cluster
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--py-files dependency.egg \
				imaginaryApp.py \
				applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="bash">
			# Submit an application to a Spark cluster
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				imaginaryApp.R \
				applicationArgs
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="bash">
			# Submit an arbitrary application to a Spark cluster
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--class buri.sparkour.ImaginaryApp \
				bundledAssembly.jar \
				applicationArgs
				
			# Submit an application with Maven package dependencies
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--packages groupId:artifactId:version \
				--class buri.sparkour.ImaginaryApp \
				imaginaryApp.jar \
				applicationArgs
				
			# Submit an application with JAR dependencies
			$SPARK_HOME/bin/spark-submit \
				--master spark://ip-172-31-24-101:7077 \
				--jars dependency.jar \
				--class buri.sparkour.ImaginaryApp \
				imaginaryApp.jar \
				applicationArgs
		</bu:rCode>
	</bu:rTab>
</bu:rTabs>

<ol>
	<li>It's time to submit our simple application. It has no dependencies or application arguments, and 
		we'll run it in Local mode, which means that a brand new Spark engine spins up to execute the code, rather than relying upon an existing Spark cluster.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				cd /opt/sparkour/submitting-applications
				
				# Create environment variables for readability.
				export SRC_PATH="src/main"
				export PACKAGE="buri/sparkour"
				
				# Compile Java class and create JAR file
				mkdir target/java
				javac $SRC_PATH/java/$PACKAGE/JSubmittingApplications.java \
					-classpath "$SPARK_HOME/jars/*" -d target/java
				cd target/java
				jar -cf ../JSubmittingApplications.jar *
				cd ../..
				
				# Submit the application
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.JSubmittingApplications \
					target/JSubmittingApplications.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				cd /opt/sparkour/submitting-applications
				$SPARK_HOME/bin/spark-submit \
					src/main/python/submitting_applications.py
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				cd /opt/sparkour/submitting-applications
				$SPARK_HOME/bin/spark-submit \
					src/main/r/submitting_applications.R
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				cd /opt/sparkour/submitting-applications
				
				# Create environment variables for readability.
				export SRC_PATH="src/main"
				export PACKAGE="buri/sparkour"
				
				# Compile Scala class and create JAR file
				mkdir target/scala
				scalac $SRC_PATH/scala/$PACKAGE/SSubmittingApplications.scala \
					-classpath "$SPARK_HOME/jars/*" -d target/scala
				cd target/scala
				jar -cf ../SSubmittingApplications.jar *
				cd ../..
				
				# Submit the application
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.SSubmittingApplications \
					target/SSubmittingApplications.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>The complete set of low-level commands required to build and submit are explicitly shown here for your awareness.
		In tutorials and recipes that follow, these commands are simplified through a helpful build script.</li>
	<li>Submitting your application should result in a brief statement about Spark.</li>
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

<bu:rSection anchor="05" title="Spark Distribution Examples" />

<p>Now that we have successfully submitted and executed an application, let's take a look at one of the examples included in the Spark distribution.</p>

<ol>
	<li>The source code for the <span class="rCW">JavaWordCount</span> application can be found in the <span class="rCW">org.apache.spark.examples</span> package. 
		You can view the source code, but be aware that this is just a reference copy. Any changes you make to it will not affect the already compiled application JAR.</li>
		
	<bu:rCode lang="bash">
		# Go to the Java examples directory
		cd $SPARK_HOME/examples/src/main/java/
		
		# Go into the examples package
		cd org/apache/spark/examples
		
		# View the source code
		vi JavaWordCount.java
	</bu:rCode>

	<li>To submit this application in Local mode, you use the <span class="rCW">spark-submit</span> script, just as we did with the Python application.</li>

	<bu:rCode lang="bash">
		# Submit the JavaWordCount application
		cd $SPARK_HOME
		$SPARK_HOME/bin/spark-submit \
			--class org.apache.spark.examples.JavaWordCount \
			./examples/jars/spark-examples_*.jar \
			$SPARK_HOME/README.md
	</bu:rCode>

	<li>Spark also includes a quality-of-life script that makes running Java and Scala examples simpler. Under the hood, this script ultimately calls <span class="rCW">spark-submit</span>.</li>

	<bu:rCode lang="bash">
		# Submit the JavaWordCount application with the run-example script.
		$SPARK_HOME/bin/run-example JavaWordCount $SPARK_HOME/README.md
	</bu:rCode>
	
	<li>Source code for the Python examples can be found in <span class="rCW">$SPARK_HOME/examples/src/main/python/</span>. These examples have no dependent packages, other than
		the basic <span class="rCW">pyspark</span> library.</li>
			
	<li>Source code for the R examples can be found in <span class="rCW">$SPARK_HOME/examples/src/main/r/</span>. These examples have no dependent packages, other than
		the basic <span class="rCW">SparkR</span> library.</li>

	<li>Source code for the Scala examples can be found in <span class="rCW">$SPARK_HOME/examples/src/main/scala/</span>. These examples follow the same patterns and directory
		organization as the Java examples.</li>
</ol>
 
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
		<li><bu:rLink id="building-maven" /></li>
		<li><bu:rLink id="building-sbt" /></li>
	</bu:rLinks>

	<bu:rChangeLog>
		<li>2016-03-15: Updated with instructions for all supported languages instead of Python alone
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-4">SPARKOUR-4</a>).</li>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>