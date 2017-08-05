name := "BuildingSBT"
version := "1.0"
scalaVersion := "2.11.11"

libraryDependencies += "org.apache.spark" %% "spark-core" % "2.2.0" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.2.0" % "provided"
libraryDependencies += "org.apache.commons" % "commons-csv" % "1.2"
