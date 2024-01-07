/* Copyright 2016 - 2020 by Brian Uri!
   sparkour@urizone.net, https://sparkour.urizone.net/

   Licensed under the Apache License, Version 2.0 (the "License"); you may not
   use this file except in compliance with the License. You may obtain a copy
   of the License at:

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */
package buri.sparkour.web.control;

import java.util.Collections;
import java.util.Map;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import buri.sparkour.web.AbstractControl;

/**
 * Controller class for web page operations.
 *
 * @author Brian Uri!
 */
@Controller
public class PageControl extends AbstractControl {

	@Resource(name="recipeTitles")
	private Map<String, String> _recipeTitles;

	private static final String RECIPE_ID_PATTERN = "^[a-zA-Z0-9\\-]+$";

	/**
	 * Entry point for displaying the home page.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home() {
		return ("/home/index");
	}

	/**
	 * Entry point for displaying the recipes page.
	 */
	@RequestMapping(value = "/recipes", method = RequestMethod.GET)
	public String recipes() {
		return ("/recipes/index");
	}

	/**
	 * Entry point for displaying a specfic recipe.
	 */
	@RequestMapping(value = "/recipes/{id}/", method = RequestMethod.GET)
	public String recipe(@PathVariable("id") String id, ModelMap modelMap, HttpServletResponse response) {
		if (!id.matches(RECIPE_ID_PATTERN)) {
			response.setStatus(HttpStatus.NOT_FOUND.value());
			return ("");
		}
		modelMap.addAttribute("id", id);
		modelMap.addAttribute("pageTitle", getRecipeTitles().get(id));
		modelMap.addAttribute("imagesPath", "/recipes/" + id);
		return ("/recipes/" + id);
	}

	/**
	 * Entry point for displaying the license page.
	 */
	@RequestMapping(value = "/license", method = RequestMethod.GET)
	public String license() {
		return ("/home/license");
	}

	/**
	 * Accessor for the map of recipe IDs to recipe titles
	 */
	@ModelAttribute("recipeTitles")
	public Map<String, String> getRecipeTitles() {
		return (Collections.unmodifiableMap(_recipeTitles));
	}
}