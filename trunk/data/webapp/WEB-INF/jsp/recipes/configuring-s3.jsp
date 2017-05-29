<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-03-05">
	<h3>Synopsis</h3>
	<p>This recipe provides the steps needed to securely expose data in Amazon Simple Storage Service (S3) for consumption by a Spark application.
	The resultant configuration works with both supported S3 protocols in Spark: the classic <span class="rCW">s3n</span> protocol 
	and the newer, but still maturing, <span class="rCW">s3a</span> protocol.</p>
	
	<h3>Prerequisites</h3>
	<ol>
		<li>You need an
			<a href="https://www.amazon.com/ap/signin?openid.assoc_handle=aws&openid.return_to=https%3A%2F%2Fsignin.aws.amazon.com%2Foauth%3Fresponse_type%3Dcode%26client_id%3Darn%253Aaws%253Aiam%253A%253A015428540659%253Auser%252Fhomepage%26redirect_uri%3Dhttps%253A%252F%252Fconsole.aws.amazon.com%252Fconsole%252Fhome%253Fstate%253DhashArgs%252523%2526isauthcode%253Dtrue%26noAuthCookie%3Dtrue&openid.mode=checkid_setup&openid.ns=http://specs.openid.net/auth/2.0&openid.identity=http://specs.openid.net/auth/2.0/identifier_select&openid.claimed_id=http://specs.openid.net/auth/2.0/identifier_select&openid.pape.preferred_auth_policies=MultifactorPhysical&openid.pape.max_auth_age=43200&openid.ns.pape=http://specs.openid.net/extensions/pape/1.0&server=/ap/signin&forceMobileApp=&forceMobileLayout=&pageId=aws.ssop&ie=UTF8">AWS account</a>
			and a general understanding of how <a href="https://media.amazonwebservices.com/AWS_Pricing_Overview.pdf">AWS billing works</a>.</li>
		<li>You need an EC2 instance with the AWS command line tools installed, so you can test the connection. The instance created in either <bu:rLink id="installing-ec2" /> or 
			<bu:rLink id="spark-ec2" /> is sufficient.</li>
	</ol>
	
	<h3>Target Versions</h3>
	<ol>
		<li>This recipe is independent of any specific version of Spark or Hadoop. All work is done through Amazon Web Services (AWS).</li>
	</ol>
		
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Introducing Amazon S3</a></li>
		<li><a href="#02">Configuring Access Control</a></li>
		<li><a href="#03">Next Steps</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Introducing Amazon S3" />

<p>Amazon S3 is a key-value object store that can be used as a data source to your Spark cluster. You can store unlimited data in S3
although there is a 5 TB maximum on individual files. Data is organized into S3 <span class="rPN">buckets</span> with various options for access control and versioning.
The monthly cost is based upon the number of API calls your application makes and the amount of space 
your data takes up ($0.03 per GB per month, as of May 2017). Transfer of data between S3 and an EC2 instance is free.</p>

<p>There are no S3 libraries in the core Apache Spark project. Spark uses libraries from Hadoop to connect to S3, and the integration between Spark, Hadoop, and the AWS services
is very much a work in progress. Your success in getting things working is very dependent on specific versions of the various libraries, the protocol you use, and possibly even the weather forecast.
Because of this, the Spark side is covered in a separate recipe (<bu:rLink id="using-s3" />) and this recipe focuses solely on the S3 side.</p>

<h3>Important Limitations</h3>
<ul>
	<li>By using S3 as a data source, you lose the ability to position your data as closely as possible to your cluster (<span class="rPN">data locality</span>). A common pattern
		to work around this is to load data from S3 into a local HDFS store in the cluster, and then operate upon it from there.</li>
	<li>You can mimic the behavior of subdirectories on a filesystem by using object keys resembling file paths, such as <span class="rCW">s3n://myBucket/2016/03/03/output.log</span>,
		but S3 is not a true hierarchical filesystem. You cannot assume that a wildcard in a key will be processed as it would on a real filesystem. In particular, if you use
		Spark Streaming with S3, nested directories are not supported. If you want to grab all files in all subdirectories, you'll need to do some extra coding on your side to resolve
		the subdirectories first so you can send explicit path requests to S3.</li>
	<li>S3 provides Read-After-Write consistency for new objects and Eventual consistency for object updates and deletions. If your data changes, you cannot guarantee that every worker
		node requesting the data will see the authoritative newest version right away -- all requesters will <i>eventually</i> see the changes.</li>
