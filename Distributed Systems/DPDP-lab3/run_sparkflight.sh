#!/bin/bash
mvn package
hadoop fs -copyFromLocal 664600583_T_ONTIME_sample.csv
hadoop fs -copyFromLocal L_AIRPORT_ID.csv
export HADOOP_CLASSPATH=target/flightstatistics-1.0-SNAPSHOT.jar
hdfs dfs -rm -r hdfs://localhost:9000/user/kolldun/output
spark-submit --class sparkflight.SparkFlightApp --master yarn-client --num-executors 3 target/sparkflight-1.0-SNAPSHOT.jar output 664600583_T_ONTIME_sample.csv L_AIRPORT_ID.csv
rm -R /home/kolldun/IdeaProjects/DPDP-lab3/output
hadoop fs -copyToLocal output