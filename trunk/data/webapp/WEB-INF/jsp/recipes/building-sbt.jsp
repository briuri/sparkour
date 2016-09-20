<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noMessage" value="<p>Because SBT is specific to Java and Scala applications, no examples are provided for Python and R.</p>" />

<bu:rOverview publishDate="2016-03-17">
	<h3>Synopsis</h3>
	<p>This recipe covers the use of SBT (Simple Build Tool or, sometimes, Scala Build Tool) to build and bundle Spark applications
	written in Java or Scala. It focuses very narrowly on a subset of commands relevant to Spark applications, including
	managing library dependencies, packaging, and creating an assembly JAR file with the <span class="rCW">sbt-assembly</span> plugin.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with Java, Scala, and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>This recipe is independent of any specific version of Spark or Hadoop.</li>
		<li>This recipe uses Java <span class="rPN">8</span> and Scala <span class="rPN">2.11.8</span>. You are welcome to use different versions,
			but you may need to change the version numbers in the instructions.</li>
		<li>SBT continues to mature, sometimes in ways that break backwards compatibility. You should consider using a minimum of SBT <span class="rPN">0.13.6</span> and
			<span class="rCW">sbt-assembly</span> <span class="rPN">0.12.0</span>.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing SBT</a></li>
		<li><a href="#02">Project Organization</a></li>
		<li><a href="#03">Building and Submitting an Application</a></li>
		<li><a href="#04">Creating an Assembly JAR</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Introducing SBT" />

<p>SBT is a Scala-based build tool that works with both Java and Scala source code. It adopts many of the conventions used by Apache Maven.
Although it has faced some criticism for its arcane syntax and the fact that it's "yet another build tool", SBT has become the de facto build 
tool for Scala applications. SBT manages library dependencies internally with Apache Ivy, but you do need to interact directly with Ivy to use this feature.
You are most likely to benefit from adopting SBT if you're writing a pure Scala Spark application or you have a mixed 
codebase of both Java and Scala code.</p>

<p>This recipe focuses very narrowly on aspects of SBT relevant to Spark development and intentionally glosses over the more complex configurations and
commands. Refer to the <a href="http://www.scala-sbt.org/0.13/docs/">SBT Reference Manual</a> for more advanced usage.</p>

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/building-sbt.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in 
		Java and Scala. Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the building-sbt source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/building-sbt.zip
		
		# Unzip, creating /opt/sparkour/building-sbt
		sudo unzip building-sbt.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name.</li>
</ol>

<h3>Installing SBT</h3>
	
<ol>
	<li>SBT can be downloaded and manually installed from its <a href="http://www.scala-sbt.org/download.html">website</a>. You can also use the <span class="rCW">yum</span>
		utility to install it on an Amazon EC2 instance:</li>

	<bu:rCode lang="bash">
		# Add a yum repository containing SBT (not included in base Amazon Linux repositories)
		sudo curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
		
		# Install SBT
		sudo yum install sbt
		# (Hit 'y' to proceed)
	</bu:rCode>
</ol>

<bu:rSection anchor="02" title="Project Organization" />

<p>SBT follows a Maven-like convention for its directory structure. The downloaded Sparkour example is set up as a "single build" project and contains the following 
important paths and files:</p>

<ul>
	<li><span class="rCW">build.properties</span>: This file controls the version of SBT. Different projects can use different versions of the tool in the same development environment.</li>
	<li><span class="rCW">build.sbt</span>: This file contains important properties about the project.</li>
	<li><span class="rCW">lib/</span>: This directory contains any unmanaged library dependencies that you have downloaded locally.</li>
	<li><span class="rCW">project/assembly.sbt</span>: This file contains configuration for the <span class="rCW">sbt-assembly</span> plugin, which allows you to create a Spark assembly JAR.</li>
	<li><span class="rCW">src/main/java</span>: This directory is where SBT expects to find Java source code.</li>
	<li><span class="rCW">src/main/scala</span>: This directory is where SBT expects to find Scala source code.</li>
	<li><span class="rCW">target</span>: This directory is where SBT places compiled classes and JAR files.</li>
</ul>

<p>The <span class="rCW">build.properties</span> file always contains a single property identifying the SBT version. In our example, that version is 13.9.1.</p>

<bu:rCode lang="bash">
	# SBT Properties File: controls version of sbt tool
	sbt.version=13.9.1
