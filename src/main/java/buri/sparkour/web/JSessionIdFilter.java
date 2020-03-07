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

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import javax.servlet.http.HttpSession;

/**
 * Servlet filter which disables URL-encoded session identifiers.
 * 
 * @author Brian Uri!
 */
public class JSessionIdFilter implements Filter {

	/**
	 * Filters requests to disable URL-based session identifiers.
	 */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException,
		ServletException {
		if (!(request instanceof HttpServletRequest)) {
			chain.doFilter(request, response);
			return;
		}
		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		if (httpRequest.isRequestedSessionIdFromURL()) {
			HttpSession session = httpRequest.getSession(false);
			if (session != null) {
				session.invalidate();
			}
		}
		chain.doFilter(request, new NonEncodingWrapper(httpResponse));
	}

	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig config) throws ServletException {}

	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {}
	
	/**
	 * Response wrapper which does not encode URLs.
	 * 
	 * @author Brian Uri!
	 */
	public static final class NonEncodingWrapper extends HttpServletResponseWrapper {
		
		/**
		 * Base constructor
		 */
		public NonEncodingWrapper(HttpServletResponse response) {
			super(response);
		}
		
		@Override
		public String encodeRedirectUrl(String url) {
			return url;
		}
		
		@Override
		public String encodeRedirectURL(String url) {
			return url;
		}
		
		@Override
		public String encodeUrl(String url) {
			return url;
		}
		
		@Override
		public String encodeURL(String url) {
			return url;
		}
	}
}