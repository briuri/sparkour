<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<c:set var="noJavaMessage" value="There is no interactive shell available for Java. You should use one of the other languages to smoke test your Spark cluster." />

<bu:rOverview publishDate="2016-03-04">
	<h3>Synopsis</h3>
	<p>This recipe describes how to automatically launch, start, stop, or destroy a Spark cluster running in Amazon Elastic Cloud Compute (EC2)
	using the <span class="rCW">spark-ec2</span> script. It steps through the pre-launch configuration, explains the script's
	most common parameters, and points out where specific parameter values can be found in the Amazon Web Services (AWS) Management Console.</p>
				
	<h3>Prerequisites</h3>
	<ol>
		<li>You need an
			<a href="https://www.amazon.com/ap/signin?openid.assoc_handle=aws&openid.return_to=https%3A%2F%2Fsignin.aws.amazon.com%2Foauth%3Fresponse_type%3Dcode%26client_id%3Darn%253Aaws%253Aiam%253A%253A015428540659%253Auser%252Fhomepage%26redirect_uri%3Dhttps%253A%252F%252Fconsole.aws.amazon.com%252Fconsole%252Fhome%253Fstate%253DhashArgs%252523%2526isauthcode%253Dtrue%26noAuthCookie%3Dtrue&openid.mode=checkid_setup&openid.ns=http://specs.openid.net/auth/2.0&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select&openid.pape.preferred_auth_policies=MultifactorPhysical&openid.pape.max_auth_age=43200&openid.ns.pape=http://specs.openid.net/extensions/pape/1.0&server=/ap/signin&forceMobileApp=&forceMobileLayout=&pageId=aws.ssop&ie=UTF8">AWS account</a>
			and a general understanding of how <a href="https://media.amazonwebservices.com/AWS_Pricing_Overview.pdf">AWS billing works</a>.
			You also need to <a href="http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html">generate access keys</a>
			(to run the <span class="rCW">spark-ec2</span> script) and  		
			<a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair">create an EC2 Key Pair</a>
			(to SSH into the launched cluster).</li>
		<li>You need a launch environment with Apache Spark and Python installed, from which you run the <span class="rCW">spark-ec2</span> script.</li>
	</ol>
	
	<h3>Target Versions</h3>
	<ol>
		<li>With the <span class="rCW">spark-ec2</span> script from a specific version of Apache Spark, you can launch a cluster running
			the same, or any earlier, version of Spark. For consistency between your launch environment (which is probably also your development
			environment) and the cluster, you should use the same version of Spark everywhere.</li>
		<li>The script included in Spark 1.6.2 omits "1.6.2" as a valid version number, so it can only be used to create clusters up to versions 1.6.1.
			You can track the progress of this bug in the <a href="https://issues.apache.org/jira/browse/SPARK-16257">SPARK-16257</a> ticket. Advanced
			users can hand-edit their <span class="rCW">spark_ec2.py</span> file and manually insert 1.6.2 into the following variables:
			<span class="rCW">SPARK_EC2_VERSION</span>, <span class="rCW">VALID_SPARK_VERSIONS</span>, <span class="rCW">SPARK_TACHYON_MAP</span>,
			<span class="rCW">DEFAULT_SPARK_EC2_BRANCH</span>.</li> 
		<li>The <span class="rCW">spark-ec2</span> script only supports three versions of Hadoop right now: Hadoop 1.0.4, Hadoop 2.4.0, or
			the Cloudera Distribution with Hadoop (CDH) 4.2.0. If you have application dependencies that require another version of Hadoop,
			you will need to manually set up the cluster without the script. These tutorials may be useful in
			that case:<ul>
				<li><bu:rLink id="installing-ec2" /></li>
				<li><bu:rLink id="managing-clusters" /></li>
			</ul></li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Pre-Launch Configuration</a></li>
		<li><a href="#02">Script Parameters</a></li>
		<li><a href="#03">Managing the Cluster</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Pre-Launch Configuration" />

<p>Before running the <span class="rCW">spark-ec2</span> script, you must:</p>

<ol>
	<li>Add the appropriate permissions to your AWS Identity and Access Management (IAM) user account that will allow you to run the script.</li>
	<li>Create an IAM Role for the instances in the generated Spark cluster that will allow them to access other AWS services.</li>
	<li>Make configuration decisions about how your Spark cluster should be deployed, and look up important IDs and values in the AWS Management Console.</li>
