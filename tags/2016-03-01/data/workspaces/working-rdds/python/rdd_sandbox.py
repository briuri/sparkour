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
from pyspark import SparkContext

"""
    Performs a variety of RDD manipulations to show off 
    the data structure.
"""
if __name__ == "__main__":
    sc = SparkContext(appName="PythonRddSandbox")

    # Create an array of 1000 random numbers between 0 and 50.
    numbers = []
    for x in range (1000):
        numbers.append(random.randint(0, 50))

    # Create an RDD from the numbers array
    numbers_list_rdd = sc.parallelize(numbers)

    # Create an RDD from a similar array on the local filesystem
    numbers_file_rdd = sc.textFile("random_numbers.txt")

    # 1000 Chicago residents: How many books do you own?
    chicago_rdd = numbers_list_rdd

    # 1000 Houston residents: How many books do you own?
    # Must convert from string data to ints first
    houston_rdd = numbers_file_rdd.flatMap(lambda x: x.split(' ')) \
                                  .map(lambda x: int(x))

    # How many have more than 30 in Chicago?
    more_than_thirty = chicago_rdd.filter(lambda x: x > 30).count()
    print("{} Chicago residents have more than 30 books.".format(more_than_thirty))

    # What's the most number of books in either city?
    most_books = chicago_rdd.union(houston_rdd).reduce(lambda x, y: x if x > y else y)
    print("{} is the most number of books owned in either city.".format(most_books))

    # What's the total number of books in both cities?
    total_books = chicago_rdd.union(houston_rdd).reduce(add)
    print("{} books in both cities.".format(total_books))

    sc.stop()