</ul>	

<h3>Creating a Bucket</h3>

<p>If you don't already have an S3 bucket created, you can create one for the purposes of this recipe.</p>

<ol>
	<li>Login to your <a href="https://console.aws.amazon.com/">AWS Management Console</a> and select the 
		<span class="rPN">S3</span> service. The S3 dashboard provides a filesystem-like view of the object 
		store (with forward slashes treated like directory separators) for ease of understanding and browsing.</li>
	<li>Select <span class="rAB">Create Bucket</span>. Set the <span class="rK">Bucket Name</span> to a unique value
		like <span class="rV">sparkour-data</span>. Bucket names must be unique across all of S3, so it's a good idea to assign a unique hyphenated
		prefix to your bucket names.</li>  
	<li>Set the <span class="rK">Region</span> to <span class="rV">US Standard</span>. This
		is a bicoastal US service. If your cluster is in a different AWS Region, you want the S3 bucket to exist in the same Region.
		Finally, select <span class="rAB">Create</span>. You should see the new bucket in the list.</li>
	<li>Select the bucket name in the list to browse inside of it. Select <span class="rAB">Upload</span>, then <span class="rAB">Add Files</span>
		to upload a simple text file. Once you have picked a file from your local machine, select <span class="rAB">Start Upload</span>. We try to
		download this file later on to test our connection.
	<li>Exit this dashboard and return to the list of AWS service offerings by selecting the "cube" icon in the upper left corner.</li>
</ol>

<bu:rSection anchor="02" title="Configuring Access Control" />

<p>Access control can be handled as a policy attached to the bucket itself, a policy attached to the entity interacting with the bucket, or some combination of both (with the final
decision based on the principle of least-privilege). The way you secure your bucket depends on the communication protocol you intend to use in your Spark application.</p>

<ol>
	<li>The <span class="rCW">s3</span> protocol is supported in Hadoop, but does not work with Apache Spark unless you are using the AWS version of Spark in Elastic MapReduce (EMR).
		We can safely ignore this protocol for now.</li>
	<li>The <span class="rCW">s3n</span> protocol is Hadoop's older protocol for connecting to S3. Implemented with a third-party library (JetS3t), it provides rudimentary support
	for files up to 5 GB in size and uses AWS secret API keys to run. This "shared secret" approach is brittle, and no longer the preferred best practice within AWS. It also conflates
	the concepts of users and roles, as the worker node communicating with S3 presents itself as the person tied to the access keys.</li>

	<li>The <span class="rCW">s3a</span> protocol is successor to <span class="rCW">s3n</span> but is not mature yet. Implemented directly on top of AWS APIs, it is faster, handles files up to
	5 TB in size, and supports authentication with Identity and Access Management (IAM) Roles. With IAM Roles, you assign an IAM Role to your worker nodes and then attach policies
	granting access to your S3 bucket. No secret keys are involved, and the risk of accidentally disseminating keys or committing them in version control is reduced.
	<span class="rCW">s3a</span> support was introduced in <a href="https://issues.apache.org/jira/browse/HADOOP-10400">Hadoop 2.6.0</a>, but several important issues
	were corrected in version <a href="https://issues.apache.org/jira/browse/HADOOP-11571">2.7.0</a> and <a href="https://issues.apache.org/jira/browse/HADOOP-11694">2.8.0</a>.
	You should consider 2.8.0 to be the minimum required version of Hadoop to use this protocol.</li>
</ol>

<p>As you can see, the protocol you select is a trade-off between maturity, security, and performance. This decision drives your approach for bucket access control.</p>

