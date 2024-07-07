/*
Run below statements in Athena Query Editor

Creates a Glue database that references to the S3 bucket location that stores the YARN metrics.
Replace <EMR_USAGE_DATABASE> with Glue database name of YARN metrics.
Replace <MY_REPORT_BUCKET> with your S3 URI.
*/
CREATE DATABASE IF NOT EXISTS <EMR_USAGE_DATABASE> LOCATION 's3://<MY_REPORT_BUCKET>/emr_usage_report'

-- Creates a table with name, cluster_usage, that references to cluster metrics
CREATE EXTERNAL TABLE IF NOT EXISTS <EMR_USAGE_DATABASE>.cluster_usage(
`appssubmitted` int COMMENT 'from deserializer',
`appscompleted` int COMMENT 'from deserializer',
`appspending` int COMMENT 'from deserializer',
`appsrunning` int COMMENT 'from deserializer',
`appsfailed` int COMMENT 'from deserializer',
`appskilled` int COMMENT 'from deserializer',
`reservedmb` int COMMENT 'from deserializer',
`availablemb` int COMMENT 'from deserializer',
`allocatedmb` int COMMENT 'from deserializer',
`pendingmb` int COMMENT 'from deserializer',
`reservedvirtualcores` int COMMENT 'from deserializer',
`availablevirtualcores` int COMMENT 'from deserializer',
`allocatedvirtualcores` int COMMENT 'from deserializer',
`pendingvirtualcores` int COMMENT 'from deserializer',
`containersallocated` int COMMENT 'from deserializer',
`containersreserved` int COMMENT 'from deserializer',
`containerspending` int COMMENT 'from deserializer',
`totalmb` int COMMENT 'from deserializer',
`totalvirtualcores` int COMMENT 'from deserializer',
`utilizedmbpercent` int COMMENT 'from deserializer',
`utilizedvirtualcorespercent` int COMMENT 'from deserializer',
`rmschedulerbusypercent` int COMMENT 'from deserializer',
`totalnodes` int COMMENT 'from deserializer',
`lostnodes` int COMMENT 'from deserializer',
`unhealthynodes` int COMMENT 'from deserializer',
`decommissioningnodes` int COMMENT 'from deserializer',
`decommissionednodes` int COMMENT 'from deserializer',
`rebootednodes` int COMMENT 'from deserializer',
`activenodes` int COMMENT 'from deserializer',
`shutdownnodes` int COMMENT 'from deserializer',
`totalusedresourcesacrosspartition` struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>> COMMENT 'from deserializer',
`totalclusterresourcesacrosspartition` struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>> COMMENT 'from deserializer',
`totalreservedresourcesacrosspartition` struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>> COMMENT 'from deserializer',
`totalallocatedcontainersacrosspartition` int COMMENT 'from deserializer',
`crosspartitionmetricsavailable` boolean COMMENT 'from deserializer',
`timestamp` bigint COMMENT 'from deserializer')
PARTITIONED BY (
`cluster_id` string,
`year` string,
`month` string,
`day` string)
ROW FORMAT SERDE
'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
'paths'='activeNodes,allocatedMB,allocatedVirtualCores,appsCompleted,appsFailed,appsKilled,appsPending,appsRunning,appsSubmitted,availableMB,availableVirtualCores,containersAllocated,containersPending,containersReserved,crossPartitionMetricsAvailable,decommissionedNodes,decommissioningNodes,lostNodes,pendingMB,pendingVirtualCores,rebootedNodes,reservedMB,reservedVirtualCores,rmSchedulerBusyPercent,shutdownNodes,timestamp,totalAllocatedContainersAcrossPartition,totalClusterResourcesAcrossPartition,totalMB,totalNodes,totalReservedResourcesAcrossPartition,totalUsedResourcesAcrossPartition,totalVirtualCores,unhealthyNodes,utilizedMBPercent,utilizedVirtualCoresPercent')
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
's3://<MY_REPORT_BUCKET>/emr_usage_report/cluster_usage/'
TBLPROPERTIES (
'classification'='json',
'compressionType'='none',
'typeOfData'='file')

-- Refresh the table to get updated partitions and data.  
MSCK REPAIR TABLE <EMR_USAGE_DATABASE>.cluster_usage

