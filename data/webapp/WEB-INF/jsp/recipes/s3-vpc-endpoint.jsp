<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-04-13">
	<h3>Synopsis</h3>
	<p>This recipe shows how to set up a VPC Endpoint for Amazon S3, which allows your Spark cluster to interact with S3 resources
	from a private subnet without a Network Address Translation (NAT) instance or Internet Gateway.</p>
	
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
		<li><a href="#01">VPC Endpoint Highlights</a></li>
		<li><a href="#02">Establishing the VPC Endpoint</a></li>
		<li><a href="#03">Next Steps</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="VPC Endpoint Highlights" />

<p>Amazon S3 is a key-value object store that can be used as a data source to your Spark cluster. Normally, connections between EC2 instances in a Virtual Private Cloud (VPC)
and resources in S3 require an Internet Gateway to be established in the VPC. However, you may need to deploy your Spark cluster in a private subnet where no Internet Gateway
is available. In this case, you can establish a VPC Endpoint, which enables secure connections to S3 without the extra expense of a NAT instance. (Normally, a NAT instance would be
needed to allow instances in the private subnet to share the Internet Gateway of a nearby public subnet).</p>

<p>Currently, S3 is the only Amazon service accessible over a VPC Endpoint, but other services are expected to adopt Endpoints in the future. 
Using a VPC Endpoint to access S3 also improves your cluster's security posture, as traffic between the cluster and S3 never leaves the Amazon network.</p>  

<bu:rSection anchor="02" title="Establishing the VPC Endpoint" />

<ol>
	<li>Login to your <a href="https://console.aws.amazon.com/">AWS Management Console</a> and select the 
		<span class="rPN">VPC</span> service.</li>
	<li>Navigate to <span class="rMI">Endpoints</span> in the left side menu, and then select
		<span class="rAB">Create Endpoint</span> at the top of the page. 
		This starts a wizard workflow to create a new Endpoint.</li>
	<li>On <span class="rPN">Step 1. Configure Endpoint</span>, set the <span class="rK">VPC</span> to 
		the VPC containing your Spark cluster or other EC2 instances. In this example, we're using the Default VPC
		provided with the base AWS account, as shown in the image below.</li>
		
	<img src="${localImagesUrlBase}/configure-endpoint.png" width="600" height="585" title="Configuring a VPC Endpoint to S3" class="diagram border" />
	
	<li>Like all AWS services, you can attach policies for fine-grained access control to the VPC Endpoint. You
		can also configure bucket policies in S3 to control access <i>from</i> specific Endpoints. In this example,
		we're using the <span class="rV">Full Access</span> policy on the Endpoint. The recipe,
		<bu:rLink id="configuring-s3" />, shows how to configure bucket policies. Go to the <span class="rAB">Next Step</span>.</li>
	<li>On <span class="rPN">Step 2. Configure Route Tables</span>, select the route table corresponding to 
		subnets that need access to the Endpoint. In this example, the default VPC has a route table attached
		to the four default subnets. Any EC2 instance in any of the subnets are able to use the Endpoint, unless
		we explicitly configure an access control policy on the previous page.</li>
	<li>Before you proceed, make sure that there is no active communication between your Spark cluster and S3.
		Any active connections are dropped when the Endpoint is established. When ready, go to <span class="rAB">Create Endpoint</span>.
		You should see "Endpoint created" as a status message. Go to <span class="rAB">View Endpoints</span>
		to return to the list of Endpoints.</li>
	<li>From the VPC Dashboard, navigate to <span class="rMI">Route Tables</span> and then select the modified route table
		in the dashboard. Details about the route table appear in the lower pane, as seen in the image below. Select the
		<span class="rPN">Routes</span> tab.</li>
	
	<img src="${localImagesUrlBase}/routes.png" width="692" height="452" title="Showing the Routes in the Route Table" class="diagram border" />
	
	<li>Routes are processed in order from most specific to least specific. In this example, there is a route for local
		traffic within the VPC, a new route pointing to our new S3 VPC Endpoint, and a catch-all route pointing to the
		Internet Gateway for all other traffic. (If you are working in a private subnet, you should not see the catch-all route).</li>
</ol>

<bu:rSection anchor="03" title="Next Steps" />

<p>The recipe, <bu:rLink id="configuring-s3" />, provides instructions for setting up an S3 bucket and testing a connection between
EC2 and S3. Normally, those tests would send and receive traffic through the configured Internet Gateway out of Amazon's network, and then
back in to S3. Now that you have created a VPC Endpoint, it is the preferred route for such traffic. If your Spark cluster
is in a private subnet, those tests should fail without a VPC Endpoint in place.</p>

<p>If your Spark cluster is in a public subnet and you want to confirm that the VPC Endpoint is working, 
you can temporarily detach the Internet Gateway from the VPC:</p>

<ol>
	<li>Confirm that no critical applications are running that require use of the Internet Gateway.</li>
	<li>From the VPC Dashboard, navigate to <span class="rMI">Internet Gateways</span> in the left side menu, 
		and then select the Internet Gateway attached to your VPC, as shown in the image below.</li>
	
	<img src="${localImagesUrlBase}/internet-gateways.png" width="700" height="308" title="Managing Internet Gateways in the VPC Dashboard" class="diagram border" />
	
	<li>Select <span class="rAB">Detach from VPC</span> and then try the connection tests from the other recipe again.
		If your VPC Endpoint is configured properly, the connection between EC2 and S3 will continue to work without the 
		Internet Gateway.</li>
	<li>When you have confirmed the behavior, select <span class="rAB">Attach to VPC</span> to restore Internet connectivity
		to your VPC.</li>	
</ol>

<bu:rFooter>
	<bu:rLinks>
		<li><a href="hhttp://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-endpoints.html">VPC Endpoints</a> in the Amazon VPC Documentation</a></li>
		<li><a href="http://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies-vpc-endpoint.html">Example Bucket Policies for VPC Endpoints</a> in the Amazon S3 Documentation</li>
		<li><bu:rLink id="configuring-s3" /></li>
		<li><bu:rLink id="using-s3" /></li>	
	</bu:rLinks>
	
	<bu:rChangeLog>
		<li>This recipe hasn't had any substantive updates since it was first published.</li>
	</bu:rChangeLog>
</bu:rFooter>

<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>