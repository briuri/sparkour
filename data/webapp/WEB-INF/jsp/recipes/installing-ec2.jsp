<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noJavaMessage" value="There is no interactive shell available for Java. You should use one of the other languages to smoke test your Spark installation." />

<bu:rOverview publishDate="2016-02-24">
	<h3>Synopsis</h3>
	<p>This tutorial teaches you how to get a pre-built distribution of Apache Spark running on a Linux server,
	using two Amazon Web Services (AWS) offerings: Amazon Elastic Cloud Compute (EC2) and Identity and Access 
	Management (IAM). We configure and launch an EC2 instance and then install Spark, using the Spark 
	interactive shells to smoke test our installation. The focus is on getting the Spark engine running successfully,
	with many "under the hood" details deferred for now.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need an
			<a href="https://www.amazon.com/ap/signin?openid.assoc_handle=aws&openid.return_to=https%3A%2F%2Fsignin.aws.amazon.com%2Foauth%3Fresponse_type%3Dcode%26client_id%3Darn%253Aaws%253Aiam%253A%253A015428540659%253Auser%252Fhomepage%26redirect_uri%3Dhttps%253A%252F%252Fconsole.aws.amazon.com%252Fconsole%252Fhome%253Fstate%253DhashArgs%252523%2526isauthcode%253Dtrue%26noAuthCookie%3Dtrue&openid.mode=checkid_setup&openid.ns=http://specs.openid.net/auth/2.0&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select&openid.pape.preferred_auth_policies=MultifactorPhysical&openid.pape.max_auth_age=43200&openid.ns.pape=http://specs.openid.net/extensions/pape/1.0&server=/ap/signin&forceMobileApp=&forceMobileLayout=&pageId=aws.ssop&ie=UTF8">AWS account</a>
			to access AWS service offerings. If you are creating a new account, 
			Amazon requires a credit card number on file and telephone verification.</li>
		<li>You need to 
			<a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair">create an EC2 Key Pair</a>
			to login to your EC2 instance.</li>
		<li>You need to <a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html">import your EC2 Key Pair</a> into your favourite
			SSH client, such as <a href="http://www.putty.org/">PuTTY</a>. This allows your SSH client to present a private key 
			instead of a username and password when logging into your EC2 instance.</li>
		<li>You need a general understanding of how
			<a href="https://media.amazonwebservices.com/AWS_Pricing_Overview.pdf">AWS billing works</a>, so
			you can practice responsible server scheduling and you aren't surprised by unexpected charges.</li>
	</ol>
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will be able to configure, launch, start, stop, and terminate an EC2 instance in the AWS Management Console.</li>
		<li>You will have a working Spark environment that you can use to explore other Sparkour recipes.</li>
		<li>You will be able to run commands through the Spark interactive shells.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Why EC2?</a></li>
		<li><a href="#02">Configuring and Launching a New EC2 Instance</a></li>
		<li><a href="#03">Installing Apache Spark</a></li>
		<li><a href="#04">Conclusion</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Why EC2?" />

<p>Before we can install Spark, we need a server. Amazon EC2 is a cloud-based service that allows you to quickly
configure and launch new servers in a pay-as-you-go model. Once it's running, an EC2 instance can be used just like 
a physical machine in your office. The only difference is that it lives somewhere on the Internet, or "in the cloud".
Although we could choose to install Spark on our local development environment, this recipe uses EC2 for the following reasons:</p>

<ol> 
	<li>EC2 results in a clean and consistent baseline, independent of whatever is already installed in your 
		development environment. This makes troubleshooting easier, and reduces the potential number of environment configurations
		to worry about in other Sparkour recipes.</li>
	<li>Conversely, your Spark experimentation on an EC2 instance is isolated from your local development work. 
		If you tend to experiment with violent abandon, you can easily wipe and restore your EC2 instance with minimal risk.</li>
	<li>Becoming familiar with EC2 puts you in a better position to work with Spark clusters spanning multiple servers in
		the future.</li>
</ol>

<p>If you would still prefer to install locally, or you want to use an alternate cloud infrastructure (such as Google Cloud 
or Microsoft Azure) or operating system (such as Microsoft Windows), skip ahead to <a href="#03">Installing Apache Spark</a>
at your own risk. You may need to translate some of the examples to work in your unique environment.</p>

<bu:rSection anchor="02" title="Configuring and Launching a New EC2 Instance" />

<h3>Creating an IAM Role</h3>

<p>First, we need to define an IAM Role for our instance. IAM Roles grant permissions for an instance to work with other 
AWS services (such as Simple Storage Service, or S3). Although it is not strictly necessary for this recipe, it's a good 
practice to always assign an IAM Role to new instances, because a new Role cannot be assigned after the instance is launched.</p>