<h3>Configuring Your Bucket for s3n</h3>

<p>To support the "shared secret" style of authentication, we add permissions directly to the bucket for the owner of the access keys used in the application.</p>

<ol>
 	<li>From the <a href="https://console.aws.amazon.com/">AWS Management Console</a> and select the 
		<span class="rPN">S3</span> service.</li>
	<li>Select the "magnifying glass" icon next to your bucket name in the list to bring up the <span class="rPN">Properties</span> tab. Expand
		the <span class="rMI">Permissions</span> divider, which is collapsed by default.</li>
		
	<img src="${localImagesUrlBase}/bucket-permissions.png" width="671" height="389" title="Setting bucket permissions" class="diagram border" />
	
	<li>As the owner of the bucket, you should see your own permissions. Select <span class="rAB">Add bucket policy</span> and a policy
		editing window appears. Paste in the policy shown below, which grants a specific user read/write access to anything in the bucket.
		You need to modify the <span class="rCW">aws-account-id</span>, <span class="rCW">username</span>, and <span class="rCW">bucket-name</span>
		to match your environment. If you don't know the user's Principal string, you can look up the details in the <span class="rPN">Identity & Access Management</span>
		dashboard (select the user and it appears on their <span class="rPN">Summary</span> page).</li> 

	<bu:rCode lang="plain">
		{
			"Version": "2012-10-17",
			"Statement": [
				{
					"Principal": {
						"AWS": ["arn:aws:iam::aws-account-id:user/username"]
					},
					"Effect": "Allow",
					"Action": [
						"s3:Delete*", "s3:Get*", "s3:List*", "s3:PutObject"
					],
					"Resource": "arn:aws:s3:::bucket-name/*"
				}
			]
		}
	</bu:rCode>
	
	<li>Here is an example of the populated policy template.</li>
	
	<bu:rCode lang="plain">
		{
			"Version": "2012-10-17",
			"Statement": [
				{
					"Principal": {
						"AWS": ["arn:aws:iam::123456789012:user/brian"]
					},
					"Effect": "Allow",
					"Action": [
						"s3:Delete*", "s3:Get*", "s3:List*", "s3:PutObject"
					],
					"Resource": "arn:aws:s3:::sparkour-data/*"
				}
			]
		}
	</bu:rCode>	
	
	<li>Select <span class="rAB">Save</span>. If there are no syntax errors, the policy is attached to the bucket.</li>
	<li>To test the result of this policy, SSH into an EC2 instance and try to download the file you placed in your bucket earlier.</li>
	
	<bu:rCode lang="bash">
		# Put the secret keys into the environment
		export AWS_SECRET_ACCESS_KEY=AaBbCcDdEeFGgHhIiJjKkLlMmNnOoPpQqRrSsTtU
		export AWS_ACCESS_KEY_ID=ABCDEFG1234567890123
		
		# Copy the file from S3 to the local directory
		aws s3 cp s3://sparkour-data/myfile.txt .
		
		# Copy the file back to S3
		aws s3 cp ./myfile.txt s3://sparkour-data/myfile.copy.txt
	</bu:rCode>
	
	<li>If this copy worked correctly, the permissions are set up properly, and you are now ready to configure Spark to work with <span class="rCW">s3n</span>.</li>
</ol>

<a name="s3a-config"></a><h3>Configuring Your Bucket for s3a</h3>

<p>To support the role-based style of authentication, we create a policy that can be attached to an IAM Role on your worker nodes.</p>

