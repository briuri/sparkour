<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noMessage" value="<p>Because Maven is specific to Java and Scala applications, no examples are provided for Python and R.</p>" />

<bu:rOverview publishDate="2016-03-29">
	<h3>Synopsis</h3>
	<p>This recipe covers the use of Apache Maven to build and bundle Spark applications
	written in Java or Scala. It focuses very narrowly on a subset of commands relevant to Spark applications, including
	managing library dependencies, packaging, and creating an assembly JAR file.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with Java and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>This recipe is independent of any specific version of Spark or Hadoop.</li>
		<li>This recipe uses Java <span class="rPN">8</span> and Scala <span class="rPN">2.11.12</span>. You are welcome to use different versions,
			but you may need to change the version numbers in the instructions. Make sure to use the same version of Scala as the one used to build your
			distribution of Spark. Pre-built distributions of Spark 1.x use Scala 2.10, while pre-built distributions of Spark 2.x use Scala 2.11.</li>
		<li>You should consider using a minimum of Maven <span class="rPN">3.2.5</span> to maximize the availability
			and compatibility of plugins, such as <span class="rCW">maven-compiler-plugin</span>, <span class="rCW">addjars-maven-plugin</span>,
			<span class="rCW">maven-shade-plugin</span>, and <span class="rCW">scala-maven-plugin</span>.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing Maven</a></li>
		<li><a href="#02">Project Organization</a></li>
		<li><a href="#03">Building and Submitting an Application</a></li>
		<li><a href="#04">Creating an Assembly JAR</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Introducing Maven" />

<p>Apache Maven is a Java-based build tool that works with both Java and Scala source code. 
It employs a "convention over configuration" philosophy that attempts to make useful assumptions about project structure and
common build tasks in order to reduce the amount of explicit configuration by a developer. Although it has faced some criticism
for its use of verbose XML in configuration files and for being difficult to customize, it has eclipsed Apache Ant
as the standard build tool for Java applications. Maven also manages library dependencies and benefits from broadly adopted
public dependency repositories. You are most likely to benefit from adopting Maven if you're writing a pure Java Spark application
or you have a mixed codebase of mostly Java code.</p>

<p>This recipe focuses very narrowly on aspects of Maven relevant to Spark development and intentionally glosses over the more complex configurations and
commands. Refer to the <a href="http://maven.apache.org/guides/">Maven Documentation</a> for more advanced usage.</p>

<h3>Downloading the Source Code</h3>

<ol>
	<li><a href="${filesUrlBase}/building-maven.zip">Download</a> and unzip the example source code for this recipe. This ZIP archive contains source code in 
		Java and Scala. Here's how you would do this on an EC2 instance running Amazon Linux:</li> 

	<bu:rCode lang="bash">
		# Download the building-maven source code to the home directory.
		cd ~
		wget https://sparkour.urizone.net${filesUrlBase}/building-maven.zip
		
		# Unzip, creating /opt/sparkour/building-maven
		sudo unzip building-maven.zip -d /opt
		
		# Update permissions
		sudo chown -R ec2-user:ec2-user /opt/sparkour		
	</bu:rCode>

	<li>The example source code for each language is in a subdirectory of <span class="rCW">src/main</span> with that language's name.</li>
</ol>

<h3>Installing Maven</h3>
	
<ol>
	<li>Maven can be downloaded and manually installed from its <a href="http://maven.apache.org/download.cgi">website</a>. Here's how
		you would do so on an Amazon EC2 instance:</li>

	<bu:rCode lang="bash">
		# Download Maven to the ec2-user's home directory
		wget http://apache.mirrors.hoobly.com/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
		
		# Unpack Maven in the /opt directory
		sudo tar zxvf apache-maven-3.6.0-bin.tar.gz -C /opt
		 
		# Update permissions on installation
		sudo chown -R ec2-user:ec2-user /opt/apache-maven-3.6.0
		 
		# Create a symbolic link to make it easier to access
		sudo ln -fs /opt/apache-maven-3.6.0 /opt/maven
		 
		#Edit your bash profile to add environment variables
		vi ~/.bash_profile
	</bu:rCode>
	
	<bu:rCode lang="bash">
		# Insert these lines into your .bash_profile:
		PATH=$PATH:/opt/maven/bin
		# Then exit the text editor and return to the command line.
	</bu:rCode>
	
	<bu:rCode lang="bash">
		# Reload the environment variables
		source ~/.bash_profile
		
		# Confirm that Maven is in the PATH
		mvn --version
	</bu:rCode>
