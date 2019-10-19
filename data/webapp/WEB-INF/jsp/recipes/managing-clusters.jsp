<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noJavaMessage" value="There is no interactive shell available for Java. You should use one of the other languages to smoke test your Spark cluster." />

<bu:rOverview publishDate="2016-02-26">
	<h3>Synopsis</h3>
	<p>This tutorial describes the tools available to manage Spark in a clustered configuration, including
	the official Spark scripts and the web User Interfaces (UIs). We compare the different cluster modes
	available, and experiment with Local and Standalone mode on our EC2 instance. We also learn how to
	connect the Spark interactive shells to different Spark clusters and conclude with a description of
	the <span class="rCW">spark-ec2</span> script.</p>
		
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a running EC2 instance with Spark installed, as described in
			<bu:rLink id="installing-ec2" />. If you have stopped and started the instance since the
			previous tutorial, you need to make note of its new dynamic Public IP address.</li> 
	</ol>
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will be able to visualize a Spark cluster and understand the difference between Local and Standalone Mode.</li>
		<li>You will know how to manage masters and slaves from the command line, Master UI, or Worker UI.</li>
		<li>You will know how to run the interactive shells against a specific cluster.</li>
		<li>You will be ready to create a real Spark cluster with the <span class="rCW">spark-ec2</span> script.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Clustering Concepts</a></li>
		<li><a href="#02">Local and Standalone Mode</a></li>
		<li><a href="#03">The Master and Worker UI</a></li>
		<li><a href="#04">Running the Interactive Shells with a Cluster</a></li>
		<li><a href="#05">Looking Ahead: The spark-ec2 Script</a></li>
		<li><a href="#06">Conclusion</a></li>		
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Clustering Concepts" />

<p>A key feature of Spark is its ability to process data in a parallel, distributed fashion.
Breaking down a processing job into smaller tasks that can be executed in parallel by many workers is critical
when dealing with massive volumes of data, but this introduces new complexity in the form of task scheduling,
monitoring, failure recovery. Spark abstracts this complexity away, leaving you free to focus on your data processing.
Key clustering concepts are shown in the image below.</p>

<img src="${localImagesUrlBase}/cluster.png" width="750" height="244" title="A Spark cluster hides the complexity of distributed data processing from the application using it." class="diagram border" />

<ul>
	<li>A Spark <span class="rPN">cluster</span> is a collection of servers running Spark that work together to run a data processing
		application.</li>
	<li>A Spark cluster has some number of <span class="rPN">worker</span> servers (informally called the "slaves") that can perform
		tasks for the application. There's always at least 1 worker in a cluster, and more workers can be added for increased performance.
		When a worker receives the application code and a series of tasks to run, it creates <span class="rPN">executor</span> processes
		to isolate the application's tasks from other applications that might be using the cluster.</li>
	<li>A Spark cluster has a <span class="rPN">cluster manager</span> server (informally called the "master") that takes care of the
		task scheduling and monitoring on your behalf. It keeps track of the status and progress of every worker in the cluster.</li>
	<li>A <span class="rPN">driver</span> containing your application submits it to the cluster as a <span class="rPN">job</span>. The cluster manager
		partitions the job into tasks and assigns those tasks to workers. When all workers have finished their tasks, the application
		can complete.</li> 
</ul>

<p>Spark comes with a cluster manager implementation referred to as the <span class="rPN">Standalone</span> cluster manager. However,
resource management is not a unique Spark concept, and you can swap in one of these implementations instead:

<ul> 
	<li><a href="http://mesos.apache.org/">Apache Mesos</a> is a general-purpose cluster manager with fairly broad industry adoption.</li>
	<li><a href="http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html">Apache Hadoop YARN</a>
		(Yet Another Resource Navigator) is the resource manager for Hadoop 2, and may be a good choice in a Hadoop-centric ecosystem.</li>
</ul>

<p>We focus on Standalone Mode here, and explore these alternatives in later recipes.</p>

<a name="spark-server-roles"></a>
<h3>The Roles of a Spark Server</h3>

<p>A server with Spark installed on it can be used in four separate ways:</p>

