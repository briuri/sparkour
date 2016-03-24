<%@ page isErrorPage="true" %>
<%@ include file="./WEB-INF/jsp/shared/header.jspf" %>
	<title>404 Not Found</title>
</head>
<body>
	<div id="layoutOuterPosition">
		<a href="${homeUrl}"><div id="layoutHeaderRow">Sparkour</div></a>
		<div id="menuContainer">
			<ul id="menu">
			</ul>
		</div>
		<div id="layoutContent">
			<div id="layoutInnerContent">	
				<h1>404 Not Found</h1>
				<p>The page at <code><c:out value="${pageContext.errorData.requestURI}" /></code> could not be found.</p>
<%@ include file="./WEB-INF/jsp/shared/footer.jspf" %>