</ol>

<bu:rSection anchor="02" title="Project Organization" />

<p>Maven defines a standard convention for the directory structure of a project. The downloaded Sparkour example contains the following 
important paths and files:</p>

<ul>
	<li><span class="rCW">pom-java.xml</span>: A Maven file for Java projects containing managed library dependencies.</li>
	<li><span class="rCW">pom-java-local.xml</span>: A Maven file for Java projects containing unmanaged library dependencies that have been manually downloaded to the local filesystem.</li>
	<li><span class="rCW">pom-scala.xml</span>: A Maven file for Scala projects containing managed library dependencies.</li>
	<li><span class="rCW">pom-scala-local.xml</span>: A Maven file for Scala projects containing unmanaged library dependencies that have been manually downloaded to the local filesystem.</li>
	<li><span class="rCW">lib/</span>: This directory contains any unmanaged library dependencies that you have downloaded locally.</li>
	<li><span class="rCW">src/main/java</span>: This directory is where Maven expects to find Java source code.</li>
	<li><span class="rCW">src/main/scala</span>: This directory is where Maven expects to find Scala source code.</li>
	<li><span class="rCW">target</span>: This directory is where Maven places compiled classes and JAR files.</li>
</ul>

<p>The Project Object Model (POM) file is the primary Maven artifact. In this case, there are 4 POM files, each of which builds the example in a different way. We can
designate a specific file with the <span class="rK">--file</span> parameter. In the absence of this parameter, Maven
will default to a file named <span class="rV">pom.xml</span>.</p>

<p>Each example POM file has some configuration in common:</p>

<ul>
	<li>The combination of a <span class="rK">groupId</span>, <span class="rK">artifactId</span>, and 
		<span class="rK">version</span> uniquely identifies this project build if it is ever published to a Maven repository.</li>

	<bu:rCode lang="xml">
    	<groupId>net.urizone.sparkour</groupId>
    	<artifactId>building-maven</artifactId>
    	<version>1.0-SNAPSHOT</version>
    </bu:rCode>

	<li>A collection of <span class="rK">dependencies</span> identifies library dependencies that Maven needs
		to gather from a Maven repository to compile, package, or run the project. All of our example POMs
		identify Apache Spark as a dependency.</li>
		
	<bu:rCode lang="xml">
	    <dependencies>
        	<dependency>
            	<groupId>org.apache.spark</groupId>
            	<artifactId>spark-core_2.11</artifactId>
            	<version>2.4.0</version>
            	<scope>provided</scope>
        	</dependency>
	        <dependency>
	            <groupId>org.apache.spark</groupId>
	            <artifactId>spark-sql_2.11</artifactId>
	            <version>2.4.0</version>
	            <scope>provided</scope>
	        </dependency>
        	<!-- Other managed dependencies (described below) -->
	    </dependencies>
	</bu:rCode>
	
	<li>The <span class="rCW">_2.11</span> suffix in the <span class="rK">artifactId</span> specifies a build of Spark that was compiled
		with Scala 2.11. Adding a <span class="rK">scope</span> of <span class="rV">provided</span>
		signifies that Spark is needed to compile the project, but does not need to be available at runtime or included
		in an assembly JAR file. (Recall that Spark will already be installed on a Spark cluster executing your
		application, so there is no need to provide a new copy at runtime).</li>
		
	<li>A collection of <span class="rK">plugins</span> identifies Maven plugins that perform tasks such as
		compiling code.</li> 

	<bu:rCode lang="xml">
	    <build>
        	<plugins>
        		<!-- A plugin for compiling Java code -->
				<plugin>
		            <groupId>org.apache.maven.plugins</groupId>
		            <artifactId>maven-compiler-plugin</artifactId>
		            <version>3.6.1</version>
		            <configuration>
		                <source>1.8</source>
		                <target>1.8</target>
		            </configuration>
		        </plugin>
		        
		        <!-- Or, a plugin for compiling Scala code -->
		        <!-- Make sure you are not using "maven-scala-plugin", which is the older version -->
	            <plugin>
	                <groupId>net.alchim31.maven</groupId>
	                <artifactId>scala-maven-plugin</artifactId>
	                <version>3.2.2</version>
	                <executions>
	                    <execution>
	                        <goals>
	                            <goal>compile</goal>
	                        </goals>
	                    </execution>
	                </executions>
	            </plugin>       		
        		
        		<!-- Other plugins (e.g. unmanaged dependency handling or assembly JARs) (described below) -->
	        </plugins>
	    </build>
	</bu:rCode>
