<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-09-22">
	<h3>Synopsis</h3>
	<p>This recipe explains how to install Apache Zeppelin and configure it to work with Spark. Interactive notebooks 
		such as Zeppelin make it easier for analysts (who may not be software developers) to harness the power of Spark
		through iterative exploration and built-in visualizations.</p> 
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a web-accessible server where you can install Zeppelin and a web browser to visit the user interface 
			(UI). If you are installing on Amazon EC2 (such as the instance used in <bu:rLink id="installing-ec2" />), 
			it should have at least 1 GB of free memory available.</li> 
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>This recipe uses Apache Zeppelin <span class="rPN">0.7.3</span>, which supports Spark 2.2.x. If you are targeting Spark 1.x, you should use Zeppelin 
			<span class="rPN">0.6.0</span>.</li> 
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing Notebooks</a></li>
		<li><a href="#02">Installing Apache Zeppelin</a></li>
		<li><a href="#03">Configuring Zeppelin to Use Spark</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="Introducing Notebooks" />

<p>While Apache Spark offers a robust, high performance engine for distributed data processing, it does not necessarily
fit directly into the day-to-day workflow of data scientists and analysts. Data scientists may need 
to explore data in an ad hoc way, iteratively defining their data processing algorithms over successive executions and
then rendering the output graphically so it is easily understandable. The algorithms and visualizations might then be 
reused and refined collaboratively or applied to alternate datasets.</p> 

<p><span class="rPN">Interactive Notebooks</span> (such as Zeppelin, Jupyter, and Beaker) bridge the gap between the 
data scientist and the underlying engine, providing a web-based UI for real-time exploration of data and useful 
charts and graphs to quickly visualize output. This expands Spark's potential audience beyond software developers 
(who are already comfortable with programming languages and submitting Spark jobs for batch processing).</p>

<p>Notebooks connect to underlying data sources and engines through <span class="rPN">Interpreters</span>. Zeppelin,
in particular, ships with 20 built-in Interpreters for sources as varied as Elasticsearch, HDFS, JDBC, and Spark. This reduces
the level of effort needed to use different engines at different phases in a data processing pipeline, and allows
new engines to be supported in the future.</p>

<bu:rSection anchor="02" title="Installing Apache Zeppelin" />

<ol>
	<li>Visit the <a href="http://zeppelin.apache.org/download.html">Apache Zeppelin - Download</a> page to find the
		download link for the binary distribution you need. Because of Scala and Spark version differences, you should
		download Zeppelin <span class="rPN">0.7.3</span> to use with Spark 2.2.x or <span class="rPN">0.6.0</span> to use with Spark 1.x. 
		While it's theoretically possible to get newer versions of Zeppelin to work with
		older versions of Spark, you may end up spending more time than desired troubleshooting arcane version errors.</li>
					
	<li>On a web-accessible server, download and unpack the binary distribution.</li>
	
	<bu:rCode lang="bash">
		# Download the Zeppelin binary to the home directory.
		cd ~
		wget http://www-us.apache.org/dist/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-all.tgz
	
		# Unpack Zeppelin in the /opt directory
		sudo tar zxvf zeppelin-0.7.3-bin-all.tgz -C /opt
	
		# Update permissions on installation
		sudo chown -R ec2-user:ec2-user /opt/zeppelin-0.7.3-bin-all/
	
		# Create a symbolic link to make it easier to access
		sudo ln -fs /opt/zeppelin-0.7.3-bin-all /opt/zeppelin
	</bu:rCode>
	
	<li>To complete your installation, add Zeppelin into your <span class="rCW">PATH</span>
		environment variable.</li>
		
	<bu:rCode lang="bash">
		# Insert these lines into your ~/.bash_profile:
		PATH=$PATH:/opt/zeppelin/bin
		export PATH
		# Then exit the text editor and return to the command line.
	</bu:rCode>
		
	<li>You need to reload the environment variables (or logout and login again) so
		they take effect.</li>
		
	<bu:rCode lang="bash">
		# Reload environment variables
		source ~/.bash_profile
		
		# Confirm that Zeppelin is now in the PATH.
		zeppelin-daemon.sh --version
		# (Should display a version number)
	</bu:rCode>
		
	<li>By default, Zeppelin will run on port 8080. If you have other software already using this port,
		you'll need to assign a different one. For example, the Spark Master UI also uses port 8080,
		so installing Zeppelin on the same server as a master node will cause conflicts.</li>
	
	<bu:rCode lang="bash">
		# Change port, if sharing this server with other applications
		cd /opt/zeppelin/conf
		cp zeppelin-site.xml.template zeppelin-site.xml
		vi zeppelin-site.xml
		
		# (Find the "zeppelin.server.port" property and change its value
		#  then save the file and return to the command line)
	</bu:rCode>
	
	<li>Finally, start up Zeppelin. Log files will be in <span class="rCW">/opt/zeppelin/logs</span> if you
		need to troubleshoot anything.</li>
		
	<bu:rCode lang="bash">
		# Start Zeppelin
		zeppelin-daemon.sh start
	</bu:rCode>
</ol>

<h3>Testing Your Installation</h3>

