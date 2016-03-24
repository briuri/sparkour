<%@ include file="../shared/header.jspf" %>
<c:set var="pageTitle" value="Recipes" />
<%@ include file="../shared/headerSplit.jspf" %>

<h2>Tutorials</h2>

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

<h2>Standalone Recipes</h2>

<p>These recipes are targeted, adaptable examples of useful Spark code addressing common developer needs. Initially, this is just a roadmap
of the recipes I would like to tackle next -- the titles will become links as they are published.
Suggestions for new recipes can be submitted through the <a href="${issuesUrl}">Issues</a> page.</p>

<h3>Spark Components</h3>
<ul>
	<li>Using Shared Variables in an Application</li>
	<li>Using Spark DataFrames in an Application</li>
	<li>Using Spark Datasets in an Application</li>
	<li>Using Spark GraphX in an Application</li>
	<li>Using Spark MLLib in an Application</li>
	<li>Using Spark SQL in an Application</li>
	<li>Using Spark Streaming in an Application</li>
	<li>Using SparkR in an Application</li>
</ul>

<h3>Spark Development</h3>
<ul>
	<li>Creating an "Uber Jar" for Submission</li>
	<li>Simplifying Java Applications with Lambda Expressions</li>
	<li>Writing Unit Tests for Your Application</li>
</ul>

<h3>Spark Integration</h3>
<ul>
	<li>Clustering<ul>
		<li>Job Scheduling Configuration</li>
		<li>Managing a Cluster with the spark-ec2 Script</li>
		<li>Using Apache Hadoop YARN as a Cluster Manager</li>
		<li>Using Apache Mesos as a Cluster Manager</li>
	</ul></li>
	<li>Data Sources<ul>
		<li>Using Amazon S3 as a Data Store</li>
		<li>Using HDFS as a Data Store</li>
	</ul></li>	
	<li>Logging and Monitoring<ul>
	</ul></li>
	<li>Security<ul>
		<li>Adding Authentication to Spark UIs</li>
		<li>Running Spark over SSL</li>
	</ul></li>
	<li>Tuning<ul>
		<li>Using Amazon CloudWatch to Profile Your Workload</li>
		<li>Using Spark Metrics to Profile Your Workload</li>
		<li>Configuring Shuffle Behavior</li>
	</ul></li>
</ul>

<%@ include file="../shared/footer.jspf" %>