<ol>
	<li>Login to your <a href="https://console.aws.amazon.com/">AWS Management Console</a> and select the 
		<span class="rPN">Identity &amp; Access	Management</span> service.</li>
	<li>Navigate to <span class="rMI">Roles</span> in the left side menu, and then select
		<span class="rAB">Create New Role</span> at the top of the page, as seen in the image below. 
		This starts a wizard workflow to create a new role.</li>
		
	<img src="${localImagesUrlBase}/iam-roles.png" width="500" height="266" title="Creating an IAM Role for the Spark instance" class="diagram border" />
	
	<li>On <span class="rPN">Step 1. Set Role Name</span>, set the <span class="rK">Role Name</span> to a value
		like <span class="rV">sparkour-app</span> and go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 2. Select Role Type</span>, select <span class="rV">Amazon EC2</span> to establish
		that this role will be applied to EC2 instances. Go to the <span class="rAB">Next Step</span>.</li>
	<li>Step 3 is skipped based on your previous selection. On <span class="rPN">Step 4. Attach Policy</span>, 
		do not select any policies. (We will add policies in other recipes
		when we need our instance to access other services). Go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 5. Review</span>, select <span class="rAB">Create Role</span>. You return
		to the Roles dashboard, and should see your new role listed on the dashboard.</li>
	<li>Exit this dashboard and return to the list of AWS service offerings by selecting the "cube" icon in the upper left corner.</li>
</ol>

<h3>Creating a Security Group</h3>

<p>Next, we create a Security Group to protect our instance. Security Groups contain inbound and outbound rules to allow
certain types of network traffic between our instance and the Internet. We create a new Security Group 
to ensure that our rules don't affect any other instances that might be using the default Security Group.</p>

<ol>
	<li>From the Management Console, select the <span class="rPN">EC2</span> service.</li>
	<li>Navigate to <span class="rMI">Network & Security: Security Groups</span> and select 
		<span class="rAB">Create Security Group</span>. This opens a popup dialog to create the Security Group.</li>
	<li>Set the <span class="rK">Security group name</span> to a value like <span class="rV">sparkour-app-sg</span>
		and set the <span class="rK">Description</span> to <span class="rV">Security Group protecting Spark instance</span>. Leave the group associated with the
		default Virtual Private Cloud (VPC), unless you are an advanced user and have a different VPC preference.</li>
	<li>Select the <span class="rPN">Inbound</span> tab and select <span class="rAB">Add Rule</span>.</li>
	<li>Set the <span class="rK">Type</span> to <span class="rV">SSH</span> and the 
		<span class="rK">Source</span> to <span class="rV">My IP</span>. This allows you to SSH into the instance
		from your current location. If your IP address changes or you need access from a different location, you can
		return here later and update the rule.</li>
	<li>Select <span class="rAB">Add Rule</span> and add another inbound rule. 
		Set the <span class="rK">Type</span> to <span class="rV">Custom TCP Rule</span>,
		the <span class="rK">Port Range</span> to <span class="rV">8080-8081</span>,
		and the <span class="rK">Source</span> to <span class="rV">My IP</span>. 
		This allows you to view the Spark Master and Worker UIs in a web browser (over the default ports).
		If your IP address changes or you need access from a different location, you can return here later and update the rule.</li>
	<li>Your dialog should look similar to the image below.</li>
	
	<img src="${localImagesUrlBase}/security-group.png" width="750" height="358" title="Creating a Security Group" class="diagram" />
			
	<li>Select the <span class="rPN">Outbound</span> tab and review the rules. You can see that all traffic originating from
		your instance is allowed to go out to the Internet by default.</li>
	<li>Select <span class="rAB">Create</span>. You return to the Security Group dashboard and should see your new
		Security Group listed.</li>
	<li>If the <span class="rK">Name</span> column for your new Security Group is blank, click in the blank cell to edit it and
		set it to the same value as the <span class="rK">Group Name</span>. This makes the group's information clearer when it
		appears in other AWS dashboards.</li>  
</ol>

<h3>Creating the EC2 Instance</h3>

<p>We now have everything we need to create the instance itself. We select an appropriate instance type from the wide
variety of <a href="https://aws.amazon.com/ec2/instance-types/">available options</a> tailored for different workloads and
initialize it with Amazon's free distribution of Linux (delivered in the form of an Amazon Machine Image, or AMI).</p>

<p>If you want to create new EC2 instances later on, you can start from this section and reuse the IAM Role and Security 
Group you created earlier.</p>