</ol>

<h3>Adding Launch Permissions</h3>

<p>The <span class="rCW">spark-ec2</span> script requires permission to execute multiple AWS Actions, such as creating new EC2 
instances and configuring security groups. These permissions are checked against the AWS user account used to run the script, and
can be attached to a user account through the IAM service. As a best practice, you should not be using your
<a href="http://docs.aws.amazon.com/general/latest/gr/root-vs-iam.html">root user credentials</a> to run the script.</p>

<ol>
	<li>Login to your <a href="https://console.aws.amazon.com/">AWS Management Console</a> and select the 
		<span class="rPN">Identity &amp; Access	Management</span> service.</li>
	<li>Navigate to <span class="rMI">Groups</span> in the left side menu, and then select
		<span class="rAB">Create New Group</span> at the top of the page. 
		This starts a wizard workflow to create a new Group.</li>	
	<li>On <span class="rPN">Step 1. Group Name</span>, set the <span class="rK">Group Name</span> to a value
		like <span class="rV">spark-launch</span> and go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 2. Attach Policy</span>, select <span class="rV">AdministratorAccess</span> to grant
		a pre-defined set of administrative permissions to this Group. Go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 3. Review</span>, select <span class="rAB">Create Group</span>. You return
		to the Groups dashboard, and should see your new Group listed on the dashboard.</li>
	<li>Next, click on the name of your group to show summary details. Go to the <span class="rPN">Users</span> tab
		and select <span class="rAB">Add Users to Group</span>.</li>
	<li>On the <span class="rPN">Add Users to Group</span> page, select your IAM user account and then <span class="rAB">Add Users</span>.
		You return to the Groups summary detail page, and should see your user account listed in the Group. Your account can now be
		used to run the <span class="rCW">spark-ec2</span> script.</li>		
</ol>

<p>These instructions provide all of the permissions needed to run the script, but advanced users may prefer to enforce a "least privilege" security posture
with a more restrictive, custom policy. An example of such a policy is shown below, but the specific list of Actions may vary depending
on the parameters you pass into the script to set up your Spark cluster.</p>

<bu:rCode lang="plain">
	{
		"Version": "2012-10-17",
		"Statement": [
			{
				"Effect": "Allow",
				"Action": [
					"ec2:DescribeAvailabilityZones", "ec2:DescribeRegions",
					"ec2:DescribeSecurityGroups", "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
					"ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupEgress",
					"ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress",
					
					"ec2:DescribeImages", "ec2:DescribeInstances", "ec2:DescribeInstanceStatus",
					"ec2:RunInstances", "ec2:StartInstances", "ec2:StopInstances", "ec2:TerminateInstances"

					"ec2:DescribeTags", "ec2:CreateTags", "ec2:DeleteTags",
					
					"ec2:DescribeVolumes", "ec2:CreateVolume", "ec2:DeleteVolume",
					"ec2:AttachVolume", "ec2:DetachVolume", 

					"iam:PassRole"
				],
				"Resource": [ "*" ]
			}
		]
	}
</bu:rCode>

<p>You can create and attach this policy to your Group with the IAM service instead of the <span class="rV">AdministratorAccess</span> policy we used above.
If you encounter authorization errors when running the script with this policy, you may need to add additional AWS Actions to the policy.</p>

<h3>Creating the IAM Role</h3>

<p>By deploying your cluster in Amazon EC2, you gain access to other AWS service offerings such as Amazon S3 for data storage. Your cluster nodes
need permission to access these services (separate from the permissions used to launch the cluster in the first place).
Most Spark tutorials suggest that you pass your secret API keys to the instances as environment variables.
This brittle "shared secret" approach is no longer a best practice in AWS, although it is the only way to use some older AWS integration libraries. (For example,
the Hadoop library implementing the <span class="rCW">s3n</span> protocol for loading Amazon S3 data only accepts secret keys).</p>

