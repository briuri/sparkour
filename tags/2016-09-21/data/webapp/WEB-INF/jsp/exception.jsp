<%@ page isErrorPage="true" %>
<%@ include file="./shared/header.jspf" %>
<c:set var="pageTitle" value="Error Encountered" />
<script type="text/javascript">	 
	$(document).ready(function() {
		$("div.isExpanded").click(function() {
			$(this).hide("fast");
			$(this).next().show("fast");
		});
	});
</script> 	
<%@ include file="./shared/headerSplit.jspf" %>

<h1>Error Encountered</h1>
	
<p><c:out value="${exception.message}" /></p>
<div class="isExpanded"><a href="#" onClick="return false;">show details...</a></div>	
<div class="isHidden">
<pre class="exception">
<c:forEach items="${exception.stackTrace}" var="stackTrace">
	<c:out value="${stackTrace}" /></c:forEach>
</pre>
</div>

<%@ include file="./shared/footer.jspf" %>