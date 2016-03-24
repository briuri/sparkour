<%@ include file="../shared/header.jspf" %>
<bu:rTabHandlers />
<%@ include file="../shared/headerSplit.jspf" %>

<bu:rOverview publishDate="2016-02-24">
	<h3>Synopsis</h3>
	<p>This tutorial describes the formatting conventions used in the Sparkour recipes.
	There is no hands-on work involved.
	
	<h3>Tutorial Goals</h3>
	<ul>
		<li>You will understand how recipe instructions and code samples are presented.</li>
	</ul>
	
	<a name="toc"></a>
	<h3>Section Links</h3>
	<ul>
		<li><a href="#01">Instructions</a></li>
		<li><a href="#02">Code Samples</a></li>
	</ul>
</bu:rOverview>

<bu:rSection anchor="01" title="Instructions" />

<p>Sparkour recipes employ a few formatting conventions to make instructions clearer:</p>

<ul>
	<li><span class="rPN">Page Name</span> denotes the title of a page, or a tabbed pane within a page. 
		This is also used to highlight important terminology.</li>
	<li><span class="rMI">Menu Item</span> denotes an option in a menu that needs to be selected.</li>
	<li><span class="rAB">Button</span> denotes an important button you need to press in
		a user interface (UI).</li>
	<li><span class="rK">Field Name</span> denotes the name of a form field in a UI.</li>
	<li><span class="rV">Field Value</span> denotes the value that you would enter into a form field. Example values in a recipe
		will generally include a <span class="rV">sparkour-</span> prefix. Feel free to customize this with a token
		relevant to your own work.</li>
	<li><span class="rCW">code word</span> denotes technical coding concepts, such as the names
		of classes and variables, or the name of a Linux command line utility.</li>
</ul>

<bu:rSection anchor="02" title="Code Samples" />	

<p>Commands to be typed at the Linux command line are <span class="rCW">bash</span>-compatible
	and displayed in a syntax-highlighted box. The command prompt is not shown:</p>
	
<bu:rCode lang="bash">
	# This is a comment that explains the next command. You don't need to type this.
	typeThis.sh parameter1 parameter2
	# (Parenthetical comments describe an action you'd take based on the results 
	#  of the previous command, such as selecting something from a follow-up menu)
</bu:rCode>

<p>Code samples employ the Java, Python, R, or Scala programming languages. If the example
	has been translated into multiple languages, a separate box appears for each employed language. These boxes will show code
	in Python by default, but you can change the language and use the &#128190; icon to save your preferred language.</p>

<bu:rTabs>
	<bu:rTab index="1">
		<bu:rCode lang="java">
			/**
			 * A sample Java class.
			 */
			public class SparkApp() {
			
				public SparkApp() {}
			}
		</bu:rCode>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			class SparkApp():
				"""A sample Python class.
				
			    	camelCase used for variable names for consistency and
    				ease of translation across the prevailing style of
    				the Java, R, and Scala examples.
				"""
				
				def __init__(self):
			   		self.data = []
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="plain">
			# R code using SparkR as a front-end to Spark
			
			# Use SparkR to get the SparkContext
			sc <- sparkR.init("local")
			sqlContext <- sparkRSQL.init(sc)

			# Create a DataFrame from a text file
			people <- read.df(sqlContext, "data.json", "json")
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			/**
			 * A sample Scala class
			 */
			object SparkApp {
			
			}
		</bu:rCode>	
	</bu:rTab>
</bu:rTabs>

<p>Code intended for the Spark interactive shells will include the shell prompt at the beginning of each line:</p>

<bu:rTabs>
	<bu:rTab index="1">
		<p>There is no interactive shell in Java.</p>
	</bu:rTab><bu:rTab index="2">
		<bu:rCode lang="python">
			>>> # This is a comment in Spark's Python interactive shell. You don't need to type this.
			>>> quit()
		</bu:rCode>
	</bu:rTab><bu:rTab index="3">
		<bu:rCode lang="plain">
			> # This is a comment in an R shell. You don't need to type this.
			> quit()
		</bu:rCode>
	</bu:rTab><bu:rTab index="4">
		<bu:rCode lang="scala">
			scala> // This is a comment in Spark's Scala interactive shell. You don't need to type this.
			scala> exit
		</bu:rCode>
	</bu:rTab>
</bu:rTabs>

<bu:rFooter>
	<bu:rChangeLog>
		<li>2016-03-13: Added instructions for saving a preferred programming language
			(<a href="https://ddmsence.atlassian.net/projects/SPARKOUR/issues/SPARKOUR-1">SPARKOUR-1</a>).</li>
	</bu:rChangeLog>
</bu:rFooter>
	
<bu:rIndexLink />	
<%@ include file="../shared/footer.jspf" %>