<p>A cleaner way to set this up is to use IAM Roles. You can assign a Role to every node in your cluster and then 
attach a policy granting those instances access to other services. No secret keys are involved, and the risk of accidentally disseminating keys or 
committing them in version control is reduced. The only caveat is that the IAM Role must be assigned when an EC2 instance is first launched. 
You cannot assign an IAM Role to an EC2 instance already in its post-launch lifecycle.</p>

<p>For this reason, it's a best practice to always assign an IAM Role to new instances, even if you don't need it right away. It is much easier to 
attach new permission policies to an existing Role than it is to terminate the entire cluster and recreate everything with Roles after the fact.</p>

<ol>
	<li>Go to the <span class="rPN">Identity &amp; Access Management</span> service, if you are not already there.</li>
	<li>Navigate to <span class="rMI">Roles</span> in the left side menu, and then select
		<span class="rAB">Create New Role</span> at the top of the page, as seen in the image below. 
		This starts a wizard workflow to create a new role.</li>
		
	<img src="${localImagesUrlBase}/iam-roles.png" width="500" height="266" title="Creating an IAM Role for the Spark cluster" class="diagram border" />
	
	<li>On <span class="rPN">Step 1. Set Role Name</span>, set the <span class="rK">Role Name</span> to a value
		like <span class="rV">sparkour-cluster</span> and go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 2. Select Role Type</span>, select <span class="rV">Amazon EC2</span> to establish
		that this role will be applied to EC2 instances. Go to the <span class="rAB">Next Step</span>.</li>
	<li>Step 3 is skipped based on your previous selection. On <span class="rPN">Step 4. Attach Policy</span>, 
		do not select any policies. (We will add policies in other recipes when we need our instance to 
		access other services). Go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 5. Review</span>, select <span class="rAB">Create Role</span>. You return
		to the Roles dashboard, and should see your new role listed on the dashboard.</li>
	<li>Exit this dashboard and return to the list of AWS service offerings by selecting the "cube" icon in the upper left corner.</li>
</ol>

<h3>Gathering VPC Details</h3>

<p>Next, you need to gather some information about the Virtual Private Cloud (VPC) where the cluster will be deployed.
Setting up VPCs is outside the scope of this recipe, but Amazon provides many default components so you can get started quickly. 
Below is a checklist of important details you should have on hand before you run the script.</p>

<ul>
	<li><span class="rPN">Which AWS Region will I deploy into?</span> You need the unique <span class="rK">Region</span> key for your 
		<a href="http://docs.aws.amazon.com/general/latest/gr/rande.html#vpc_region">selected region</a>.</li>
	<li><span class="rPN">Which VPC will I deploy into?</span> You need the VPC ID of your VPC (the default is fine if you do not want to
		create a new one). From the <span class="rPN">VPC</span> dashboard in the AWS Management Console,
		you can find this in the <span class="rPN">Your VPCs</span> table.</li>
	<li><span class="rPN">What's the IP address of my launch environment?</span> The default Security Group created by the <span class="rCW">spark-ec2</span>
		script punches a giant hole in your security boundary by opening up many Spark ports to the public Internet. While this is useful for
		getting things done quickly, it's very insecure. As a best practice, you should explicitly specify an IP address or IP range so your cluster
		isn't immediately open to the world's friendliest hackers.</li>
</ul>

<bu:rSection anchor="02" title="Script Parameters" />

<p>The <span class="rCW">spark-ec2</span> script exposes a variety of configuration options. The most commonly used options are described below, and
there are other options available for advanced users. Calling the script with the <span class="rK">--help</span> parameter 
displays the complete list.</p>