<ol>
	<li>As a <span class="rPN">development environment</span>, you use the server to write applications for Spark and then use the <span class="rCW">spark-submit</span>
		script to submit your applications to a Spark cluster for execution.</li>
	<li>As a <span class="rPN">launch environment</span>, you use the server to run the <span class="rCW">spark-ec2</span> script, which launches a new Spark cluster
		from scratch, starts and stops an existing cluster, or permanently terminates the cluster.</li>
	<li>As a <span class="rPN">master</span> node in a cluster, this server is responsible for cluster management and receives jobs from a development environment.</li>
	<li>As a <span class="rPN">worker</span> node in a cluster, this server is responsible for task execution.</li>
</ol>

<p>Sometimes, these roles will overlap on the same server. For example, you probably use the same server as both a development environment and a launch environment.
When you're doing rapid development with a test cluster, you might reuse the master node as a development environment to reduce the feedback loop between compiling and running
your code. Later in this tutorial, we reuse the same server to create a cluster where a master and a worker are running on the same EC2 instance -- this demonstrates
clustering concepts without forcing us to pay for an additional instance.</p>

<p>When you document or describe your architecture for others, you should be clear about
the logical roles. For example, "Submitting my application from my local server A to the Spark cluster on server B" is much clearer than 
"Running my application on my Spark server" and guaranteed to elicit better responses when you inevitably pose a question on <a href="http://stackoverflow.com/">Stack Overflow</a>.</p>
 
<bu:rSection anchor="02" title="Local and Standalone Mode" />

<h3>Local Mode</h3>

<p>Juggling the added complexity a Spark cluster may not be a priority when you're just getting started with Spark. If you are developing
a new application and just want to execute code against small test datasets, you can use Spark's Local mode. In
this mode, your development environment is the only thing you need. An ephemeral Spark engine is started when you run your application, 
executes your application just like a real cluster would, and then goes away when your application stops. There are no explicit
masters or slaves to complicate your mental model.</p>

<p>By default, the Spark interactive shells run in Local mode unless you explicitly specify a cluster. A Spark engine starts up when you start
the shell, executes the code that you type interactively, and goes away when you exit the shell. To mimic the idea of adding more workers
to a Spark cluster, you can specify the number of parallel threads used in Local mode:</p>

<bu:rTabs>
	<bu:rTab index="1">
		<p><c:out value="${noJavaMessage}" escapeXml="false" /></p>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="bash">
			# Run in Local mode with a single thread
			$SPARK_HOME/bin/pyspark --master local
			
			# The default is also Local Mode with a single thread
			$SPARK_HOME/bin/pyspark
			
			# Run with 2 worker threads (try not to exceed the number of cores this server has)
			$SPARK_HOME/bin/pyspark --master local[2]
			
			# Run with as many threads as this server can handle
			$SPARK_HOME/bin/pyspark --master local[*]
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="bash">
			# Run in Local mode with a single thread
			$SPARK_HOME/bin/sparkR --master local
			
			# The default is also Local Mode with a single thread
			$SPARK_HOME/bin/sparkR
			
			# Run with 2 worker threads (try not to exceed the number of cores this server has)
			$SPARK_HOME/bin/sparkR --master local[2]
			
			# Run with as many threads as this server can handle
			$SPARK_HOME/bin/sparkR --master local[*]
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="bash">
			# Run in Local mode with a single thread
			$SPARK_HOME/bin/spark-shell --master local
			
			# The default is also Local Mode with a single thread
			$SPARK_HOME/bin/spark-shell
			
			# Run with 2 worker threads (try not to exceed the number of cores this server has)
			$SPARK_HOME/bin/spark-shell --master local[2]
			
			# Run with as many threads as this server can handle
			$SPARK_HOME/bin/spark-shell --master local[*]
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<h3>Standalone Mode</h3>

<p>"Running in Standalone Mode" is just another way of saying that the Spark Standalone cluster manager is being used in the cluster. The
Standalone cluster manager is a simple implementation that accepts jobs in First In, First Out (FIFO) order: applications that submit jobs first
are given priority access to workers over applications that submit jobs later on. Starting a Spark cluster in Standalone Mode on our EC2 instance 
is easy to do with the official Spark scripts.</p>

<p>Normally, a Spark cluster would consist of separate servers for the cluster manager (master) and each worker (slave). 
Each server would have a copy of Spark installed, and a third server would be your development environment where you write and submit your application.
In the interests of limiting the time you spend configuring EC2 instances and reducing the risk of unexpected charges, this tutorial creates
a minimal cluster using the same EC2 instance as the development environment, master, and slave, as shown in the image below.</p>

