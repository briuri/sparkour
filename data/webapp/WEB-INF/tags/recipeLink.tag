<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ attribute name="id" required="false" type="java.lang.String" %>
<c:if test="${not empty id}"><spring:url var="recipeUrl" value="/recipes/${id}/" /><a href="${recipeUrl}"></c:if><c:out value="${recipeTitles[id]}" /><c:if test="${not empty id}"></a></c:if>