<ol>
	<li>If you aren't already there, select the <span class="rPN">EC2</span> service from the
		<a href="https://console.aws.amazon.com/">AWS Management Console</a>.</li>
	<li>Navigate to <span class="rMI">Instances: Instances</span> and select <span class="rAB">Launch Instance</span>. 
		This starts a wizard workflow to create the new instance.</li>
	<li>On <span class="rPN">Step 1: Choose an Amazon Machine Image (AMI)</span>, <span class="rAB">Select</span> the
		<span class="rV">Amazon Linux AMI</span> option. This image contains Amazon's free distribution of Linux
		(based on Red Hat) and comes preinstalled with useful extras like Java, Python, and the AWS command line tools.
		If you are an advanced user, you're welcome to select an alternate option, although you may need to install extra dependencies or
		adjust the Sparkour script examples to match your chosen distribution.</li>
	<li>On <span class="rPN">Step 2: Choose Instance Type</span>, select the <span class="rV">m4.large</span>
		instance type. This is a modest, general-purpose server with 2 cores and 8GB of memory that is sufficient for our
		testing purposes. In later recipes, we will discuss how to profile your Spark workload and use the optimal
		configuration of compute-optimized or memory-optimized instance types.<br /><br />Be aware that EC2 instances incur charges
		whenever they are running ($0.12 per hour for m4.large, as of February 2016). If you are a new AWS user
		operating on a tight budget, you can take advantage of the Free Tier by selecting <span class="rV">t2.micro</span>.
		You get 750 free hours of running time per month, but performance will be slower, and you'll lose the ability to run applications with multiple cores.<br /><br />
		Select <span class="rAB">Next: Configure Instance Details</span> after you have made your selection.</li>
	<li>On <span class="rPN">Step 3: Configure Instance Details</span>, set <span class="rK">IAM role</span> to the IAM Role
		you created earlier. Toggle the <span class="rK">Enable termination protection</span> checkbox to ensure that you
		don't accidentally delete the instance. You can leave all of the other details with their default values.
		Select <span class="rAB">Next: Add Storage</span>.</li>
	<li>On <span class="rPN">Step 4: Add Storage</span>, keep all of the default values. Elastic Block Store (EBS) is
		Amazon's network-attached storage solution, and the Amazon Linux AMI requires at least 8 GB of storage. This is
		enough for our initial tests, and we can attach more Volumes later on as needed. Be aware that EBS Volumes incur charges
		based on their allocated size ($0.10 per GB per month, as of February 2016), regardless of whether they are actually attached
		to a running EC2 instance. Select <span class="rAB">Next: Tag Instance</span>.</li>	
	<li>On <span class="rPN">Step 5: Tag Instance</span>, set <span class="rK">Name</span> to a value like <span class="rV">sparkour-app</span>.
		You can assign other arbitrary tags as needed, and it's considered a best practice to establish consistent and granular
		tagging conventions once you move beyond having a single instance.
		Select <span class="rAB">Next: Configure Security Group</span>.</li>
	<li>On <span class="rPN">Step 6: Configure Security Group</span>, choose <span class="rV">Select an existing security group</span>
		and pick the Security Group you created earlier. Finally, select <span class="rAB">Review and Launch</span>. 
	<li>On <span class="rPN">Step 7: Review Instance Launch</span>, select <span class="rAB">Launch</span>. The instance is
		created and starts up (this may take a few minutes). You can monitor the status of the instance from the EC2 dashboard.
		<br /><br /><b>Important</b>: You are now incurring continuous charges for the EBS Volume as well as charges whenever the EC2 instance
		is running. Make sure you understand how AWS billing works.</li>
</ol>

<a name="managing-ec2"></a>
<h3>Managing the EC2 Instance</h3>

<p>To help avoid unexpected charges, you should stop your EC2 instance when you won't be using it for an extended period. EC2 charges
are incurred whenever an instance is running, and costs round up to the nearest hour. EBS charges are incurred as long as
the EBS Volume exists, and only stop when the Volume is terminated. You don't need to perform these actions now, but make
sure you locate the necessary commands in the EC2 dashboard so you can manage your instance later:</p>

<ul>
	<li>To start or stop an EC2 instance from the EC2 dashboard, select it in the table of instances and select
		<span class="rAB">Actions</span>. In the dropdown menu that appears, select <span class="rMI">Instance State</span>
		and either <span class="rMI">Start</span> or <span class="rMI">Stop</span>. No EC2 charges are incurred while the instance is stopped,
		and all of your data will still be there when you start back up.</li>
	<li>To permanently terminate an EC2 instance, select it in the table of instances and select
		<span class="rAB">Actions</span>. In the dropdown menu that appears, select <span class="rMI">Instance Settings</span>
		and <span class="rMI">Change Termination Protection</span>. Once protection is disabled, you can select 
		<span class="rMI">Instance State > Terminate</span> from the <span class="rAB">Actions</span> dropdown menu. Terminating
		an EC2 instance also permanently deletes the attached EBS Volume (this is a configurable setting in the EC2 Launch wizard).</li>
