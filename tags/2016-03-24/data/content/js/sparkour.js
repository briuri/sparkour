var eMail = "\u0073\u0070\u0061\u0072\u006b\u006f\u0075\u0072\u0040\u0075\u0072\u0069\u007a\u006f\u006e\u0065\u002e\u006e\u0065\u0074"

if (parent.location.href.indexOf("urizone.net") != -1) {
	var sc_project=10838703;
	var sc_invisible=0;
	var sc_partition=63;
	var sc_click_stat=1;
	var sc_security="7c0dc6ec";
	var sc_text=2;
}

// Cookies.get wrapper with a default value
function getCookie(name, defaultValue) {
	value = Cookies.get(name)
	if (typeof value === "undefined") {
		return defaultValue;
	}
	return value;
}

// Add event handlers for saving the code tab choice (used on individual recipes)
function registerSaveTabClicks() {
	$(".tabSave").click(function(event) {
		var savedTab = $(this).parent().siblings(".tabCurrent").children().first().attr("href");
		Cookies.set("defaultCodeTab", savedTab, { expires: 30 });
		
		$(".tabsCodeMenu li").removeClass("tabCurrent");
		$(".tabsCodeMenu li a[href$='" + savedTab + "']").parent().addClass("tabCurrent");
		
		$('.tabCodeContentPane').children(savedTab).css("display", "block");
		$('.tabCodeContentPane').children().not(savedTab).css("display", "none");
		
		$(this).next().hide();
		$(this).next().show(0);
	});
}

// Add event handlers for tab clicking (used on recipes page and individual recipes)
function registerTabClicks() {
	$(".tabsMenu a").click(function(event) {
		event.preventDefault();
		var liElement = $(this).parent()
        liElement.addClass("tabCurrent");
        liElement.siblings().removeClass("tabCurrent");
		$(".tabSaveMessage").hide();
		        
        var selectedTab = $(this).attr("href");
        var tabContentPaneElement = liElement.parent().next();		        
        tabContentPaneElement.children().not(selectedTab).css("display", "none");
        tabContentPaneElement.children(selectedTab).fadeIn(200);
	});
}

// Remember the most recently visited recipe tab (just for recipes page)
function rememberLastRecipeTab() {
	var lastRecipeTab = getCookie("lastRecipeTab", ".tab-1");
	$("a[href$='" + lastRecipeTab + "']").parent().addClass("tabCurrent");
	$(".tabContentPane").children(lastRecipeTab).css("display", "block");
	$(".tabsMenu a").click(function(event) {
		Cookies.set("lastRecipeTab", $(this).attr("href"), { expires: 1 });
	});
}

// Show all of the code tabs based on the default setting. (used on individual recipes)
function showDefaultCodeTab() {
	var defaultCodeTab = getCookie("defaultCodeTab", ".tab-2");
	$("a[href$='" + defaultCodeTab + "']").parent().addClass("tabCurrent");
	$(".tabCodeContentPane").children(defaultCodeTab).css("display", "block");
}