</bu:rCode>

<p>The <span class="rCW">build.sbt</span> file is a Scala-based file containing properties about the project. Earlier versions of SBT required the file to
be double-spaced, but this restriction has been removed in newer releases. The syntax of the <span class="rK">libraryDependencies</span> setting is covered in the next section.</p>

<bu:rCode lang="scala">
	name := "BuildingSBT"
	version := "1.0"
	scalaVersion := "2.11.8"

	libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0"
	libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.0.0"
	libraryDependencies += "org.apache.commons" % "commons-csv" % "1.2"
</bu:rCode>	

<p>The <span class="rCW">project/assembly.sbt</span> file includes the <span class="rCW">sbt-assembly</span> plugin in the build. Additional configuration for the plugin
would be added here, although our example uses basic defaults.</p>

<bu:rCode lang="scala">
	addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.2")
</bu:rCode>

<p>Finally, we have two very simple Spark applications (in Java and Scala) that we use to demonstrate SBT. Each application has a dependency on 
	the <a href="https://commons.apache.org/proper/commons-csv/">Apache Commons CSV</a> Java library, so we can demonstrate how SBT handles dependencies.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			/**
			 * A simple Java application with an external dependency to
			 * demonstrate building and submitting as well as creating an
			 * assembly JAR.
			 */
			public final class JBuildingSBT {
			
				public static void main(String[] args) throws Exception {
					SparkSession spark = SparkSession.builder().appName("JBuildingSBT").getOrCreate();
					JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());
			
					// Create a simple RDD containing 4 numbers.
					List<Integer> numbers = Arrays.asList(1, 2, 3, 4);
					JavaRDD<Integer> numbersListRdd = sc.parallelize(numbers);
			
					// Convert this RDD into CSV.
					CSVPrinter printer = new CSVPrinter(System.out, CSVFormat.DEFAULT);
					printer.printRecord(numbersListRdd.collect());
			
					spark.stop();
				}
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<c:out value="${noMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			/**
			 * A simple Scala application with an external dependency to
			 * demonstrate building and submitting as well as creating an
			 * assembly JAR.
			 */
			object SBuildingSBT {
				def main(args: Array[String]) {
					val spark = SparkSession.builder.appName("SBuildingSBT").getOrCreate()
			
					// Create a simple RDD containing 4 numbers.
					val numbers = Array(1, 2, 3, 4)
					val numbersListRdd = spark.sparkContext.parallelize(numbers)
			
					// Convert this RDD into CSV (using Java CSV Commons library).
					val printer = new CSVPrinter(Console.out, CSVFormat.DEFAULT)
					val javaArray: Array[java.lang.Integer] = numbersListRdd.collect() map java.lang.Integer.valueOf
					printer.printRecords(javaArray)
			
					spark.stop()
				}
			}
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>
								
<bu:rSection anchor="03" title="Building and Submitting an Application" />

<h3>Managed Library Dependencies</h3>

<p>Under the hood, SBT uses Apache Ivy to download dependencies from the Maven2 repository. You define your dependencies in your <span class="rCW">build.sbt</span> file with
the format of <span class="rV">groupID % artifactID % revision</span>, which may look familiar to developers who have used Maven. In our example, we have 3
dependencies, Commons CSV, Spark Core, and Spark SQL:</p>

<bu:rCode lang="scala">
	libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0"
	libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.0.0"
	libraryDependencies += "org.apache.commons" % "commons-csv" % "1.2"
</bu:rCode>	

<p>The double percent operator (<span class="rCW">%%</span>) is a convenience operator which inserts the Scala compiler version into the ID. Dependencies only available in Java
should always be written with the single percent operator (<span class="rCW">%</span>). If you don't know the 
<span class="rCW">groupID</span> or <span class="rCW">artifactID</span> of your dependency, you can probably find them
on that dependency's website or in the <a href="http://search.maven.org/">Maven Central Repository</a>.</p>

