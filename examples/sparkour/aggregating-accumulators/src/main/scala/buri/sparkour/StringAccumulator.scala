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

import org.apache.spark.util.AccumulatorV2

/**
 * A custom accumulator for string concatenation
 *
 * Contrived example -- see recipe for caveats. The built-in
 * CollectionAccumulator does something similar but more elegantly.
 */
class StringAccumulator(private var _value: String) extends AccumulatorV2[String, String] {

	def this() {
		this("")
	}

	override def add(newValue: String): Unit = {
		_value = value + " " + newValue.trim
	}

	override def copy(): StringAccumulator = {
		new StringAccumulator(value) 
	}

	override def isZero(): Boolean = {
		value.length() == 0
	}

	override def merge(other: AccumulatorV2[String, String]): Unit = {
		add(other.value)
	}

	override def reset(): Unit = {
		_value = ""
	}

	override def value(): String = {
		_value
	}
}
