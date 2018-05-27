<%@ include file="../shared/header.jspf" %>
<c:set var="pageTitle" value="Home" />
<c:set var="hideHeaderTitle" value="true" />
<script type="text/javascript">
	$(document).ready(function() {
		$("div.expand").click(
			function() {
				$(this).hide("fast");
				$(this).next().show("fast");
			});
		});
</script>
<%@ include file="../shared/headerSplit.jspf" %>

<h1>Sparkour</h1>

<img src="${imagesUrlBase}/logo-256.png" width="160" height="160" title="Sparkour" align="right" />

<!-- Description locations: index.jsp, header.jspf, LICENSE.txt, Issues -->
<p>Sparkour is an open-source collection of programming recipes for <a href="https://spark.apache.org/">Apache Spark</a>.
Designed as an efficient way to navigate the intricacies of the Spark ecosystem,
Sparkour aims to be an approachable, understandable, and actionable cookbook for distributed data processing.</p>

<p>Sparkour delivers extended tutorials for developers new to Spark as well as shorter, standalone recipes 
that address common developer needs in Java, Python, R, and Scala. The entire trove is 
<a href="${licenseUrl}">licensed</a> under the Apache License 2.0.</p> 

<h2>What's New? <a href="${filesUrlBase}/atom.xml"><img src="${imagesUrlBase}/atom.png" width="20" height="20" title="Atom Feed" /></a></h2>