<img src="${localImagesUrlBase}/minimal-cluster.png" width="750" height="411" title="Both master and slave on the same EC2 instance" class="diagram border" />

<p>In a real world situation, you would launch as many worker EC2 instances as you need (and you would probably forgo these 
manual  steps in favour of automation with the <span class="rCW">spark-ec2</span> script).</p>

<ol>
	<li>Login to your EC2 instance. Run these commands to start a Standalone master.</li>
 
	<bu:rCode lang="bash">
		# Start the master
		$SPARK_HOME/sbin/start-master.sh
	</bu:rCode>

	<li>The output of this command identifies a log file location. Open this log file in your favourite text editor.</li>
	
	<bu:rCode lang="bash">
		# Use whatever text editor you'd like
		vi $SPARK_HOME/logs/spark-ec2-user-org.apache.spark.deploy.master.Master-1-ip-172-31-24-101.out
	</bu:rCode>
	
	<bu:rCode lang="plain">
		INFO Utils: Successfully started service 'sparkMaster' on port 7077.
		INFO Master: Starting Spark master at spark://ip-172-31-24-101:7077
		INFO Master: Running Spark version 2.4.4
		INFO Utils: Successfully started service 'MasterUI' on port 8080.
		INFO MasterWebUI: Bound MasterWebUI to 0.0.0.0, and started at http://172.31.24.101:8080
		INFO Utils: Successfully started service on port 6066.
		INFO StandaloneRestServer: Started REST server for submitting applications on port 6066
		INFO Master: I have been elected leader! New state: ALIVE
	</bu:rCode>

	<li>On line 2 of the log output above, you can see the unique URL for this master, <span class="rCW">spark://ip-172-31-24-101:7077</span>.
		This is the URL you specify when you want your application (or the interactive shells) to connect to this cluster. This is also
		the URL that slaves use to register themselves with the master. The hostname or IP address in this URL must be network-accessible from
		both your application and each slave.</li>
	<li>On line 5 of the log output above, you can see the URL for the Master UI, <span class="rCW">http://172.31.24.101:8080</span>.
		This URL can be opened in a web browser to monitor tasks and workers in the cluster. Spark defaults to the private IP address
		of our EC2 instance. To access the URL from our local development environment, we need to replace the IP with the Public IP of the EC2 instance when we load it
		in a web browser.</li>
	<li>Copy the URLs into a text file so you can use them later. Then, exit your text editor and return to the command line.</li>
	<li>Next, we'll start up a single slave on the same EC2 instance. Remember that a real cluster would have a separate instance for
		each slave -- we are intentionally overloading this instance for training purposes.
		The <span class="rCW">start-slave.sh</span> script requires the master URL from your log file.</li>
	
	<bu:rCode lang="bash">
		# Start a slave on the same server as the master in this contrived example
		$SPARK_HOME/sbin/start-slave.sh spark://ip-172-31-24-101:7077
	</bu:rCode>

	<li>The output of this command identifies a log file location. Open this log file in your favourite text editor.</li>
	
	<bu:rCode lang="bash">
		# Use whatever text editor you'd like
		vi $SPARK_HOME/logs/spark-ec2-user-org.apache.spark.deploy.worker.Worker-1-ip-172-31-24-101.out
	</bu:rCode>
	
	<bu:rCode lang="plain">
		INFO Utils: Successfully started service 'sparkWorker' on port 37907.
		INFO Worker: Starting Spark worker 172.31.24.101:37907 with 2 cores, 6.8 GB RAM
		INFO Worker: Running Spark version 2.4.4
		INFO Worker: Spark home: /opt/spark
		INFO Utils: Successfully started service 'WorkerUI' on port 8081.
		INFO WorkerWebUI: Bound WorkerWebUI to 0.0.0.0, and started at http://172.31.24.101:8081
		INFO Worker: Connecting to master ip-172-31-24-101:7077...
		INFO TransportClientFactory: Successfully created connection to ip-172-31-24-101/172.31.24.101:7077 after 39 ms (0 ms spent in bootstraps)
		INFO Worker: Successfully registered with master spark://ip-172-31-24-101:7077
	</bu:rCode>

	<li>On line 6 of the log output above, you can see the URL for the Worker UI, <span class="rCW">http://172.31.24.101:8081</span>.
		This URL can be opened in a web browser to observe the worker. Just like before, Spark defaults to the private IP address
		of our EC2 instance. To access the URL from our local development environment, we need to replace the IP with the Public IP of the EC2 instance.</li>
	<li>Once you have copied this URL, exit your text editor and return to the command line.</li>
	<li>You now have a minimal Spark cluster (1 master and 1 slave) running on your EC2 instance, and three URLs copied into a scratch file for later.</li>
