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
	<bu:newsUpdate date="2016-03-26">
		<bu:rLink id="using-sql-udf" /> demonstrates how to query Spark DataFrames with Structured Query Language (SQL). The SparkSQL library
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

	<div id="newsFeedControl" class="expand"><a href="#" onClick="return false;">more...</a></div>	
	<div id="oldNews" class="hidden">
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
			My long-term goal is to publish one or two new standalone recipes per week until the end of time. Help me improve Sparkour
			by submitting bugs and improvement suggestions on the <a href="${issuesUrl}">Issues</a> page.
		</bu:newsUpdate>	
		<bu:newsUpdate date="2016-02-22">
			The Sparkour website is online. Visiting <span class="rCW">sparkour.net</span> will redirect you here if you forget the full hostname.
		</bu:newsUpdate>
		<bu:newsUpdate date="2016-02-15">		
			The idea for Sparkour was conceived during the President's Day ice storm.
		</bu:newsUpdate>
	</div>
</div>

<h2>About the Author</h2>

<p><img src="${imagesUrlBase}/author.jpg" width="104" height="120" title="BU" class="border" align="left" />
<a href="https://www.linkedin.com/in/urizone">Brian Uri!</a> is a software engineer at the advanced analytics company,
<a href="http://www.novetta.com/">Novetta</a>, where he provides technical leadership, data strategy, and business development support
across multiple Department of Defense / Intelligence Community projects. He has over a decade of experience in software development 
and government data standards, with relevant certifications in Apache Hadoop and Amazon Web Services.
Brian is also the creator of the open-source library, <a href="https://ddmsence.urizone.net/">DDMSence</a>.</p> 

<p>Sparkour was conceived in February 2016 as a way for Brian to learn Apache Spark while scratching an itch to create more open-source software.</p>

<%@ include file="../shared/footer.jspf" %>