<ol>
	<li>Let's build our example source code with SBT.</li> 

	<bu:rCode lang="bash">
		cd /opt/sparkour/building-sbt
		sbt clean
		sbt package
		# (This command may take a long time on its first run)
	</bu:rCode>
	
	<li>The <span class="rCW">package</span> command compiles the source code in <span class="rCW">/src/main/</span> and creates a JAR file of just the project code without
		any dependencies. In our case, we have both Java and Scala applications in the directory, so we end up with a convenient JAR file containing both applications.</li>
	
	<li>There are many more configuration options available in SBT that you may want to learn if you are serious about adopting SBT across your codebase. Refer to the 
	 	<a href="http://www.scala-sbt.org/0.13/docs/">SBT Reference Manual</a> to learn more. For example, you might use <span class="rCW">dependencyClasspath</span>
	 	to separate compile, test, and runtime dependencies or add <span class="rCW">resolvers</span> to identify alternate repositories for downloading dependencies.</li>
	 	
	<li>We can now run these applications using the familiar <span class="rCW">spark-submit</span> script. We use the <span class="rK">--packages</span> parameter to include
		Commons CSV as a runtime dependency. Remember that <span class="rCW">spark-submit</span> uses Maven syntax, not SBT syntax (colons as separators instead of percent signs),
		and that we don't need to include Spark itself as a dependency since it is implied by default. You can add other Maven IDs with a comma-separated list.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Run the Java version.
				cd /opt/sparkour/building-sbt
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.JBuildingSBT \
					--packages org.apache.commons:commons-csv:1.2 \
					target/scala-2.11/buildingsbt_2.11-1.0.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Run the Scala version.
				cd /opt/sparkour/building-sbt
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.SBuildingSBT \
					--packages org.apache.commons:commons-csv:1.2 \
					target/scala-2.11/buildingsbt_2.11-1.0.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
</ol>

<h3>Unmanaged Library Dependencies</h3>

<p>An alternative to letting SBT handle your dependencies is to download them locally yourself. Here's how you would alter our example project (which 
uses managed dependencies) to use this approach:</p>

<ol>
	<li>Update the <span class="rCW">build.sbt</span> file to remove the Commons CSV dependency.</li>
	
	<bu:rCode lang="scala">
		libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0"
		libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.0.0"
		//libraryDependencies += "org.apache.commons" % "commons-csv" % "1.2"
	</bu:rCode>	
	
	<li>Download Commons CSV to the local <span class="rCW">lib/</span> directory. SBT implicitly uses anything in this directory at compile time.</li>
	
	<bu:rCode lang="bash">
		cd /opt/sparkour/building-sbt/lib
		wget http://central.maven.org/maven2/org/apache/commons/commons-csv/1.2/commons-csv-1.2.jar
	</bu:rCode>
	
	<li>Build the code as we did before. This results in the same JAR file as the previous approach.</li>
	
	<bu:rCode lang="bash">
		cd /opt/sparkour/building-sbt
		sbt clean
		sbt package
	</bu:rCode>
	
	<li>We can now run the applications using <span class="rCW">spark-submit</span> with the <span class="rK">--jars</span> parameter to include
		Commons CSV as a runtime dependency. You can add other JARs with a comma-separated list.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Run the Java version.
				cd /opt/sparkour/building-sbt
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.JBuildingSBT \
					--jars lib/commons-csv-1.2.jar \
					target/scala-2.11/buildingsbt_2.11-1.0.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Run the Scala version.
				cd /opt/sparkour/building-sbt
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.SBuildingSBT \
					--jars lib/commons-csv-1.2.jar \
					target/scala-2.11/buildingsbt_2.11-1.0.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>As a best practice, you should make sure that dependencies are not both managed and unmanaged. If you specify a managed dependency and also have a local copy in
		<span class="rCW">lib/</span>, you may waste several enjoyable hours troubleshooting if the versions ever get out of sync. You should also review Spark's own
		assembly JAR, which is implicitly in the classpath when you run <span class="rCW">spark-submit</span>. If a library you need is already a core dependency of Spark,
		including your own copy may lead to version conflicts.</li>
</ol>

<bu:rSection anchor="04" title="Creating an Assembly JAR" />

<p>As the number of library dependencies increases, the network overhead of sending all of those files to each node in the Spark cluster increases as well. The official
Spark documentation recommends creating a special JAR file containing both the application and all of its dependencies called an <span class="rPN">assembly JAR</span> (or 
"uber" JAR) to reduce network churn. The assembly JAR contains a combined and flattened set of class and resource files -- it is not just a JAR file containing other JAR files.</p> 