</ol>

<p>There are several environment variables and properties that can be configured to control the behavior of the master and slaves. 
For example, we could explicitly set the hostnames used in the URLs to our EC2 instance's public IP, to guarantee that the URLs would
be accessible from outside of the Amazon Virtual Private Cloud (VPC) containing our instance. Refer to the official Spark documentation on 
<a href="http://spark.apache.org/docs/latest/spark-standalone.html">Spark Standalone Mode</a> for a complete list.</p>

<bu:rSection anchor="03" title="The Master and Worker UI" />

<p>Each member of the Spark cluster has a web-based UI that allows you to monitor running applications and executors in real time.</p>

<ol>
	<li>From your local development environment, open two web browser windows or tabs and paste in the links to the Master and Worker UI you previously copied
		out of the log files. You should see the web pages shown in the images below.</li> 

	<img src="${localImagesUrlBase}/master-ui.png" width="750" height="279" title="The Master UI for your minimal Spark cluster" class="diagram border" />
	<img src="${localImagesUrlBase}/worker-ui.png" width="750" height="213" title="The Worker UI for your minimal Spark cluster" class="diagram border" />
	
	<li>If you cannot access the links, make sure that you are using the public IP address of your EC2 instance, rather than the private IP
		displayed in the log files. Also make sure that the IP address of your local development environment has not changed since you set up the Security Group
		rules in the previous recipe. If your IP has changed, you need to update the Security Group rules to allow access from your new IP.
		You can update each Inbound rule from the EC2 dashboard	in the <a href="https://console.aws.amazon.com/">AWS Management Console</a>.</li>

	<li>Keep the UI pages open as you complete this recipe. Periodically refresh the pages and you should see updates to the status of
		various cluster components.</li>		
</ol>

<bu:rSection anchor="04" title="Running the Interactive Shells with a Cluster" />

<p>Now that you have a Spark cluster running, you can connect to it with the interactive shells.
We are going to run our interactive shells from our EC2 instance, meaning that this instance is playing the roles of
development environment, master, and slave at the same time.</p> 

<ol>
	<li>From the command line, run an interactive shell and specify the master URL of your minimal cluster. </li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /></p>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Start the shell with your running cluster	
				$SPARK_HOME/bin/pyspark --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Start the shell with your running cluster	
				$SPARK_HOME/bin/sparkR --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Start the shell with your running cluster	
				$SPARK_HOME/bin/spark-shell --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>Refresh each UI web page. You should see a new application (the shell) in the Master UI, and a new executor in the Worker UI.</li>

	<li>Next, run our simple line count example in the shell.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /></p>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				>>> textFile = spark.sparkContext.textFile("README.md")
				>>> textFile.count()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				> # The low-level Spark Core API containing <span class="rCW">textFile()</span>
				> # is not available in R, so we cannot attempt this example.				
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				scala> val textFile = spark.sparkContext.textFile("README.md")
				scala> textFile.count()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>This time, the shell makes use of the Spark cluster to process the data. Your application is sent to the master for scheduling,
		and the master assigns the task to the a worker for processing (here, we only have 1 worker). The time to execute is about the 
		same as running in Local mode because our data size is so small, but improvements would be noticeable with massive 
		amounts of data.</li>
		
	<li>As an experiment, open a second SSH window into your EC2 instance and stop the running worker. You need the worker's ID,
		which can be found in the Workers table of the Master UI. You can close this second window once the worker is stopped.</li>
		
	<bu:rCode lang="bash">
		# Stop the slave	
		$SPARK_HOME/sbin/stop-slave.sh worker-20160920103856-172.31.24.101-37907
	</bu:rCode>

	<li>Refreshing the Master UI after this command shows the Worker as <span class="rCW">DEAD</span>. The Worker UI is also shut down
		and can no longer be refreshed. Additionally, trying to execute our commands in the Python shell now fails:</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /> Here is how you would accomplish this example inside an application.</p>
			<bu:rCode lang="java">
				// Processing data fails now, because there are no workers
				System.out.println(textFile.count());
			</bu:rCode>	
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				>>> # Processing data fails now, because there are no workers
				>>> textFile.count()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				> # The low-level Spark Core API containing "textFile()"
				> # is not available in R, so we cannot attempt this example.				
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				scala> // Processing data fails now, because there are no workers
				scala> textFile.count()
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>After you submit this command, refresh the Master UI. 
		The application enters a <span class="rCW">WAITING</span> state and your shell eventually shows a warning.</li>

	<bu:rCode lang="plain">
		Initial job has not accepted any resources; check your cluster UI to ensure 
		that workers are registered and have sufficient resources
	</bu:rCode>
	
	<li>Because there are no workers to assign tasks to, your application can never complete.
		Hit <span class="rCW">Ctrl+C</span> to abort your command in the interactive shell and then quit the shell.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /></p>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				>>> # Quit the shell
				>>> quit()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				> quit()
				> # (Hit 'n' to quit without saving the workspace).					
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				scala> // Quit the shell
				scala> sys.exit
			</bu:rCode>	
			<p>When using a version of Spark built with Scala 2.10, the command to quit is simply "<span class="rCW">exit</span>".
		</bu:rTab>
	</bu:rTabs>

	<li>Refresh the Master UI one final time, and the shell moves from the Running Applications list to the Completed Applications list.</li>
	
	<li>To clean up our work, let's stop the master.</li>
	
	<bu:rCode lang="bash">
		# Stop the master	
		$SPARK_HOME/sbin/stop-master.sh
	</bu:rCode>
	
