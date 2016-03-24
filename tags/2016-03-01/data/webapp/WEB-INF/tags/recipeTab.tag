<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="index" required="true" type="java.lang.String" %>
<div class="tab-${index} tabContent"><jsp:doBody /></div>