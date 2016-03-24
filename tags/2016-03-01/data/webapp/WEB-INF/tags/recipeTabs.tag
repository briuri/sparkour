<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="tabsContainer">
    <ul class="tabsMenu">
        <li><a href=".tab-1">Java</a></li>
        <li class="tabCurrent"><a href=".tab-2">Python</a></li>
        <li><a href=".tab-3">R</a></li>
        <li><a href=".tab-4">Scala</a></li>
    </ul>
    <div class="tabContentPane"><jsp:doBody /></div>
</div>