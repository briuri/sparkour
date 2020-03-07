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
package buri.sparkour;

import static org.junit.Assert.*;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.*;

import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.context.WebApplicationContext;

/**
 * Base class for test cases involving Spring configuration.
 * 
 * @author Brian Uri!
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:sparkour-context.xml", "classpath:sparkour-servlet.xml" })
@WebAppConfiguration(value = "output/staging/webapp")
public abstract class AbstractSpringTestCase {

	@Autowired
	private WebApplicationContext context;

	protected MockMvc mockMvc;

	protected static final String EXCEPTION_URL = "/WEB-INF/jsp/exception.jsp";

	@Before
	public final void baseSetUp() {
		// Set up mock MVC for control tests
		mockMvc = webAppContextSetup(context).build();
	}

	@After
	public final void baseTearDown() {
	}
	
	/**
	 * Convenience method to fail a test if the wrong error message comes back. This addresses cases where a test is no
	 * longer failing for the reason we expect it to be failing.
	 * 
	 * @param e the exception
	 * @param message the beginning of the expected message (enough to confirm its accuracy).
	 */
	protected void expectMessage(Exception e, String message) {
		if (!e.getMessage().contains(message)) {
			System.out.println(e.getMessage());
			fail("Test failed for the wrong reason.");
		}
	}
	
	/**
	 * Convenience method to fail out because an execution path should not have succeeded.
	 */
	protected void failNoException() {
		fail("Expected exception was not thrown.");
	}
}