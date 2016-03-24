<%@ taglib prefix="bu" uri="http://www.urizone.net/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="anchor" required="true" type="java.lang.String" %>
<%@ attribute name="title" required="true" type="java.lang.String" %>
<a name="<c:out value="${anchor}" />"></a><h2><bu:rTocLink /> <c:out value="${title}" escapeXml="false" /></h2>