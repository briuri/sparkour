/* Copyright 2016 - 2019 by Brian Uri!
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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Base class for Spring controllers, which provides common infrastructure such
 * as logging.
 * 
 * @author Brian Uri!
 */
public abstract class AbstractControl {

	protected final Logger logger = LoggerFactory.getLogger(getClass());

}