</ul>

<p>Finally, we have two very simple Spark applications (in Java and Scala) that we use to demonstrate Maven. Each application has a dependency on 
	the <a href="https://commons.apache.org/proper/commons-csv/">Apache Commons CSV</a> Java library, so we can demonstrate how Maven handles dependencies.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			/**
			 * A simple Java application with an external dependency to
			 * demonstrate building and submitting as well as creating an
			 * assembly JAR.
			 */
			public final class JBuildingMaven {
			
				public static void main(String[] args) throws Exception {
					SparkSession spark = SparkSession.builder().appName("JBuildingMaven").getOrCreate();
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
			object SBuildingMaven {
				def main(args: Array[String]) {
					val spark = SparkSession.builder.appName("SBuildingMaven").getOrCreate()
			
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

<p>A key feature of Maven is the ability to download library dependencies when needed, without requiring them to be a local part of your
project. In addition to Apache Spark, we also need to add the Scala library (for the Scala example only) and Commons CSV (for both Java
and Scala):</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="xml">
			<dependency>
	            <groupId>org.apache.commons</groupId>
	            <artifactId>commons-csv</artifactId>
	            <version>1.2</version>
	        </dependency>
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<c:out value="${noMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="3">
		<c:out value="${noMessage}" escapeXml="false" />
	</bu:rTab><bu:rTab index="4">
		<p>The <span class="rV">provided</span> scope prevents the Scala base classes from being bundled into your application package (assuming that Scala is already provided in the target
			runtime environment.</p>
		<bu:rCode lang="xml">
		    <dependency>
		        <groupId>org.scala-lang</groupId>
		        <artifactId>scala-library</artifactId>
		        <version>2.11.12</version>
		        <scope>provided</scope>
		    </dependency>
		    <dependency>
		        <groupId>org.apache.commons</groupId>
		        <artifactId>commons-csv</artifactId>
		        <version>1.2</version>
		    </dependency>
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<p>If you don't know the <span class="rK">groupID</span> or <span class="rK">artifactID</span> of your dependency, 
you can probably find them on that dependency's website or in the <a href="http://search.maven.org/">Maven Central Repository</a>.</p>

<ol>
	<li>Let's build our example source code with Maven.</li> 
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Build the managed Java version.
				cd /opt/sparkour/building-maven
				mvn --file pom-java.xml clean
				mvn --file pom-java.xml package
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Build the managed Scala version.
				cd /opt/sparkour/building-maven
				mvn --file pom-scala.xml clean
				mvn --file pom-scala.xml package
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>The <span class="rCW">package</span> command compiles the source code in <span class="rCW">/src/main/</span> and creates a JAR file of just the project code without
		any dependencies. The result is saved at <span class="rCW">target/original-building-maven-1.0-SNAPSHOT.jar</span>.</li>
	
	<li>There are many more configuration options available in Maven that you may want to learn if you are serious about adopting Maven across your codebase. Refer to the 
	 	<a href="http://maven.apache.org/guides/">Maven Documentation</a> to learn more. For example, you might use <span class="rCW">repositories</span>
	 	to identify alternate repositories for downloading dependencies.</li>
	 	
	<li>We can now run these applications using the familiar <span class="rCW">spark-submit</span> script. We use the <span class="rK">--packages</span> parameter to include
		Commons CSV as a runtime dependency. Remember that we don't need to include Spark itself as a dependency since it is implied by default. 
		You can add other Maven IDs with a comma-separated list.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Run the managed Java version.
				cd /opt/sparkour/building-maven
				$SPARK_HOME/bin/spark-submit \
				    --class buri.sparkour.JBuildingMaven \
				    --packages org.apache.commons:commons-csv:1.2 \
				    target/original-building-maven-1.0-SNAPSHOT.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Run the managed Scala version.
				cd /opt/sparkour/building-maven
				$SPARK_HOME/bin/spark-submit \
				    --class buri.sparkour.SBuildingMaven \
				    --packages org.apache.commons:commons-csv:1.2 \
				    target/original-building-maven-1.0-SNAPSHOT.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
</ol>

<h3>Unmanaged Library Dependencies</h3>

<p>An alternative to letting Maven handle your dependencies is to download them locally yourself. We can use
the <span class="rCW">addjars-maven-plugin</span> plugin to identify a local directory containing these
unmanaged libraries.</p>

<ol>
	<li>The plugin is defined in the <span class="rCW">pom-java-local.xml</span>
		and <span class="rCW">pom-scala-local.xml</span> POM files. This plugin works with
		both Java and Scala code. Our examples specify the <span class="rCW">lib/</span> directory for storing extra libraries.</li>
				
	<bu:rCode lang="xml">
        <plugin>
            <groupId>com.googlecode.addjars-maven-plugin</groupId>
            <artifactId>addjars-maven-plugin</artifactId>
            <version>1.0.5</version>
            <executions>
                <execution>
                    <goals>
                        <goal>add-jars</goal>
                    </goals>
                    <configuration>
                        <resources>
                            <resource>
                                <directory>\${basedir}/lib</directory>
                            </resource>
                        </resources>
                    </configuration>
                </execution>
            </executions>
        </plugin> 
	</bu:rCode>
	
	<li>Next, manually download the Commons CSV library into the <span class="rCW">lib/</span> directory.</li>
	
	<bu:rCode lang="bash">
		cd /opt/sparkour/building-maven/lib
		wget http://central.maven.org/maven2/org/apache/commons/commons-csv/1.2/commons-csv-1.2.jar		
	</bu:rCode>	
	
	<li>Build the code using the <span class="rCW">-local</span> version of the POM file. This results in the same JAR file as the previous approach.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Build the unmanaged Java version.
				cd /opt/sparkour/building-maven
				mvn --file pom-java-local.xml clean
				mvn --file pom-java-local.xml package
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Build the unmanaged Scala version.
				cd /opt/sparkour/building-maven
				mvn --file pom-scala-local.xml clean
				mvn --file pom-scala-local.xml package
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>We can now run the applications using <span class="rCW">spark-submit</span> with the <span class="rK">--jars</span> parameter to include
		Commons CSV as a runtime dependency. You can add other JARs with a comma-separated list.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Run the unmanaged Java version.
				cd /opt/sparkour/building-maven
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.JBuildingMaven \
					--jars lib/commons-csv-1.2.jar \
					target/original-building-maven-1.0-SNAPSHOT.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Run the unmanaged Scala version.
				cd /opt/sparkour/building-maven
				$SPARK_HOME/bin/spark-submit \
					--class buri.sparkour.SBuildingMaven \
					--jars lib/commons-csv-1.2.jar \
					target/original-building-maven-1.0-SNAPSHOT.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>As a best practice, you should make sure that dependencies are not both managed and unmanaged. If you specify a managed dependency and also have a local copy in
		<span class="rCW">lib/</span>, you may end up doing some late-night troubleshooting if the versions ever get out of sync. You should also review Spark's own
		assembly JAR, which is implicitly in the classpath when you run <span class="rCW">spark-submit</span>. If a library you need is already a core dependency of Spark,
		including your own copy may lead to version conflicts.</li>
</ol>

<bu:rSection anchor="04" title="Creating an Assembly JAR" />

<p>As the number of library dependencies increases, the network overhead of sending all of those files to each node in the Spark cluster increases as well. The official
Spark documentation recommends creating a special JAR file containing both the application and all of its dependencies called an <span class="rPN">assembly JAR</span> (or 
"uber" JAR) to reduce network churn. The assembly JAR contains a combined and flattened set of class and resource files -- it is not just a JAR file containing other JAR files.</p> 

<ol>
	<li>We use the <span class="rCW">maven-shade-plugin</span> plugin to generate an assembly JAR. This plugin is registered in
		all of our example POM files already:</li>

	<bu:rCode lang="xml">
		<!-- A plugin for creating an assembly JAR file (Java or Scala) -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>3.0.0</version>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>shade</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
	</bu:rCode>

	<li>The assembly JAR file is automatically created whenever you run the <span class="rCW">mvn package</span> command, and the JAR file
		is saved at <span class="rCW">target/building-maven-1.0-SNAPSHOT.jar</span>.</li>
		 	
	<li>You can confirm the contents of the assembly JAR with the <span class="rCW">less</span> command:</li>
		
	<bu:rCode lang="bash">
		cd /opt/sparkour/building-maven
		less target/building-maven-1.0-SNAPSHOT.jar | grep commons
	</bu:rCode>
	
	<bu:rCode lang="bash">
		-rw----     2.0 fat        0 bl defN 16-Mar-29 12:51 org/apache/commons/
		-rw----     2.0 fat        0 bl defN 16-Mar-29 12:51 org/apache/commons/csv/
		-rw----     2.0 fat      824 bl defN 16-Mar-29 12:51 org/apache/commons/csv/Assertions.class
		-rw----     2.0 fat     1100 bl defN 16-Mar-29 12:51 org/apache/commons/csv/Constants.class
		-rw----     2.0 fat     1710 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVFormat$Predefined.class
		-rw----     2.0 fat    13983 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVFormat.class
		-rw----     2.0 fat     1811 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVParser$1.class
		-rw----     2.0 fat     1005 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVParser$2.class
		-rw----     2.0 fat     7784 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVParser.class
		-rw----     2.0 fat      899 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVPrinter$1.class
		-rw----     2.0 fat     7457 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVPrinter.class
		-rw----     2.0 fat     5546 bl defN 16-Mar-29 12:51 org/apache/commons/csv/CSVRecord.class
		-rw----     2.0 fat     2160 bl defN 16-Mar-29 12:51 org/apache/commons/csv/ExtendedBufferedReader.class
		-rw----     2.0 fat     6407 bl defN 16-Mar-29 12:51 org/apache/commons/csv/Lexer.class
		-rw----     2.0 fat     1124 bl defN 16-Mar-29 12:51 org/apache/commons/csv/QuoteMode.class
		-rw----     2.0 fat     1250 bl defN 16-Mar-29 12:51 org/apache/commons/csv/Token$Type.class
		-rw----     2.0 fat     1036 bl defN 16-Mar-29 12:51 org/apache/commons/csv/Token.class
		-rwx---     2.0 fat        0 bl defN 16-Mar-29 12:51 META-INF/maven/org.apache.commons/
		-rwx---     2.0 fat        0 bl defN 16-Mar-29 12:51 META-INF/maven/org.apache.commons/commons-csv/
		-rw----     2.0 fat    18374 bl defN 16-Mar-29 12:51 META-INF/maven/org.apache.commons/commons-csv/pom.xml
		-rw----     2.0 fat      117 bl defN 16-Mar-29 12:51 META-INF/maven/org.apache.commons/commons-csv/pom.properties
	</bu:rCode>	
	
	<li>You can now submit your application for execution using the assembly JAR. Because the dependencies are bundled inside, there is no need to use <span class="rK">--jars</span>
	or <span class="rK">--packages</span>.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<bu:rCode lang="bash">
				# Run the managed or unmanaged Java version.
				cd /opt/sparkour/building-maven
				$SPARK_HOME/bin/spark-submit \
				    --class buri.sparkour.JBuildingMaven \
    				target/building-maven-1.0-SNAPSHOT.jar
			</bu:rCode>
		</bu:rTab><bu:rTab index="2">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="3">
			<c:out value="${noMessage}" escapeXml="false" />
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Run the managed or unmanaged Scala version.
				cd /opt/sparkour/building-maven
				$SPARK_HOME/bin/spark-submit \
				    --class buri.sparkour.SBuildingMaven \
				    target/building-maven-1.0-SNAPSHOT.jar
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>	
</ol>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://maven.apache.org/guides/">Maven Documentation</a></li>
		<li><a href="https://maven.apache.org/plugins/maven-compiler-plugin/"><span class="rCW">maven-compiler-plugin</span> Plugin</li>
		<li><a href="https://github.com/davidB/scala-maven-plugin"><span class="rCW">scala-maven-plugin</span> Plugin</li>
		<li><a href="https://maven.apache.org/plugins/maven-shade-plugin/"><span class="rCW">maven-shade-plugin</span> Plugin</li>
		<li><a href="https://code.google.com/archive/p/addjars-maven-plugin/"><span class="rCW">addjars-maven-plugin</span> Plugin</li>
		<li><bu:rLink id="building-sbt" /></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>