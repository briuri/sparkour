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

package buri.sparkour;

import org.apache.spark.util.AccumulatorV2;

/**
 * A custom accumulator for string concatenation
 *
 * Contrived example -- see recipe for caveats. The built-in
 * CollectionAccumulator does something similar but more elegantly.
 */
public class StringAccumulator extends AccumulatorV2<String, String> {

	private String _value;

	private static final String DEFAULT_INITIAL_VALUE = "";

	public StringAccumulator() {
		this(DEFAULT_INITIAL_VALUE);
	}

	public StringAccumulator(String initialValue) {
		if (initialValue == null) {
			initialValue = DEFAULT_INITIAL_VALUE;
		}
		_value = initialValue;
	}

	public void add(String value) {
		_value = value() + " " + value.trim();
	}

	public StringAccumulator copy() {
		return (new StringAccumulator(value()));
	}

	public boolean isZero() {
		return (value().length() == 0);
	}

	public void merge(AccumulatorV2<String, String> other) {
		this.add(other.value());
	}

	public void reset() {
		_value = DEFAULT_INITIAL_VALUE;
	}

	public String value() {
		return (_value);
	}
}