<ul>
	<li><span class="rPN">Identity Options</span><ul>
		<li><span class="rK">AWS_SECRET_ACCESS_KEY / AWS_ACCESS_KEY_ID</span>: These credentials are tied to your AWS user account, and allow you to run the script.
			You can <a href="http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html">create new keys</a> if you have lost the old ones,
			by visiting the IAM User dashboard, selecting a user, selecting <span class="rAB">Users Actions</span>, and choosing <span class="rMI">Manage Access Keys</span>.
			We merely set them as environment variables as a best practice, so they are not stored anywhere on the machine containing your script.</li>
		<li><span class="rK">--key-pair / --identity-file</span>: These credentials allow the script to SSH into the cluster instances. You can <a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair">create an EC2 Key Pair</a>
			if you haven't already. The identity file must be installed in the launch environment where the script is run and must have permissions of <span class="rCW">400</span> (readable
			only by you). Use the absolute path in the parameter.</li>
		<li><span class="rK">--copy-aws-credentials</span>: Optionally allow the cluster to use the credentials with which you ran the script when accessing Amazon
			services. This is a brittle security approach, so only use it if you rely on a legacy library that doesn't support IAM Roles.</li>		
	</ul></li>
	<li><span class="rPN">VPC Options</span><ul>
		<li><span class="rK">--region</span>: Optionally set the key of the region where the cluster will live (defaults to US East).</li>
		<li><span class="rK">--vpc-id</span>: The ID of the VPC where the instances will be launched.</li>
		<li><span class="rK">--subnet-id</span>: Optionally set the ID of the Subnet within the VPC where the instances will be launched.</li>
		<li><span class="rK">--zone</span>: Optionally set the ID of an Availability Zone(s) to launch in (defaults to a randomly chosen zone). You
			can also set to <span class="rV">all</span> for higher availability at greater cost.</li>
		<li><span class="rK">--authorized-address</span>: The whitelisted IP range used in the generated Security Group (defaults to the public Internet as <span class="rV">0.0.0.0/0</span>, so you should always specify a value for better security).</li>
		<li><span class="rK">--private-ips</span>: Optionally set to <span class="rV">True</span> for VPCs in which public IP addresses are not automatically assigned to instances.
			The script tries to connect to the cluster to configure it through Public DNS Names by default, and setting this to <span class="rV">True</span> forces the use of 
			Private IPs instead (defaults to <span class="rV">False</span>).</li>
	</ul></li>
	<li><span class="rPN">Cluster Options</span><ul>                   
		<li><span class="rK">--slaves</span>: Optionally set the number of slaves to launch (defaults to <span class="rV">1</span>).</li>
		<li><span class="rK">--instance-type</span>: Optionally set the EC2 instance type from a
			<a href="https://aws.amazon.com/ec2/instance-types/">wide variety of options</a> based on your budget and workload needs (defaults to <span class="rV">m1.large</span>, which is a deprecated legacy type).</li>
		<li><span class="rK">--master-instance-type</span>: Optionally set a different instance type for the master (defaults to the overall instance type for the cluster).</li>	
		<li><span class="rK">--master-opts</span>: Optionally pass additional configuration properties to the master.</li>
		<li><span class="rK">--spark-version</span>: Optionally choose the version of Spark to install. During the launch, the script will download 
			and build the desired version of Spark from a configurable GitHub repository (defaults to the version of Spark the script came from).</li>
		<li><span class="rK">--spark-git-repo / --spark-ec2-git-repo / --spark-ec2-git-branch</span>: Optionally specify an alternate location
			for downloading Spark and Amazon Machine Images (AMIs) for the instances (defaults to the official GitHub repository).</li>
		<li><span class="rK">--hadoop-major-version</span>: Optionally set to <span class="rV">1</span> for Hadoop 1.0.4, <span class="rV">2</span> for CDH 4.0.2,
			or <span class="rV">yarn</span> for Hadoop 2.4.0 (defaults to <span class="rV">1</span>). No other versions are currently supported.</li>
	</ul></li>
	<li><span class="rPN">Instance Options</span><ul>	
		<li><span class="rK">--instance-profile-name</span>: Optionally set to the unique name of an IAM Role to assign to each instance.</li>
		<li><span class="rK">--ami</span>: Optionally specify an AMI ID to install on the instances (defaults to the best-fit AMI from the official
			GitHub repository, based upon your selected instance type).</li>
		<li><span class="rK">--user-data</span>: Optionally specify a startup script (from a location on the machine running the <span class="rCW">spark-ec2</span> script). If specified,
			this script will run on each of the cluster instances as an initialization step.</li>
		<li><span class="rK">--additional-tags</span>: Optionally apply AWS tags to these instances. 
			Tag keys and values are separated by a colon, and you can pass in a comma-separated list of tags: <span class="rV">name:value,name2:value2</span>.</li>
		<li><span class="rK">--instance-initiated-shutdown-behavior</span>: Optionally set to <span class="rV">stop</span> to stop instances when stopping
			the cluster, or <span class="rV">terminate</span> to permanently destroy instances when stopping the cluster (defaults to <span class="rV">stop</span>).</li>
		<li><span class="rK">--ebs-vol-size / --ebs-vol-type / --ebs-vol-num</span>: Optionally configure Elastic Block Store (EBS) Volumes to be created and attached
			to each of the instances.</li>
	</ul></li>
