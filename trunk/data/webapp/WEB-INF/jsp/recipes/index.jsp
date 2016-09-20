<%@ include file="../shared/header.jspf" %>
<c:set var="pageTitle" value="Recipes" />
<script type="text/javascript">
	$(document).ready(function() {
		rememberLastRecipeTab();
		registerTabClicks("Toc");
	});
</script>
<%@ include file="../shared/headerSplit.jspf" %>

<div class="tabsContainer">
    <ul class="tabsMenu tabsTocMenu">
    	<li><a href=".tab-1">Spark Tutorials (6)</a></li>
        <li><a href=".tab-2">Spark Development (8)</a></li>
        <li><a href=".tab-3">Spark Integration (4)</a></li>
    </ul>
    <div class="tabContentPane tabTocContentPane">
    	<bu:rTab index="1">
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
    	</bu:rTab><bu:rTab index="2">
    		<p>These recipes are targeted, adaptable examples of useful Spark code addressing common developer needs. They assume some familiarity
			with the concepts explained in the tutorials.</p>
			
			<ul>
				<li><span class="rCategory">Libraries: Spark GraphX</span><ul>
				</ul></li>
				<li><span class="rCategory">Libraries: Spark MLLib Library</span><ul>
				</ul></li>
				<li><span class="rCategory">Libraries: Spark Streaming</span><ul>
				</ul></li>
				<li><span class="rCategory">Libraries: Spark SQL</span><ul>
					<li><bu:rLink id="working-dataframes" /></li>
					<li><bu:rLink id="using-sql-udf" /></li>
					<li><bu:rLink id="using-jdbc" /></li>
					<li><bu:rLink id="controlling-schema" /></li>
					<li>Using Hive Tables with Spark DataFrames</li>
				</ul></li>
				<li><span class="rCategory">Practices</span><ul>
					<li><bu:rLink id="building-maven" /></li>
					<li><bu:rLink id="building-sbt" /></li>
					<li><bu:rLink id="broadcast-variables" /></li>
					<li><bu:rLink id="aggregating-accumulators" /></li>
					<li>Simplifying Java Applications with Lambda Expressions</li>
					<li>Writing Unit Tests</li>
				</ul></li>
			</ul>    	
			
			<p>Unlinked titles depict the roadmap of recipes I would like to tackle next -- the titles will become links as they are published.
			Suggestions for new recipes can be submitted through the <a href="${issuesUrl}">Issues</a> page.</p>
    	</bu:rTab><bu:rTab index="3">
			<p>These recipes are targeted, adaptable examples of useful Spark code addressing common developer needs. They assume some familiarity
			with the concepts explained in the tutorials.</p>
			
	    	<ul>
				<li><span class="rCategory">Clusters</span><ul>
					<li><bu:rLink id="spark-ec2" /></li>
					<li>Configuring Job Scheduling</li>
					<li>Using Apache Hadoop YARN as a Cluster Manager</li>
					<li>Using Apache Mesos as a Cluster Manager</li>
				</ul></li>
				<li><span class="rCategory">Data Sources: S3</span><ul>
					<li><bu:rLink id="configuring-s3" /></li>
					<li><bu:rLink id="using-s3" /></li>
					<li><bu:rLink id="s3-vpc-endpoint" /></li>
				</ul></li>
				<li><span class="rCategory">Data Sources: Other</span><ul>	
					<li>Using HDFS as a Data Store</li>
				</ul></li>	
				<li><span class="rCategory">Logging and Monitoring</span><ul>
					<li>Enabling History in Your Master UI</li>
					<li>Monitoring Your Cluster with the REST API</li>
					<li>Capturing Metrics with slf4j</li>
				</ul></li>
				<li><span class="rCategory">Security</span><ul>
					<li>Adding Authentication to Spark UIs</li>
					<li>Running Spark over SSL</li>
				</ul></li>
				<li><span class="rCategory">Tuning</span><ul>
					<li>Configuring Shuffle Behavior</li>
					<li>Using Amazon CloudWatch to Profile Your Workload</li>
					<li>Using Kryo for Memory-Efficient Data Serialization</li>
					<li>Using Spark Metrics to Profile Your Workload</li>
				</ul></li>
			</ul>
			
			<p>Unlinked titles depict the roadmap of recipes I would like to tackle next -- the titles will become links as they are published.
			Suggestions for new recipes can be submitted through the <a href="${issuesUrl}">Issues</a> page.</p>
    	</bu:rTab>
    </div>
</div>

<%@ include file="../shared/footer.jspf" %>