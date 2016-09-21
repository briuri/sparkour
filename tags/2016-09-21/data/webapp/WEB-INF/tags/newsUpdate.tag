<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="date" required="true" type="java.lang.String" %>
<div class="newsUpdate"><span class="newsDate"><c:out value="${date}" /></span> <jsp:doBody /></div>