</ul>	

<bu:rSection anchor="03" title="Managing the Cluster" />

<h3>Launching the Cluster</h3>

<p>Below is an example run of the <span class="rCW">spark-ec2</span> script. Refer to the previous section for an explanation of each parameter.</p>

<bu:rCode lang="bash">
	export AWS_SECRET_ACCESS_KEY=AaBbCcDdEeFGgHhIiJjKkLlMmNnOoPpQqRrSsTtU
	export AWS_ACCESS_KEY_ID=ABCDEFG1234567890123
	$SPARK_HOME/ec2/spark-ec2 \
		--key-pair=my_key_pair \
		--identity-file=/opt/keys/my_key_pair.pem \
		--region=us-east-1 \
		--vpc-id=vpc-35481850 \
		--authorized-address=12.34.56.78/32 \
		--slaves=1 \
		--instance-type=m4.large \
		--spark-version=1.6.2 \
		--hadoop-major-version=yarn \
		--instance-profile-name=sparkour-cluster \
		launch sparkour-cluster
</bu:rCode>

<p>It is useful to remember the <a href="/recipes/managing-clusters/#spark-server-roles">4 different roles</a> a Spark server can play. In the following steps,
we are running the script from our <span class="rPN">launch environment</span> (which is probably also our <span class="rPN">development environment</span>).
The result of the script is a <span class="rPN">master</span> and a <span class="rPN">worker</span>, on two new EC2 instances.</p>

<ol>
	<li>Run the script from your launch environment, replacing the example parameters above with your own values. You should see output like the following:</li>
	
	 <bu:rCode lang="plain">
		Setting up security groups...
		Creating security group sparkour-cluster-master
		Creating security group sparkour-cluster-slaves
		Searching for existing cluster sparkour-cluster in region us-east-1...
		Spark AMI: ami-35b1885c
		Launching instances...
		Launched 1 slave in us-east-1d, regid = r-0b0dbfa0
		Launched master in us-east-1d, regid = r-bcfc4117
		Waiting for AWS to propagate instance metadata...
		Waiting for cluster to enter 'ssh-ready' state....
	</bu:rCode>
	
	<li>It may take several minutes to pass this point, during which the script will periodically attempt to SSH into the instances using their Public DNS names.
	These attempts will fail until the cluster has entered the <span class="rCW">'ssh-ready'</span> state. You can monitor progress on the EC2 Dashboard -- 
	when the Status Checks succeed, the script should be able to SSH successfully.</li>
	
	<img src="${localImagesUrlBase}/status-checks.png" width="750" height="158" title="The cluster may take several minutes to launch." class="diagram border" />

	<bu:rCode lang="plain">
		Cluster is now in 'ssh-ready' state. Waited 500 seconds.
	</bu:rCode>
	
	<li>After this point, the script uses SSH to login to each of the cluster nodes, configure directories, and install Spark, Hadoop, Scala, RStudio
		and other dependencies. There will be several pages of log output, culminating in these lines:</li>
	
	<bu:rCode lang="plain">
		Spark standalone cluster started at http://ec2-12-34-56-78.compute-1.amazonaws.com:8080
		Ganglia started at http://ec2-12-34-56-78.compute-1.amazonaws.com:5080/ganglia
		Done!
	</bu:rCode>
</ol>

<p>If your script is unable to use SSH even after the EC2 instances have succeeded their Status Checks, you should troubleshoot the connection using the 
<span class="rCW">ssh</span> command in your launch environment, replacing <span class="rCW">&lt;sparkNodeAddress&gt;</span> with the hostname or IP address
of one of the Spark nodes.</p>

<bu:rCode lang="bash">
	ssh -i /opt/keys/my_key_pair.pem ec2-user@&lt;sparkNodeAddress&gt;
</bu:rCode>

<p>Here are some troubleshooting paths to consider:</p>
 