</ol>

<bu:rSection anchor="05" title="Looking Ahead: The spark-ec2 Script" />

<p>Our minimal cluster employed the following official Spark scripts:</p>

<ul>
	<li><span class="rCW">start-master.sh</span> / <span class="rCW">stop-master.sh</span>: Written to run from the master instance</li>
	<li><span class="rCW">start-slave.sh</span> / <span class="rCW">stop-slave.sh</span>: Written to run from each slave instance</li>
</ul>

<p>In our contrived example, it was straightforward to run all of the scripts from the same overloaded instance. In a real cluster, you would need to
	login to each slave instance to start and stop that slave. As you can imagine, that would be quite tedious with many slaves, and there is a better way.</p>

<p>If you create a text file called <span class="rCW">conf/slaves</span> in the master node's Spark home directory 
	(<span class="rCW">/opt/spark</span> here), and put the hostname of each slave instance in the file (1 slave per line), 
	you can do all of your starting and stopping from the master instance with these scripts:</p>
	
<ul>
	<li><span class="rCW">start-slaves.sh</span> / <span class="rCW">stop-slaves.sh</span>: Start or stop the slaves listed in the <span class="rCW">slaves</span> file.</li>
	<li><span class="rCW">start-all.sh</span> / <span class="rCW">stop-all.sh</span>: Start or stop the slaves listed in the <span class="rCW">slaves</span> file as well as the master.</li>
</ul>

<p>Although managing the cluster from the master instance is better than logging into each worker, you still have the overhead of configuring and
launching each instance. As you start to work with clusters of non-trivial size, you should take a look at the  
<span class="rCW">spark-ec2</span> script. This script automates all facets of cluster management, allowing you to configure, launch, start,
stop, and terminate instances from the command line. It ensures that the masters and slaves running on the instances are cleanly started
and stopped when the cluster is started or stopped. We explore the power of this script in the recipe, <bu:rLink id="spark-ec2" />.</p>

<bu:rSection anchor="06" title="Conclusion" />

<p>You have now seen the different ways that Spark can be deployed, and are almost ready to dive into doing functional, productive things
with Spark. In the next tutorial, <bu:rLink id="submitting-applications" />, we focus on the steps needed to create a Spark
application and submit it to a cluster for execution. If you are done playing with Spark for now, make sure that you stop your 
EC2 instance so you don't incur unexpected charges.</p>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/spark-standalone.html">Spark Standalone Mode</a> in the Spark Programming Guide</li>
		<li><a href="http://spark.apache.org/docs/latest/">Running the Spark Interactive Shells</a> in the Spark Programming Guide</li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2016-09-20: Updated for Spark 2.0.0. Code may not be backwards compatible with Spark 1.6.x
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-18">SPARKOUR-18</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>