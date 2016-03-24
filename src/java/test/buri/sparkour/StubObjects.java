/* Copyright 2016 by Brian Uri!
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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import java.util.Locale;
import java.util.Map;

import javax.servlet.AsyncContext;
import javax.servlet.DispatcherType;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletInputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

/**
 * Dummy objects created to test special conditions. Extracted here so as not to clutter up the Test classes.
 * 
 * @author Brian Uri!
 */
public class StubObjects {
	
	/**
	 * A stub class that is used to test the non session-id path in the filter.
	 */
	public static class StubServletRequest implements ServletRequest {
		public AsyncContext getAsyncContext() {
			return null;
		}
		public Object getAttribute(String arg0) {
			return null;
		}
		public Enumeration<String> getAttributeNames() {
			return null;
		}
		public String getCharacterEncoding() {
			return null;
		}
		public int getContentLength() {
			return 0;
		}
		public long getContentLengthLong() {
			return 0;
		}
		public String getContentType() {
			return null;
		}
		public DispatcherType getDispatcherType() {
			return null;
		}
		public ServletInputStream getInputStream() throws IOException {
			return null;
		}
		public String getLocalAddr() {
			return null;
		}
		public String getLocalName() {
			return null;
		}
		public int getLocalPort() {
			return 0;
		}
		public Locale getLocale() {
			return null;
		}
		public Enumeration<Locale> getLocales() {
			return null;
		}
		public String getParameter(String arg0) {
			return null;
		}
		public Map<String, String[]> getParameterMap() {
			return null;
		}
		public Enumeration<String> getParameterNames() {
			return null;
		}
		public String[] getParameterValues(String arg0) {
			return null;
		}
		public String getProtocol() {
			return null;
		}
		public BufferedReader getReader() throws IOException {
			return null;
		}
		public String getRealPath(String arg0) {
			return null;
		}
		public String getRemoteAddr() {
			return null;
		}
		public String getRemoteHost() {
			return null;
		}
		public int getRemotePort() {
			return 0;
		}
		public RequestDispatcher getRequestDispatcher(String arg0) {
			return null;
		}
		public String getScheme() {
			return null;
		}
		public String getServerName() {
			return null;
		}
		public int getServerPort() {
			return 0;
		}
		public ServletContext getServletContext() {
			return null;
		}
		public boolean isAsyncStarted() {
			return false;
		}
		public boolean isAsyncSupported() {
			return false;
		}
		public boolean isSecure() {
			return false;
		}
		public void removeAttribute(String arg0) {}
		public void setAttribute(String arg0, Object arg1) {}
		public void setCharacterEncoding(String arg0) throws UnsupportedEncodingException {}
		public AsyncContext startAsync() {
			return null;
		}
		public AsyncContext startAsync(ServletRequest arg0, ServletResponse arg1) {
			return null;
		}		
	}
}