<ol>
	<li>If you are running the <span class="rCW">spark-ec2</span> script from an EC2 instance, does its Security Group allow outbound traffic to the Spark cluster?</li>
	<li>Does the Spark cluster's generated Security Group allow inbound SSH traffic (port 22) from your launch environment?</li>
	<li>Can you manually SSH into a Spark cluster node from your launch environment over an IP address?</li>  
	<li>Can you manually SSH into a Spark cluster node from your launch environment over a Public DNS Name? A failure here may suggest that your Spark cluster
		does not automatically get public addresses assigned (in which case you can use the 
		<span class="rK">--private-ips</span> parameter), or your launch environment cannot locate the cluster over its DNS service.</li>
</ol>

<h3>Validating the Cluster</h3>

<ol>					
	<li>From a web browser, open the Master UI URL for the Spark cluster (shown above on port 8080). It should show a single worker in the <span class="rCW">ALIVE</span>
		state. If you are having trouble hitting the URL, examine the master's Security Group in the EC2 dashboard and make sure that an inbound rule
		allows access from the web browser's location to port 8080.</li>
		
	<li>From the EC2 dashboard, select each instance in the cluster. In the details pane, confirm that the IAM Role was successfully assigned.</li>
	
	<li>Next, try to SSH into the master instance. You can do this from the launch environment where you ran the <span class="rCW">spark-ec2</span> script, or use a client
		like PuTTY that has been configured with the EC2 Key Pair. When logged into the master, you will find the Spark libraries
		installed under <span class="rCW">/root/</span>.</li>
		
	<li>Finally, try running the Spark interactive shell on the master instance, connecting to the cluster.
		You can copy the Master URL from the Master UI and then start a shell with that value.</li>
	
	<bu:rTabs>
		<bu:rTab index="1">
			<p><c:out value="${noJavaMessage}" escapeXml="false" /></p>
		</bu:rTab><bu:rTab index="2">
			<bu:rCode lang="bash">
				# Start the shell with your running cluster	
				$SPARK_HOME/bin/pyspark --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="3">
			<bu:rCode lang="bash">
				# Start the shell with your running cluster	
				$SPARK_HOME/bin/sparkR --master spark://ip-172-31-24-101:7077
			</bu:rCode>
		</bu:rTab><bu:rTab index="4">
			<bu:rCode lang="bash">
				# Start the shell with your running cluster	
				$SPARK_HOME/bin/spark-shell --master spark://ip-172-31-24-101:7077
			</bu:rCode>	
		</bu:rTab>
	</bu:rTabs>
	
	<li>When you refresh the Master UI, the interactive shell should appear as a running application. Your cluster is alive! You can quit or exit
		your interactive shell now.</li>
</ol>

<h3>Controlling the Cluster</h3>

<ul>
	<li>To start or stop the cluster, run these commands (from your launch environment, not the master):</li>

	<bu:rCode lang="bash">
		$SPARK_HOME/ec2/spark-ec2 start sparkour-cluster
		
		$SPARK_HOME/ec2/spark-ec2 stop sparkour-cluster
		# (Hit 'y' to confirm)
	</bu:rCode>

	<li>To permanently destroy your cluster, run this command (from your launch environment, not the master):</li>	

	<bu:rCode lang="bash">
		$SPARK_HOME/ec2/spark-ec2 destroy sparkour-cluster
		# (Hit 'y' to confirm)
	</bu:rCode>
	
	<li>Destroying a cluster does not delete the generated Security Groups by default. If you try to manually delete them, you will run into
		trouble because they reference each other. Remove all of the inbound rules from each Security Group and you can delete
		them successfully.</li>
</ul>

<p>Remember that while you only incur costs for running EC2 instances, you are billed for all provisioned EBS Volumes.
	Charges stop when the Volumes are terminated, and this occurs by default when you terminate the EC2 instances for which they were created.</p>
	
<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://spark.apache.org/docs/latest/ec2-scripts.html">Running Spark on EC2</a> in the Spark Programming Guide</li>
		<li><a href="http://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html">Amazon IAM User Guide</a></li>
		<li><a href="http://docs.aws.amazon.com/AWSEC2/latest/UserGuide">Amazon EC2 User Guide</a></li>
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>Updated with additional detail on required permissions and SSH troubleshooting
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-7">SPARKOUR-7</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>