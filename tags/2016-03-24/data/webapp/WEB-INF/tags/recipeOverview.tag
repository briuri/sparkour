<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="publishDate" required="true" type="java.lang.String" %>
<div class="rDate">published on <c:out value="${publishDate}" /></div>
<div class="rReference"><jsp:doBody /></div>