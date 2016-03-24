<%@ include file="../shared/header.jspf" %>
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-02-26">
	<h3>Synopsis</h3>
	<p>This tutorial offers a whirlwind tour of important Apache Spark concepts.
	There is no hands-on work involved.
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will understand what Spark is, and how it might satisfy your data processing requirements.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">What Is Spark?</a></li>
		<li><a href="#02">What <i>Isn't</i> Spark?</a></li>
		<li><a href="#03">How Does Spark Deliver on Its Promises?</a></li>
		<li><a href="#04">When Should I Use Spark?</a></li>
		<li><a href="#05">Conclusion</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="What Is Spark?" />

<p>Apache Spark is an open-source framework for distributed data processing. A developer that uses the Spark
ecosystem in an application can focus on his or her domain-specific data processing business case, while trusting that Spark will handle the 
messy details of parallel computing, such as data partitioning, job scheduling, and fault-tolerance. This 
separation of concerns supports the flexibility and scalability needed to handle massive volumes of data efficiently.</p>

<p>Spark is deployed as a <span class="rPN">cluster</span> consisting of a master server and many worker servers. The master
server accepts incoming jobs and breaks them down into smaller tasks that can be handled by workers. A cluster includes 
tools for logging and monitoring progress and status. Profiling metrics to support a decision on whether to
improve performance with additional workers is easily accessible.</p> 

<p>Spark increases processing efficiency by implementing <span class="rPN">Resilient Distributed Datasets</span> (RDDs), which are
immutable, fault-tolerant collections of objects. RDDs can be built from any arbitrary dataset, such as a text file in Amazon S3,
or an array of integers in the application itself. With Spark, your application can perform <span class="rPN">transformations</span>
on RDDs to create new RDDs, or <span class="rPN">actions</span> that return the result of some computation. Spark transformations
are "lazy", which means that they are not actually executed until an action is called. This reduces processing churn,
making Spark more appropriate for iterative data processing workflows where more than one pass across the data might be needed.</p>

<p>Spark is an open-source project (under the Apache Software Foundation) with a healthy developer community and
<a href="http://spark.apache.org/docs/latest/">extensive documentation</a> (dispelling the myth that
all open-source documentation is a barren wasteland of incomplete JavaDocs). Adopting Spark provides the
intrinsic benefits of open-source software (OSS), such as plentiful community support, rapid releases, 
and shared innovation. Spark is released under the Apache License 2.0, which tends to scare the potential customers 
of your application much less than some "copyleft" licenses.</p>

<bu:rSection anchor="02" title="What <i>Isn't</i> Spark?" />

<ul>
	<li>Spark is not a <span class="rPN">data storage solution</span>:<br />
		Spark requires some other storage provider to store your source data and saved, processed data.
		It can accept data from a wide variety of storage options (such as your local filesystem, Amazon S3, the Hadoop Distributed File System [HDFS], 
		or Apache Cassandra) but it does not implement storage itself.</li>
	<li>Spark is not a <span class="rPN">Hadoop Killer</span>:<br />
		In spite of some articles with clickbait headlines, Spark is actually a complementary addition to Apache Hadoop, rather than a replacement.
		It's designed to integrate well with components from the Hadoop ecosystem (such as HDFS, Hive, or YARN). Spark can be used to extend Hadoop,
		especially in use cases where the Hadoop MapReduce paradigm has become a limiting factor in the scalability of your solution. Conversely,
		you don't need to use Hadoop at all if Spark satisfies your requirements on its own.</li>
	<li>Spark is not a <span class="rPN">miracle product</span>:<br />
		At the end of the day, Spark is just a collection of very useful Application Programming Interfaces (APIs). 
		It's not a shrinkwrapped product that you turn on and set loose on your data for immediate benefit. As the domain expert
		on your data, you still need to write the application that extracts value from that data. Spark just makes your
		job much easier.</li>
</ul>

<bu:rSection anchor="03" title="How Does Spark Deliver on Its Promises?" />

<p>The <a href="https://spark.apache.org/">Apache Spark homepage</a> touts 4 separate benefits:</p>

<ol>
	<li><span class="rPN">Speed</span>: With its implementation of RDDs and the ability to cluster, Spark is much faster than a comparable job executed with Hadoop MapReduce.
		Additionally, Spark prefers in-memory computation wherever possible, greatly reducing file I/O as a bottleneck.</li>
	<li><span class="rPN">Ease of Use</span>: Although Spark itself was originally written in Scala, the Spark API is offered in Java, Python, R, and Scala. 
		This greatly reduces the barrier of entry for developers who already know at least one of these languages. 
		The official documentation includes code samples in multiple languages as well.</li>

	<img src="${localImagesUrlBase}/components.png" width="686" height="170" title="Spark includes modules supporting a broad set of use cases." class="diagram border" />

	<li><span class="rPN">Generality</span>: Spark includes four targeted libraries built on top of its Core API, as shown in the image above.
		<span class="rPN">Spark Streaming</span> supports streaming data sources (such as Twitter feeds) while <span class="rPN">Spark SQL</span> provides options for exploring and mining
		data in ways much closer to the mental model of a data analyst. <span class="rPN">MLLib</span> enables machine learning use cases and <span class="rPN">GraphX</span>
		is available for graph computation. Previously, each of these areas might have been served by a different tool that needed to be integrated into your solution. Spark makes
		it easy to combine these libraries into a single application without extra integration or the need to learn the idiosyncrasies of unrelated tools.</li>
	<li><span class="rPN">Runs Everywhere</span>: Spark focuses narrowly on the complexities of data processing, leaving several technology choices in your hands.
		Data can originate from many compatible storage solutions. Spark clusters can be managed by Spark's "Standalone" cluster manager or another popular manager (Apache Mesos or Hadoop YARN).
		Finally, Spark's cluster is very conducive to deployment in a cloud environment (with helpful scripts provided for Amazon Web Services in particular). This greatly
		increases the tuning options and scalability of your application.</li>
</ol>

<bu:rSection anchor="04" title="When Should I Use Spark?" />

<p>Spark is quite appropriate for a broad swath of data processing use cases, such as data transformation, analytics, batch computation, and machine learning. 
The generality of Spark means that there isn't a single use case it's best for. 
Instead, consider using Spark if some of these conditions apply to your scenario.</p>

<ol>
	<li>You are starting a new application.</li>
	<li>You expect to have massive datasets (on the order of petabytes).</li>
	<li>You expect to integrate with a variety of data sources or the Hadoop ecosystem.</li>
	<li>You expect to need more than one of Spark's libraries (e.g. MLLib and SQL) in the same application.</li>
	<li>Your data processing workflow is a pipeline of iterative steps that might be refined in multiple passes fairly dynamically.</li>
	<li>Your data processing workflow would be limited by the rigidity or performance of Hadoop MapReduce.</li>
</ol>

<bu:rSection anchor="05" title="Conclusion" />

<p>You have now gotten a taste of Apache Spark in theory, and are ready to do some hands-on work. 
In the next tutorial, <bu:rLink id="installing-ec2" />, we install Apache Spark
on an Amazon EC2 instance.</p> 

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/">Apache Spark documentation</a></li>
		<li><a href="http://spark.apache.org/faq.html">Apache Spark FAQ</a></li>	
		<li><a href="https://en.wikipedia.org/wiki/Apache_Spark">Apache Spark</a> on Wikipedia</li>	
	</bu:rLinks>
	<bu:rChangeLog>
		<li>This tutorial hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>
	
<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>