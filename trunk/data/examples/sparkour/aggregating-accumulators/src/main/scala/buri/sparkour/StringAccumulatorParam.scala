/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package buri.sparkour

import org.apache.spark.AccumulatorParam

/**
 * A custom accumulator for string concatenation
 * Contrived example -- see recipe for caveats.
 */
object StringAccumulatorParam extends AccumulatorParam[String] {
	def zero(initialValue: String): String = {
		""
	}
				
	def addInPlace(s1: String, s2: String): String = {
		s1.trim + " " + s2.trim
	}
}