-- Creates a table with name, application_usage, that references to application metrics
CREATE EXTERNAL TABLE IF NOT EXISTS <EMR_USAGE_DATABASE>.application_usage(
`id` string COMMENT 'from deserializer',
`user` string COMMENT 'from deserializer',
`name` string COMMENT 'from deserializer',
`queue` string COMMENT 'from deserializer',
`state` string COMMENT 'from deserializer',
`finalstatus` string COMMENT 'from deserializer',
`progress` double COMMENT 'from deserializer',
`trackingui` string COMMENT 'from deserializer',
`trackingurl` string COMMENT 'from deserializer',
`diagnostics` string COMMENT 'from deserializer',
`clusterid` bigint COMMENT 'from deserializer',
`applicationtype` string COMMENT 'from deserializer',
`applicationtags` string COMMENT 'from deserializer',
`priority` int COMMENT 'from deserializer',
`startedtime` bigint COMMENT 'from deserializer',
`launchtime` bigint COMMENT 'from deserializer',
`finishedtime` bigint COMMENT 'from deserializer',
`elapsedtime` int COMMENT 'from deserializer',
`amcontainerlogs` string COMMENT 'from deserializer',
`amhosthttpaddress` string COMMENT 'from deserializer',
`masternodeid` string COMMENT 'from deserializer',
`allocatedmb` int COMMENT 'from deserializer',
`allocatedvcores` int COMMENT 'from deserializer',
`reservedmb` int COMMENT 'from deserializer',
`reservedvcores` int COMMENT 'from deserializer',
`runningcontainers` int COMMENT 'from deserializer',
`memoryseconds` int COMMENT 'from deserializer',
`vcoreseconds` int COMMENT 'from deserializer',
`queueusagepercentage` double COMMENT 'from deserializer',
`clusterusagepercentage` double COMMENT 'from deserializer',
`resourcesecondsmap` struct<entry:struct<key:string,value:string>> COMMENT 'from deserializer',
`preemptedresourcemb` int COMMENT 'from deserializer',
`preemptedresourcevcores` int COMMENT 'from deserializer',
`numnonamcontainerpreempted` int COMMENT 'from deserializer',
`numamcontainerpreempted` int COMMENT 'from deserializer',
`preemptedmemoryseconds` int COMMENT 'from deserializer',
`preemptedvcoreseconds` int COMMENT 'from deserializer',
`preemptedresourcesecondsmap` string COMMENT 'from deserializer',
`logaggregationstatus` string COMMENT 'from deserializer',
`unmanagedapplication` boolean COMMENT 'from deserializer',
`amnodelabelexpression` string COMMENT 'from deserializer',
`timeouts` struct<timeout:array<struct<type:string,expirytime:string,remainingtimeinseconds:int>>> COMMENT 'from deserializer',
`amrpcaddress` string COMMENT 'from deserializer',
`resourceinfo` struct<resourceusagesbypartition:array<struct<partitionname:string,used:struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>>,reserved:struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>>,pending:struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>>,amused:struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>>,amlimit:struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>>,useramlimit:struct<memory:int,vcores:int,resourceinformations:struct<resourceinformation:array<struct<attributes:string,maximumallocation:int,minimumallocation:int,name:string,resourcetype:string,units:string,value:int>>>>>>> COMMENT 'from deserializer')
PARTITIONED BY ( `cluster_id` string)
ROW FORMAT SERDE
'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
'paths'='allocatedMB,allocatedVCores,amContainerLogs,amHostHttpAddress,amNodeLabelExpression,amRPCAddress,applicationTags,applicationType,clusterId,clusterUsagePercentage,diagnostics,elapsedTime,finalStatus,finishedTime,id,launchTime,logAggregationStatus,masterNodeId,memorySeconds,name,numAMContainerPreempted,numNonAMContainerPreempted,preemptedMemorySeconds,preemptedResourceMB,preemptedResourceSecondsMap,preemptedResourceVCores,preemptedVcoreSeconds,priority,progress,queue,queueUsagePercentage,reservedMB,reservedVCores,resourceInfo,resourceSecondsMap,runningContainers,startedTime,state,timeouts,trackingUI,trackingUrl,unmanagedApplication,user,vcoreSeconds')
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
's3://<MY_REPORT_BUCKET>/emr_usage_report/application_usage/'
TBLPROPERTIES (
'classification'='json',
'compressionType'='none',
'typeOfData'='file')

-- Refresh the table to get updated partitions and data.  
MSCK REPAIR TABLE <EMR_USAGE_DATABASE>.application_usage