<div id="newsFeed">
	<bu:newsUpdate date="2018-05-27">
		All recipes have been updated and tested against Spark 2.3.0 and Scala 2.11.12.
	</bu:newsUpdate>
	<bu:newsUpdate date="2017-08-05">
		All recipes have been updated and tested against Spark 2.2.0.
	</bu:newsUpdate>	
	<bu:newsUpdate date="2017-05-29">
		All recipes have been updated and tested against Spark 2.1.1 and Scala 2.11.11.
	</bu:newsUpdate>	
	<bu:newsUpdate date="2016-10-09">
		All recipes have been updated and tested against Spark 2.0.1.
	</bu:newsUpdate>	
	<bu:newsUpdate date="2016-09-24">
		<bu:rLink id="understanding-sparksession" />
		introduces the new <span class="rCW">SparkSession</span> class from Spark 2.0, which provides a unified entry point
		for all of the various Context classes previously found in Spark 1.x.
	</bu:newsUpdate>
	<bu:newsUpdate date="2016-09-22">
		<bu:rLink id="installing-zeppelin" />
		explains how to install Apache Zeppelin and configure it to work with Spark. Interactive notebooks 
		such as Zeppelin make it easier for analysts (who may not be software developers) to harness the power of Spark
		through iterative exploration and built-in visualizations.
	</bu:newsUpdate>
	<div id="newsFeedControl" class="expand"><a href="#" onClick="return false;">more...</a></div>	
	<div id="oldNews" class="hidden">
		<bu:newsUpdate date="2016-09-21">
			Website statistics prove that developers love Sparkour (except on the weekends). Thanks for your continued support!<br /> 
			<img src="${imagesUrlBase}/stats-160921.png" width="589" height="240" title="Visitor Stats" class="diagram border" />
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-09-20">
			All recipes have been updated to use the new features available in Spark 2.0.0, such as the <span class="rCW">SparkSession</span>
			and the new Accumulator API. I will focus exclusively on Spark 2.x in future recipes, as that is the release most in 
			need of solid documentation.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-06-28">
			All recipes have been updated and tested against Spark 1.6.2.
		</bu:newsUpdate>	
		<bu:newsUpdate date="2016-05-07">
			<bu:rLink id="aggregating-accumulators" />
			explains how to use accumulators to aggregate results in a Spark application.
			Accumulators provide a safe way for multiple Spark workers to contribute information to
			a shared variable, which can then be read by the application driver.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-05-04">
			<bu:rLink id="controlling-schema" />
			demonstrates different strategies for defining the schema of a DataFrame built from various data sources (using
			RDD and JSON as examples). Schemas can be inferred from metadata or the data itself, or programmatically specified in advance
			in your application.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-04-14">
			<bu:rLink id="broadcast-variables" />
			explains how to use broadcast variables to distribute immutable reference data across a Spark cluster. Using
			broadcast variables can improve performance by reducing the amount of network traffic and data serialization required 
			to execute your Spark application.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-04-13">
			<bu:rLink id="s3-vpc-endpoint" />
			shows how to set up a VPC Endpoint for Amazon S3, which allows your Spark cluster to interact with S3 resources from a private subnet 
			without a Network Address Translation (NAT) instance or Internet Gateway.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-04-07">
			All recipes have been updated and tested against Spark 1.6.1.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-29">
			<bu:rLink id="building-maven" />
			covers the use of Apache Maven to build and bundle Spark applications
			written in Java or Scala. It focuses very narrowly on a subset of commands relevant to Spark applications, including
			managing library dependencies, packaging, and creating an assembly JAR file.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-26">
			<bu:rLink id="using-sql-udf" /> demonstrates how to query Spark DataFrames with Structured Query Language (SQL). The Spark SQL library
			supports SQL as an alternate way to work with DataFrames that is compatible with the code-based approach discussed in
			the recipe, <bu:rLink id="working-dataframes" />.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-24">
			<bu:rLink id="using-jdbc" />
			 shows how Spark DataFrames can be read from or written to relational database tables with Java Database Connectivity (JDBC).
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-17">
			<bu:rLink id="building-sbt" />
			covers the use of SBT (Simple Build Tool or, sometimes, Scala Build Tool) to build and bundle Spark applications
			written in Java or Scala. It focuses very narrowly on a subset of commands relevant to Spark applications, including
			managing library dependencies, packaging, and creating an assembly JAR file with the <span class="rCW">sbt-assembly</span> plugin.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-15">
			<bu:rLink id="submitting-applications" />
			has been updated to include examples in Java, R, and Scala as well as the original Python.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-11">
			<bu:rLink id="working-dataframes" />
			provides a straightforward introduction to the Spark DataFrames API. It uses common DataFrames operators to explore and transform raw data
			from the 2016 Democratic Primary in Virginia.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-06">
			<bu:rLink id="using-s3" />
			provides the steps needed to securely connect an Apache Spark cluster running on Amazon EC2	to data stored in Amazon S3.
			It contains instructions for both the classic <span class="rCW">s3n</span> protocol and the newer, but still maturing, 
			<span class="rCW">s3a</span> protocol.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-05">
			<bu:rLink id="configuring-s3" />
			provides the steps needed to securely expose data in Amazon S3 for consumption by a Spark application.
			The resultant configuration works with both supported S3 protocols in Spark: the classic <span class="rCW">s3n</span> 
			protocol and the newer, but still maturing, <span class="rCW">s3a</span> protocol.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-03-04">	
			<bu:rLink id="spark-ec2" />
			describes how to automatically launch, start, stop, or destroy a Spark cluster running in Amazon EC2. 
			It steps through the pre-launch configuration, explains the script's most common parameters, and points out where 
			specific parameters can be found in the AWS Management Console.
		</bu:newsUpdate>	
		<bu:newsUpdate date="2016-03-01">	
			Welcome to Sparkour! 
			To kick things off, I have released 5 sequential <a href="${recipesUrl}">tutorials</a>, which should give you a solid foundation for mastering Spark.
			My long-term goal is to publish a few new recipes each month until the end of time. Help me improve Sparkour
			by submitting bugs and improvement suggestions on the <a href="${issuesUrl}">Issues</a> page.
		</bu:newsUpdate>	
		<bu:newsUpdate date="2016-02-22">
			The Sparkour website is online.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-02-15">		
			The idea for Sparkour was conceived during the President's Day ice storm.
		</bu:newsUpdate>
	</div>
</div>

<h2>About the Author</h2>

<p><img src="${imagesUrlBase}/author.jpg" width="120" height="120" title="BU" class="border" align="left" />
<a href="https://www.linkedin.com/in/urizone">Brian Uri!</a> is a solutions architect at the advanced analytics company,
<a href="http://www.novetta.com/">Novetta</a>. He has over a decade of experience in software development 
and government data standards, with relevant certifications in Apache Hadoop and Amazon Web Services.</p>

<p>Sparkour was conceived in February 2016 as a way for Brian to learn Apache Spark while scratching an itch to create more open-source software. 
Brian is also the creator of the open-source library, <a href="https://ddmsence.urizone.net/">DDMSence</a>.</p> 

</p>

<%@ include file="../shared/footer.jspf" %>