<ol>
	<li>From a web browser, visit the hostname and port of the running Zeppelin server. An example of this URL is
		<span class="rCW">http://127.0.0.1:8080/</span>. You should see the Zeppelin home page shown below. If you
		cannot connect to Zeppelin on an Amazon EC2 instance, make sure that your Security Groups allow traffic from
		the computer where your web browser is installed.</li>
		
	<img src="${localImagesUrlBase}/notebook-home.png" width="750" height="333" title="Zeppelin Home Page" class="diagram border" />
	
	<li>Expand the <span class="rPN">Zeppelin Tutorial</span> and select the <span class="rPN">Basic Features (Spark)</span> note.
	On your first visit, you will be taken to a Settings page listing all of the installed Interpreters, as shown below. 
	Scroll down this list and select <class="rAB">Save</class>.</li>
	
	<img src="${localImagesUrlBase}/notebook-settings.png" width="750" height="682" title="Zeppelin Settings" class="diagram border" />
	
	<li>The Basic Features note will appear onscreen, with multiple panes, as shown below. The top pane shows a welcome message,
		the next pane down provides some Scala code to generate sample data, and the three smaller panes provide some SQL code to query the data and
		generate visualizations. These panes are called <span class="rPN">Paragraphs</span>. You can refer to the 
		<a href="https://zeppelin.apache.org/docs/latest/">Zeppelin Documentation</a>
		for a more descriptive walkthrough of Zeppelin features and the Tutorial paragraphs.</li>
		
	<img src="${localImagesUrlBase}/notebook-welcome.png" width="750" height="686" title="Basic Features" class="diagram border" />
	
	<li>Select the &#x25b7; icon in the upper right corner of the <span class="rPN">Load data into table</span> paragraph. This will
		load sample data out of Amazon S3 so it can be explored.</li>
	<li>Select the &#x25b7; icon in one of the 3 visualization paragraphs. This will execute a SQL query against the sample
		data and render the results as some form of chart. You can select different chart types (e.g. table, bar, pie) and
		the results will be re-rendered without re-executing the query. You can also edit the SQL query on the fly to run
		a different query.</li>
	<li>If running each Paragraph works without errors, Zeppelin has been installed successfully.</li>
</ol>

<bu:rSection anchor="03" title="Configuring Zeppelin to Use Spark" />

<p>By default, Zeppelin's Spark Interpreter points at a local Spark cluster bundled with the Zeppelin distribution. It is
very straightforward to point at an existing Spark cluster instead.</p>

<ol>
	<li>From any Zeppelin note page, click on the &#9881; icon at the top of the page to get to the 
		<span class="rPN">Interpreter Binding</span> page. Then, follow the link to the <span class="rPN">Interpreter</span>
		page.</li>
	<li>Scroll down the list to the Spark Interpreter. As shown in the image below, the default Interpreter has its
		<span class="rK">master</span> property set to <span class="rV">local[*]</span>. This means that running a paragraph
		will use a local Spark cluster with as many cores as available.</li> 

	<img src="${localImagesUrlBase}/interpreter-local.png" width="750" height="235" title="Spark Interpreter Settings" class="diagram border" />

	<li>Select the <span class="rAB">edit</span> button and change the <span class="rK">master</span> property
		to a valid Spark cluster URL, such as <span class="rV">spark://ip-172-31-24-101:7077</span>. Make sure your network
		and AWS Security Groups allow traffic on this port between the Zeppelin server and the Spark cluster.
		Scroll down the page and select the <span class="rAB">Save</span> button. You will be prompted to confirm the action.</li>
		
	<li>Return to the Zeppelin Tutorial note by way of the <span class="rPN">Notebook</span> dropdown menu at the top of the page.
		Rerun the various paragraphs and Zeppelin should use your external Spark cluster. You can also visit
		the Master UI for your Spark cluster and see Zeppelin as a running application.</li>
</ol>
 
<p>The configuration page for the Spark Interpreter also allows you to specify library dependencies from the local filesystem
or from a Maven repository, as described in <a href="https://zeppelin.apache.org/docs/latest/manual/dependencymanagement.html">Dependency Management</a>
in the Zeppelin documentation.</p>

<h3>java.lang.NoSuchMethodError: scala.runtime.VolatileByteRef.create(B)Lscala/runtime/VolatileByteRef;</h3>

<p>This error appears in the Zeppelin logs when there is a mismatch between Scala versions. Make sure that the Zeppelin distribution you have
installed was built with the same version of Scala as your Spark distribution, as described in the "Installing Apache Zeppelin" section.</p>
	
<bu:rFooter>
	<bu:rLinks>
		<li><a href="https://zeppelin.apache.org/docs/latest/">Zeppelin Documentation</a></li>
		<li><a href="https://zeppelin.apache.org/docs/latest/manual/interpreterinstallation.html">Interpreter Installation</a> in the Zeppelin Documentation</li>
		<li><a href="https://zeppelin.apache.org/docs/latest/manual/dependencymanagement.html">Dependency Management</a> in the Zeppelin Documentation</li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>2017-06-09: Updated for Zeppelin 0.7.1.	(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-25">SPARKOUR-25</a>).</li>
		<li>2018-05-27: Updated for Zeppelin 0.7.3.	(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-28">SPARKOUR-28</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>