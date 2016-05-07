<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-05-08">
	<h3>Synopsis</h3>
	<p>This recipe </p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need a development environment with your primary programming language and Apache Spark installed, as
			covered in <bu:rLink id="submitting-applications" />.</li>
	</ol>		

	<h3>Target Versions</h3>
	<ol>
		<li>Accumulators existed in Spark as early as <span class="rPN">0.5.2</span>. Any modern version should work with this recipe.</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">What Is An Accumulator?</a></li>
		<li><a href="#02">Using Accumulators</a></li>
	</ul>
</bu:rOverview>
		
<bu:rSection anchor="01" title="What Is An Accumulator?" />
<bu:rSection anchor="02" title="Using Accumulators" />

Accumulators
	Background
		Tutorial #5 on Multithreaded / Shared Variables
	Uses
		Calculating a side-effect of running Spark operations
			count errors / statistics
	Properties
		Associative: operations can be regrouped: (1+3)+4 = 1+(3+4)
		Commutative operands can be moved around: 1+3 = 3+1
			sum / max are examples
		Can be given a name to appear in Spark UI
		Obey same lazy rules as transformation/action
		Write-only from Workers, Read by Driver
	Caveats
		Accumulator in Action guaranteed to run only once. (e.g. foreach)
		Accumulator in Transformation might run multiple times
			Speculative
			Task Failure / Re-execution
			If executor fails, that accumulator is lost
		AccumulatorV2
			https://issues.apache.org/jira/browse/SPARK-14654
		Not in SparkR yet
			https://issues.apache.org/jira/browse/SPARK-6815
	Numeric
		Int, Double, Long, Float
	Custom
		
		
		
		

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/programming-guide.html#accumulators">Accumulators</a> in the Spark Programming Guide</li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>