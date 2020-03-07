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
package buri.sparkour.web;

import static org.junit.Assert.*;

import javax.servlet.ServletRequest;

import org.junit.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockFilterConfig;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import buri.sparkour.AbstractSpringTestCase;
import buri.sparkour.StubObjects;

/**
 * Basic test for JSessionId
 * 
 * @author Brian Uri!
 */
public class JSessionIdFilterTest extends AbstractSpringTestCase {

	private JSessionIdFilter jSessionIdFilter = new JSessionIdFilter();
	
	@Test
	public void testInvalidate() throws Exception {
		MockFilterChain chain = new MockFilterChain();
		MockFilterConfig config = new MockFilterConfig();
		MockHttpServletRequest request = new MockHttpServletRequest();
		MockHttpServletResponse response = new MockHttpServletResponse();
		request.getSession(true);
		request.setRequestedSessionIdFromURL(true);
		jSessionIdFilter.init(config);
		jSessionIdFilter.doFilter(request, response, chain);
		jSessionIdFilter.destroy();
		assertNull(request.getSession(false));
	}
	
	@Test
	public void testResponseWrapper() {
		JSessionIdFilter.NonEncodingWrapper wrapper = new JSessionIdFilter.NonEncodingWrapper(new MockHttpServletResponse());
		assertEquals("Test", wrapper.encodeRedirectUrl("Test"));
		assertEquals("Test", wrapper.encodeRedirectURL("Test"));
		assertEquals("Test", wrapper.encodeUrl("Test"));
		assertEquals("Test", wrapper.encodeURL("Test"));
	}
	
	@Test
	public void testNotHttpServletRequest() throws Exception {
		MockFilterChain chain = new MockFilterChain();
		MockFilterConfig config = new MockFilterConfig();
		ServletRequest request = new StubObjects.StubServletRequest();
		MockHttpServletResponse response = new MockHttpServletResponse();
		jSessionIdFilter.init(config);
		jSessionIdFilter.doFilter(request, response, chain);
		jSessionIdFilter.destroy();
	}
}