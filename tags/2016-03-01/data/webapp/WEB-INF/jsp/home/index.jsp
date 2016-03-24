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
	<div class="newsUpdate"><u>2016-03-01</u>: Welcome to Sparkour! 
		To kick things off, I have released 5 sequential tutorials, which should give you a solid foundation for mastering Spark.
		My long-term goal is to publish one or two new standalone recipes per week until the end of time. Help me improve Sparkour
		by submitting bugs and improvement suggestions on the <a href="${issuesUrl}">Issues</a> page.</div>
	<div id="newsFeedControl" class="expand"><a href="#" onClick="return false;">more...</a></div>	
	<div id="oldNews" class="hidden">
		<div class="newsUpdate"><u>2016-02-22</u>: The Sparkour website is online. Visiting <span class="rCW">sparkour.net</span> will redirect you here if you
			forget the full hostname.</div>
		<div class="newsUpdate"><u>2016-02-15</u>: The idea for Sparkour was conceived during the President's Day ice storm.</div>
	</div>
</div>

<h2>About the Author</h2>

<p><img src="${imagesUrlBase}/author.jpg" width="104" height="120" title="BU" class="border" align="left" />
<a href="https://www.linkedin.com/profile/view?id=10317277">Brian Uri!</a> is a software engineer at the advanced analytics company,
<a href="http://www.novetta.com/">Novetta</a>, where he provides technical leadership, data strategy, and business development support
across multiple Department of Defense / Intelligence Community projects. He has over a decade of experience in software development 
and government data standards, with relevant certifications in Apache Hadoop and Amazon Web Services.
Brian is also the creator of the open-source library, <a href="https://ddmsence.urizone.net/">DDMSence</a>.</p> 

<p>Sparkour was conceived in February 2016 as a way for Brian to learn Apache Spark while scratching an itch to create more open-source software.</p>

<%@ include file="../shared/footer.jspf" %>