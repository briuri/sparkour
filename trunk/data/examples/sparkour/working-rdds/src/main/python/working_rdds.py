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

from __future__ import print_function
import random
from operator import add
from pyspark.sql import SparkSession

"""
    Performs a variety of RDD manipulations to show off 
    the data structure.
    
    camelCase used for variable names for consistency and
    ease of translation across the prevailing style of
    the Java, R, and Scala examples.
"""
if __name__ == "__main__":
    spark = SparkSession.builder.appName("workings_rdds").getOrCreate()

    # Create an array of 1000 random numbers between 0 and 50.
    numbers = []
    for x in range (1000):
        numbers.append(random.randint(0, 50))

    # Create an RDD from the numbers array
    numbersListRdd = spark.sparkContext.parallelize(numbers)

    # Create an RDD from a similar array on the local filesystem
    numbersFileRdd = spark.read.text("random_numbers.txt").rdd

    # 1000 Chicago residents: How many books do you own?
    chicagoRdd = numbersListRdd

    # 1000 Houston residents: How many books do you own?
    # Must convert from string data to ints first
    houstonRdd = numbersFileRdd.flatMap(lambda x: x.split(' ')) \
                                  .map(lambda x: int(x))

    # How many have more than 30 in Chicago?
    moreThanThirty = chicagoRdd.filter(lambda x: x > 30).count()
    print("{} Chicago residents have more than 30 books.".format(moreThanThirty))

    # What's the most number of books in either city?
    mostBooks = chicagoRdd.union(houstonRdd).reduce(lambda x, y: x if x > y else y)
    print("{} is the most number of books owned in either city.".format(mostBooks))

    # What's the total number of books in both cities?
    totalBooks = chicagoRdd.union(houstonRdd).reduce(add)
    print("{} books in both cities.".format(totalBooks))

    spark.stop()