</ul>		

<h3>Connecting to the EC2 Instance</h3>

<ol>
	<li>While the EC2 instance is starting up, select it in the dashboard. Details about the instance appear in the lower pane, as
		seen in the image below.</li>
		
	<img src="${localImagesUrlBase}/instance-details.png" width="750" height="324" title="Creating a Security Group" class="diagram border" />

	<li>Record the <span class="rK">Public IP</span> address of the instance. You use this to SSH into the instance, or access it
		via a web browser. The Public IP is not static, and changes every time you stop and restart the instance. Advanced users
		can attach an <a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html">Elastic IP</a> 
		address to work around this minor annoyance.</li>
		
	<li>Once the dashboard shows your instance running, use your favorite SSH client to connect to the Public IP as the
		<span class="rV">ec2-user</span> user. EC2 instances do not employ password authentication, 
		so your SSH client needs have your
		<a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html">EC2 Key Pair</a> to login.</li>

	<li>On your first login, you may see a welcome message notifying you of new security updates. You can apply these updates with the
		<span class="rCW">yum</span> utility. </li>

	<bu:rCode lang="bash">
		# Get latest updates
		sudo yum update
		# (Review the list of updates and type 'y' to proceed)
	</bu:rCode>

</ol>

<bu:rSection anchor="03" title="Installing Apache Spark" />

<h3>Downloading Spark</h3>

<p>There are several options available for installing Spark. We could build it from the original source code, or 
download a distribution configured for different versions of Apache Hadoop. 
For now, we use a pre-built distribution which already contains a common set of Hadoop dependencies. 
(You do not need any previous experience with Hadoop to work with Spark).</p>
 
<ol>
	<li>In a web browser from your local development environment, visit the 
		<a href="http://spark.apache.org/downloads.html">Apache Spark Download</a> page. We need to generate a download
		link which we can access from our EC2 instance. 
		Make selections for the first three bullets on the page as follows:<br /><br />
		<span class="rK">Spark release</span>: <span class="rV">2.0.0 (Jul 26 2016)</span><br />
		<span class="rK">Package type</span>: <span class="rV">Pre-built for Hadoop 2.7 and later</span><br />
		<span class="rK">Download type</span>: <span class="rV">Direct Download</span></li>
	<li>The download link in the 4th bullet dynamically updates based on your choices, as seen in the image below.</li>
	
	<img src="${localImagesUrlBase}/spark-download.png" width="715" height="291" title="Getting a download link for Apache Spark" class="diagram border" />
	
	<li>Right-click on the download link and Copy it into your clipboard so it can be pasted onto your EC2 instance. It may not be the same
		as the link in the example script below. From your EC2 instance, type these commands:</li>
		
	<bu:rCode lang="bash">
		# Download Spark to the ec2-user's home directory
		cd ~
		wget http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.7.tgz
		
		# Unpack Spark in the /opt directory
		sudo tar zxvf spark-2.0.0-bin-hadoop2.7.tgz -C /opt
		
		# Create a symbolic link to make it easier to access
		sudo ln -fs spark-2.0.0-bin-hadoop2.7 /opt/spark
	</bu:rCode>

	<li>To complete your installation, set the <span class="rCW">SPARK_HOME</span>
		environment variable so it takes effect when you login to the EC2 instance.</li>
		
	<bu:rCode lang="bash">
		# Insert these lines into your ~/.bash_profile:
		export SPARK_HOME=/opt/spark
		PATH=$PATH:$SPARK_HOME/bin
		export PATH
		# Then exit the text editor and return to the command line.
	</bu:rCode>
		
	<li>You need to reload the environment variables (or logout and login again) so
	they take effect.</li>
		
	<bu:rCode lang="bash">
		# Reload environment variables
		source ~/.bash_profile
		
		# Confirm that spark-submit is now in the PATH.
		spark-submit --version
		# (Should display a version number)
	</bu:rCode>
		
	<li>Spark is not shy about presenting reams of informational output to the console as it runs. To make the output of your applications easier to spot, you can
		optionally set up a Log4J configuration file and suppress some of the Spark logging output. You should maintain logging at the INFO level during the
		Sparkour tutorials, as we'll review some information such as Master URLs in the log files.</li>
		
	<bu:rCode lang="bash">
		# Create a Log4J configuration file from the provided template.
		cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties
		vi $SPARK_HOME/conf/log4j.properties
		# (on line 19 of the file, change the log level from INFO to ERROR)
		# (Note that this will suppress some of the output needed in the tutorials)
		
		# log4j.rootCategory=ERROR, console
		
		# Save the file and exit the text editor.
	</bu:rCode>		
