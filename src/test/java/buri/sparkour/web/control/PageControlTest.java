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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.junit.Test;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import buri.sparkour.AbstractSpringTestCase;
/**
 * Controller tests.
 * 
 * @author Brian Uri!
 */
public class PageControlTest extends AbstractSpringTestCase {
	
	@Configuration
	public static class TestConfiguration {
		@Bean
		public PageControl pageControl() {
			return new PageControl();
		}
	}
	
	@Test
	public void testHome() throws Exception {
	    mockMvc.perform(get("/"))
	    	.andExpect(status().isOk())
	    	.andExpect(view().name("/home/index"));	    	
	}
	
	@Test
	public void testRecipes() throws Exception {
	    mockMvc.perform(get("/recipes"))
	    	.andExpect(status().isOk())
	    	.andExpect(view().name("/recipes/index"));	    	
	}
	
	@Test
	public void testRecipe() throws Exception {
	    mockMvc.perform(get("/recipes/installing-ec2/"))
	    	.andExpect(status().isOk())
	    	.andExpect(view().name("/recipes/installing-ec2"));
	    mockMvc.perform(get("/recipes/abc.ABC/"))
    		.andExpect(status().isNotFound());		    
	}
	
	@Test
	public void testLicense() throws Exception {
	    mockMvc.perform(get("/license"))
	    	.andExpect(status().isOk())
	    	.andExpect(view().name("/home/license"));	    	
	}
}