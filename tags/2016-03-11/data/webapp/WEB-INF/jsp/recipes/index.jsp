<%@ include file="../shared/header.jspf" %>
<c:set var="pageTitle" value="Recipes" />
<%@ include file="../shared/headerSplit.jspf" %>

<div class="tabsContainer">
    <ul class="tabsMenu">
    	<li class="tabCurrent"><a href=".tab-2">Spark Tutorials (6)</a></li>
        <li><a href=".tab-3">Spark Development (1)</a></li>
        <li><a href=".tab-4">Spark Integration (3)</a></li>
    </ul>
    <div class="tabContentPane">
    	<bu:rTab index="2">
			<p>These sequential tutorial recipes are intended for developers just getting started with Spark. 
			Developers should have some familiarity with the Linux command line and common tasks like running shell scripts.</p>
			
			<ul>
				<li><bu:rLink id="sparkour-conventions" /></li>
				<li><bu:rLink id="spark-nutshell" /></li>
				<li><bu:rLink id="installing-ec2" /></li>
				<li><bu:rLink id="managing-clusters" /></li>
				<li><bu:rLink id="submitting-applications" /></li>
				<li><bu:rLink id="working-rdds" /></li>
			</ul>
    	</bu:rTab><bu:rTab index="3">
    		<p>These recipes are targeted, adaptable examples of useful Spark code addressing common developer needs. They assume some familiarity
			with the concepts explained in the tutorials.</p>
			
			<ul>
				<li>Libraries: Spark GraphX<ul>
				</ul></li>
				<li>Libraries: Spark MLLib Library<ul>
				</ul></li>
				<li>Libraries: Spark Streaming<ul>
				</ul></li>
				<li>Libraries: Spark SQL<ul>
					<li><bu:rLink id="working-dataframes" /></li>
					<li>Applying User-Defined Functions and Raw SQL to Spark DataFrames</li>
					<li>Controlling the Schema of a DataFrame</li>
					<li>Using JDBC with Spark DataFrames</li>
					<li>Using Hive Tables with Spark DataFrames</li>
					<li>Working with Spark Datasets</li>
				</ul></li>
				<li>Practices<ul>
					<li>Bundling Dependencies with Java and Maven</li>
					<li>Bundling Dependencies with Python and egg Files</li>
					<li>Bundling Dependencies with Scala and sbt</li>
					<li>Simplifying Java Applications with Lambda Expressions</li>
					<li>Using Accumulators</li>
					<li>Using Broadcast Variables</li>
					<li>Writing Unit Tests</li>
				</ul></li>
			</ul>    	
    	</bu:rTab><bu:rTab index="4">
			<p>These recipes are targeted, adaptable examples of useful Spark code addressing common developer needs. They assume some familiarity
			with the concepts explained in the tutorials.</p>
			
	    	<ul>
				<li>Clusters<ul>
					<li><bu:rLink id="spark-ec2" /></li>
					<li>Configuring Job Scheduling</li>
					<li>Using Apache Hadoop YARN as a Cluster Manager</li>
					<li>Using Apache Mesos as a Cluster Manager</li>
				</ul></li>
				<li>Data Sources: S3<ul>
					<li><bu:rLink id="configuring-s3" /></li>
					<li><bu:rLink id="using-s3" /></li>
					<li>Adding a VPC Endpoint for Amazon S3</li>
				</ul></li>
				<li>Data Sources: Other<ul>	
					<li>Using HDFS as a Data Store</li>
				</ul></li>	
				<li>Logging and Monitoring<ul>
					<li>Enabling History in Your Master UI</li>
					<li>Monitoring Your Cluster with the REST API</li>
					<li>Capturing Metrics with slf4j</li>
				</ul></li>
				<li>Security<ul>
					<li>Adding Authentication to Spark UIs</li>
					<li>Running Spark over SSL</li>
				</ul></li>
				<li>Tuning<ul>
					<li>Configuring Shuffle Behavior</li>
					<li>Using Amazon CloudWatch to Profile Your Workload</li>
					<li>Using Kryo for Memory-Efficient Data Serialization</li>
					<li>Using Spark Metrics to Profile Your Workload</li>
				</ul></li>
			</ul>
    	</bu:rTab>
    </div>
</div>

<p>Unlinked titles depict the roadmap of recipes I would like to tackle next -- the titles will become links as they are published.
Suggestions for new recipes can be submitted through the <a href="${issuesUrl}">Issues</a> page.</p>

<%@ include file="../shared/footer.jspf" %>