</ol>

<h3>Testing with the Interactive Shells</h3>

<p>Spark comes with interactive shell programs which allow you to enter arbitrary commands 
and have them evaluated as you wait. These shells offer a simple way to get started with Spark 
through "quick and dirty" jobs. An interactive shell does not yet exist for Java.</p>

<p>Let's use the shells to try a simple example from the Spark website. 
This example counts the number of lines in the <span class="rCW">README.md</span> file bundled with Spark.</p>

<ol>
	<li>First, count the number of lines using a Linux utility to verify the answers you'll get from the shells.</li>
	
	<bu:rCode lang="bash">
		# See how many lines are in the README.md file via Linux, to verify shell answers.
		wc -l $SPARK_HOME/README.md
	</bu:rCode>

	<li>Start the interactive shell in the language of your choice.</li>

	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /></p>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Start the Python shell
				cd $SPARK_HOME
				$SPARK_HOME/bin/pyspark
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Start the R shell
				$SPARK_HOME/bin/sparkR
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Start the Scala shell
				cd $SPARK_HOME
				$SPARK_HOME/bin/spark-shell
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>

	<li>While in a shell, your command prompt changes, and you have access to environment settings in a
	<span class="rCW">SparkSession</span> object defined in an <span class="rCW">spark</span> variable. (In Spark 1.x, the environment
	object is a <span class="rCW">SparkContext</span>, stored in the <span class="rCW">sc</span> variable).
	When you see the shell prompt, you can enter arbitrary code in the appropriate language. (You don't 
	have to type the explanatory comments). The shell responses to each of these commands is omitted for clarity.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /> Here is how you would accomplish this example inside a Java application.</p>
			<bu:rCode lang="java">
				// Initialize the session and context
				SparkSession spark = SparkSession.builder().appName("JWordCount").getOrCreate();
 				JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());
			
				// Load the README.md file for processing
				JavaRDD<String> textFile = sc.textFile("README.md");
				
				// Output the line count (it should match the wc output from the command line)
				System.out.println(textFile.count());
			</bu:rCode>			
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="python">
				>>> # Load the README.md file for processing
				>>> textFile = spark.sparkContext.textFile("README.md")
				>>> # Output the line count (it should match the wc output from the command line)
				>>> textFile.count()
				>>> # Quit the shell
				>>> quit()
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="plain">
				> # The low-level Spark Core API containing "textFile()"
				> # is not available in R, so we just print hello and quit.
				> print("Hello")
				> quit()
				> # (Hit 'n' to quit without saving the workspace).				
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="scala">
				scala> // Load the README.md file for processing
				scala> val textFile = spark.sparkContext.textFile("README.md")
				scala> // Output the line count (it should match the wc output from the command line)
				scala> textFile.count()
				scala> // Quit the shell
				scala> sys.exit
			</bu:rCode>	
			<p>When using a version of Spark built with Scala 2.10, the command to quit is simply "<span class="rCW">exit</span>".
		</bu:rTab>
	</bu:rTabs>
	
	<li>For now, we just want to make sure that the shell executes the commands properly and return the correct value.
		We will explore what's going on under the hood in the last tutorial.</li>
</ol>

<bu:rSection anchor="03" title="Conclusion" />

<p>You now have a working Spark environment that you can use to explore other Sparkour recipes.
In the next tutorial, <bu:rLink id="managing-clusters" />, we focus on the different ways you can set up a live Spark cluster. 
If you are done playing with Spark for now, make sure that you
<a href="#managing-ec2">stop your EC2 instance</a> so you don't incur unexpected charges.</p>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/">Running the Spark Interactive Shells</a> in the Spark Programming Guide</li>
		<li><a href="https://media.amazonwebservices.com/AWS_Pricing_Overview.pdf">How AWS Pricing Works</a></li>
		<li><a href="http://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html">Amazon IAM User Guide</a></li>
		<li><a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide">Amazon EC2 User Guide</a></li>
		<li><a href="https://aws.amazon.com/ec2/instance-types">Amazon EC2 Instance Types</a></li>
	</bu:rLinks>
	<bu:rChangeLog>
		<li>This tutorial hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />
<%@ include file="../shared/footer.jspf" %>