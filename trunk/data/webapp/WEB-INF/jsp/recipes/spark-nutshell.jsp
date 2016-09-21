<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
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
		<li><a href="#05">What's the Best Programming Language for Spark?</a></li>
		<li><a href="#06">Conclusion</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="What Is Spark?" />

<p>Apache Spark is an open-source framework for distributed data processing. A developer that uses the Spark
ecosystem in an application can focus on his or her domain-specific data processing business case, while trusting that Spark will handle the 
messy details of parallel computing, such as data partitioning, job scheduling, and fault-tolerance. This 
separation of concerns supports the flexibility and scalability needed to handle massive volumes of data efficiently.</p>

<p>Spark is deployed as a <span class="rPN">cluster</span> consisting of a master server and many worker servers. The master
server accepts incoming jobs and breaks them down into smaller tasks that can be handled by workers. A cluster includes 
tools for logging and monitoring progress and status. Profiling metrics are easily accessible, and can support the 
decision on when to improve performance with additional workers or code changes.</p> 

<p>Spark increases processing efficiency by implementing <span class="rPN">Resilient Distributed Datasets</span> (RDDs), which are
immutable, fault-tolerant collections of objects. RDDs are foundation for all high-level Spark objects (such as <span class="rPN">DataFrames</span>
and <span class="rPN">Datasets</span>) and can be built from any arbitrary data, such as a text file in Amazon S3,
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
		Spark is a stateless computing engine that acts upon data from somewhere else.
		It requires some other storage provider to store your source data and saved, processed data, and
		supports a wide variety of options (such as your local filesystem, Amazon S3, the Hadoop Distributed File System [HDFS], 
		or Apache Cassandra), but it does not implement storage itself.</li>
	<li>Spark is not a <span class="rPN">Hadoop Killer</span>:<br />
		In spite of some articles with clickbait headlines, Spark is actually a complementary addition to Apache Hadoop, rather than a replacement.
		It's designed to integrate well with components from the Hadoop ecosystem (such as HDFS, Hive, or YARN). Spark can be used to extend Hadoop,
		especially in use cases where the Hadoop MapReduce paradigm has become a limiting factor in the scalability of your solution. Conversely,
		you don't need to use Hadoop at all if Spark satisfies your requirements on its own.</li>
	<li>Spark is not an <span class="rPN">in-memory computing engine</span>:<br />
		Spark exploits in-memory processing as much as possible to increase performance, but employs complementary approaches in memory usage, disk usage, and data
		serialization to operate pragmatically within the limitations of the available infrastructure. Once memory resources are exhausted, Spark can spill the overflow 
		data onto disk and continue processing.</li>
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
		it easy to combine these libraries into a single application without extra integration or the need to learn the idiosyncrasies of unrelated tools. In addition,
		<a href="http://spark-packages.org/">Spark Packages</a> provides an easy way to discover and integrate third-party tools and libraries.</li>
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
	<li>You are starting a new data processing application.</li>
	<li>You expect to have massive datasets (on the order of petabytes).</li>
	<li>You expect to integrate with a variety of data sources or the Hadoop ecosystem.</li>
	<li>You expect to need more than one of Spark's libraries (e.g. MLLib and SQL) in the same application.</li>
	<li>Your data processing workflow is a pipeline of iterative steps that might be refined in multiple passes fairly dynamically.</li>
	<li>Your data processing workflow would be limited by the rigidity or performance of Hadoop MapReduce.</li>
</ol>

<bu:rSection anchor="05" title="What's the Best Programming Language For Spark?" />

<p>Spark applications can be written in Java, Python, R, or Scala, and the language you pick should be a pragmatic decision based on your skillset and application
requirements.</p>

<ul>
	<li>From an <span class="rPN">ease of adoption</span> perspective, Python offers a friendly, forgiving entry point, especially if you're coming from a data science
		background. In 2015, Scala and Python were the most frequently used languages for Spark development, and this larger user base makes it much
		easier to seek out help and discover useful example code. Java is hampered by its lack of a Spark interactive shell, which allows you to test Spark 
		commands in real-time.</li>
	<li>From a <span class="rPN">feature completeness</span> perspective, Scala is the obvious choice. Spark itself is written in Scala, and APIs in the other three languages
		are built on top of the Scala API, as shown in the image below. New features are published to the Scala API first, and it may take a few releases for the features to
		propogate up to the other APIs. R is the least feature-complete at the moment, but active development work continues to improve this situation.</li> 

	<img src="${localImagesUrlBase}/languages.png" width="750" height="336" title="Spark includes APIs in Java, Scala, Python, and R." class="diagram border" />
	
	<li>From a <span class="rPN">performance</span> perspective, the compiled languages (Java and Scala) provide better general performance than the
		interpreted languages (Python and R) in <i>most</i> cases. However, this should not be accepted as a blanket truth without profiling, and you should be careful not
		to select a language solely on the basis of performance. Aim for developer productivity and code readability first, and optimize later when you have a legitimate
		performance concern.</li>
</ul>

<p>My personal recommendation (as a developer with 20 years of Java experience, 2 years of Python experience, and miscellaneous dabbling in the other languages) would
be to favour Python for learning and smaller applications, and Scala for enterprise projects. There's absolutely nothing wrong with writing Spark code in Java, but it 
sometimes feels unnecessarily inflexible, like running a marathon with shoes one size too small. Until the R API is more mature, I would only consider R
if I had specific requirements for pulling parts of Spark into an existing R environment. Feel free to disregard these recommendations if they don't align with your views.</p>

<bu:rSection anchor="06" title="Conclusion" />

<p>You have now gotten a taste of Apache Spark in theory, and are ready to do some hands-on work. 
In the next tutorial, <bu:rLink id="installing-ec2" />, we install Apache Spark
on an Amazon EC2 instance.</p> 

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/">Apache Spark documentation</a></li>
		<li><a href="http://spark.apache.org/faq.html">Apache Spark FAQ</a></li>	
		<li><a href="https://en.wikipedia.org/wiki/Apache_Spark">Apache Spark</a> on Wikipedia</li>
		<li><a href="http://spark-packages.org/">Spark Packages</a></li>	
	</bu:rLinks>
	<bu:rChangeLog>
		<li>2016-03-29: Updated with a section comparing the available programming languages
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-6">SPARKOUR-6</a>).</li>
		
	</bu:rChangeLog>
</bu:rFooter>
	
<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>