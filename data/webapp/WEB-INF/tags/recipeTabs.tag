<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="tabsContainer">
    <ul class="tabsMenu tabsCodeMenu">
        <li><a href=".tab-1">Java</a></li>
        <li><a href=".tab-2">Python</a></li>
        <li><a href=".tab-3">R</a></li>
        <li><a href=".tab-4">Scala</a></li>
        <li><span class="tabSave">&#128190;</span><span class="tabSaveMessage">Default language saved.</span></li>
    </ul>
    <div class="tabContentPane tabCodeContentPane"><jsp:doBody /></div>
</div>