<ol>
	<li>From the <a href="https://console.aws.amazon.com/">AWS Management Console</a> and select the 
		<span class="rPN">Identity &amp; Access	Management</span> service.</li>
	<li>Navigate to <span class="rMI">Policies</span> in the left side menu, and then select
		<span class="rAB">Create Policy</span> at the top of the page. 
		This starts a wizard workflow to create a new policy.</li>
	<li>On <span class="rPN">Step 1. Create Policy</span>, select <span class="rV">Create Your Own Policy</span>. (You can use one of the other wizard options
		if the sample policy below is insufficient for your needs).</li> 
	<li>Step 2 is skipped based on your previous selection. On <span class="rPN">Step 3. Review Policy</span>,
		set the <span class="rK">Policy Name</span> to a memorable value. The example policy grants read/write permissions to the bucket, so we call it
		<span class="rV">sparkour-data-S3-RW</span>. Set the <span class="rK">Description</span> to <span class="rV">Grant read/write access to the sparkour-data bucket</span>.</li> 
	<li>In the <span class="rK">Policy Document</span> editing area, paste in the following policy, altering the <span class="rCW">sparkour-data</span> to match your bucket name.</li>
	
	<bu:rCode lang="plain">
		{
			"Version": "2012-10-17",
			"Statement": [
				{
					"Effect": "Allow",
					"Action": [
						"s3:Delete*", "s3:Get*", "s3:List*", "s3:PutObject"
					],
					"Resource": "arn:aws:s3:::sparkour-data/*"
				}
			]
		}
	</bu:rCode>
	
	<li>Select <span class="rAB">Validate Policy</span> to check for syntax errors, and then select <span class="rAB">Create Policy</span>. You return to the Policies
		dashboard and should be able to find your policy in the list (You may need to filter out the Amazon-managed policies).</li>
		
	<li>Now, let's attach the policy to an IAM Role. If you have created an EC2 instance using one of the recipes listed in the Prerequisites of this recipe, it should
		have an IAM Role assigned to it that we can use.</li>   
	
	<li>Navigate to <span class="rMI">Roles</span> in the left side menu, and then select
		the name of the Role in the table (selecting the checkbox to the left of the name is insufficient).</li>
	<li>On the <span class="rPN">Summary</span> page that appears, select <span class="rAB">Attach Policy</span> in the <span class="rPN">Permissions</span> tab.
		Select the policy you just created. You may need to filter the table if it's lost among the many Amazon-managed policies.
		Select <span class="rAB">Attach Policy</span>. You return the Summary page and should see the policy attached.</li>
	<li>To test the result of this policy, SSH into an EC2 instance and try to download the file you placed in your bucket earlier.</li>
	
	<bu:rCode lang="bash">
		# Clear any secret keys in the environment so the AWS tools use the IAM Role
		export AWS_SECRET_ACCESS_KEY=""
		export AWS_ACCESS_KEY_ID=""
		
		# Copy the file from S3 to the local directory
		aws s3 cp s3://sparkour-data/myfile.txt .
		
		# Copy the file back to S3
		aws s3 cp ./myfile.txt s3://sparkour-data/myfile.copy.txt
	</bu:rCode>
	
	<li>If this copy worked correctly, the permissions are set up properly, and you are now ready to configure Spark to work with <span class="rCW">s3a</span>.</li>
</ol>

<h3>Configuring Your Bucket for Both Protocols</h3>

<p>It is safe to apply both the bucket access policy and the IAM Role access policy if you plan on using both protocols. The access control decision is based
on the union of the two policies.</p>

<bu:rSection anchor="03" title="Next Steps" />

<p>This recipe configures just the AWS side of the S3 equation. Once your bucket is set up correctly and can be accessed from the EC2 instance, the recipe,
<bu:rLink id="using-s3" />, will help you configure Spark itself.</p>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="http://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html">Amazon IAM User Guide</a></li>
		<li><a href="http://docs.aws.amazon.com/AmazonS3/latest/dev/Welcome.html">Amazon S3 Developer Guide</a></li>
		<li><a href="http://blogs.aws.amazon.com/security/post/TxPOJBY6FE360K/IAM-policies-and-Bucket-Policies-and-ACLs-Oh-My-Controlling-Access-to-S3-Resourc">IAM Policies and Bucket Policies and ACLs! Oh, My! (Controlling Access to S3 Resources)</li>
		<li><a href="https://wiki.apache.org/hadoop/AmazonS3">Amazon S3</a> in the Hadoop Wiki</li>
		<li><bu:rLink id="s3-vpc-endpoint" /></li>	
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>