<ol>
	<li>We use the <span class="rCW">sbt-assembly</span> plugin to generate an assembly JAR. This plugin is already in our example project, as seen in the 
		<span class="rCW">project/assembly.sbt</span> file:</li>

	<bu:rCode lang="scala">
		addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.2")
	</bu:rCode>

 	<li>Update the <span class="rCW">build.sbt</span> file to mark the Spark dependency as <span class="rV">provided</span>. This prevents it from being included in the assembly JAR.
 		You can also restore the Commons CSV dependency if you want, although our local copy in the <span class="rCW">lib/</span> directory will still get picked up automatically at compile time.</li>

	<bu:rCode lang="bash">
		libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0" % provided
		libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.0.0" % provided
		//libraryDependencies += "org.apache.commons" % "commons-csv" % "1.2"
	</bu:rCode>
	
	<li>Next, run the assembly command. This command creates an assembly JAR containing both your applications and the GSON classes.</li>
	
	<bu:rCode lang="bash">
		cd /opt/sparkour/building-sbt
		sbt assembly
	</bu:rCode>
	
	<li>There are many more configuration options available, such as using a <span class="rCW">MergeStrategy</span> to resolve potential duplicates and dependency conflicts.
		Refer to the <a href="https://github.com/sbt/sbt-assembly"><span class="rCW">sbt-assembly</span> documentation</a>
		to learn more.</li>
	 	
	<li>You can confirm the contents of the assembly JAR with the <span class="rCW">less</span>
		command:</li>
		
	<bu:rCode lang="bash">
		cd /opt/sparkour/building-sbt
		less target/scala-2.11/BuildingSBT-assembly-1.0.jar | grep commons
	</bu:rCode>
	
	<bu:rCode lang="bash">
		-rw----     1.0 fat        0 b- stor 16-Mar-20 13:31 org/apache/commons/
		-rw----     1.0 fat        0 b- stor 16-Mar-20 13:31 org/apache/commons/csv/
		-rw----     2.0 fat    11560 bl defN 15-Aug-21 17:48 META-INF/LICENSE_commons-csv-1.2.txt
		-rw----     2.0 fat     1094 bl defN 15-Aug-21 17:48 META-INF/NOTICE_commons-csv-1.2.txt
		-rw----     2.0 fat      824 bl defN 15-Aug-21 17:48 org/apache/commons/csv/Assertions.class
		-rw----     2.0 fat     1710 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVFormat$Predefined.class
		-rw----     2.0 fat    13983 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVFormat.class
		-rw----     2.0 fat     1811 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVParser$1.class
		-rw----     2.0 fat     1005 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVParser$2.class
		-rw----     2.0 fat     7784 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVParser.class
		-rw----     2.0 fat      899 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVPrinter$1.class
		-rw----     2.0 fat     7457 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVPrinter.class
		-rw----     2.0 fat     5546 bl defN 15-Aug-21 17:48 org/apache/commons/csv/CSVRecord.class
		-rw----     2.0 fat     1100 bl defN 15-Aug-21 17:48 org/apache/commons/csv/Constants.class
		-rw----     2.0 fat     2160 bl defN 15-Aug-21 17:48 org/apache/commons/csv/ExtendedBufferedReader.class
		-rw----     2.0 fat     6407 bl defN 15-Aug-21 17:48 org/apache/commons/csv/Lexer.class
		-rw----     2.0 fat     1124 bl defN 15-Aug-21 17:48 org/apache/commons/csv/QuoteMode.class
		-rw----     2.0 fat     1250 bl defN 15-Aug-21 17:48 org/apache/commons/csv/Token$Type.class
		-rw----     2.0 fat     1036 bl defN 15-Aug-21 17:48 org/apache/commons/csv/Token.class
	</bu:rCode>	
	
	<li>You can now submit your application for execution using the assembly JAR. Because the dependencies are bundled inside, there is no need to use <span class="rK">--jars</span>
	or <span class="rK">--packages</span>.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Run the Java version.
				cd /opt/sparkour/building-sbt
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.JBuildingSBT \
					target/scala-2.11/BuildingSBT-assembly-1.0.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Run the Scala version.
				cd /opt/sparkour/building-sbt
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.SBuildingSBT \
					target/scala-2.11/BuildingSBT-assembly-1.0.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>	
</ol>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://www.scala-sbt.org/0.13/docs/">SBT Reference Manual</a></li>
		<li><a href="https://github.com/sbt/sbt-assembly"><span class="rCW">sbt-assembly</span> plugin for SBT</a></li>
		<li><bu:rLink id="building-maven" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>