#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import csv
import json

"""
	A simple utility script to convert election CSV results into
	JSON for use as a DataFrame.
	
	camelCase used for variable names for consistency and
	ease of translation across the prevailing style of
	the Java, R, and Scala examples.
"""

csvFile = open('../results.csv', 'r')
jsonFile = open('../loudoun_d_primary_results_2016.json', 'w')

fieldNames = ( 
    "election_name",
    "election_date",
    "election_type",
    "locality_name",
    "locality_code",
    "office_name",
    "referendum_title",
    "precinct_name",
    "precinct_code",
    "candidate_name",
    "last_name",
    "candidateId",
    "officeId",
    "referendumId",
    "districtId",
    "DESCRIPTION",
    "district_type",
    "party",
    "office_ballot_order",
    "candidate_ballot_order",
    "total_votes",
    "negative_votes",
    "in_precinct",
)
reader = csv.DictReader(csvFile, fieldNames)
for row in reader:
    json.dump(row, jsonFile)
    jsonFile.write('\n')
