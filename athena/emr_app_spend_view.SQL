/* Run below statement in Athena Query Editor

Create Athena View with name, emr_app_spend_view that correlates YARN and CUR metrics to aggregate 
the cost usage details by cluster-id for the past 6 months and then calculates the cost usage of 
each application run based on its memorySeconds value. Modify the look back period as needed.

Replace <EMR_USAGE_DATABASE> with Glue database name of YARN metrics.
Replace <MY_CUR_DB> and <MY_CUR_TABLE> with your Glue database and table of Cost and Usage Report 
respectively.
*/
CREATE OR REPLACE VIEW emr_app_spend_view AS
SELECT
    cluster_id, id, user, name, queue, finalstatus, applicationtype, 
    date_trunc('second', cast(date_format(from_unixtime(startedtime/1000), '%Y-%m-%d %H:%i:%s') as timestamp)) AS startedtime,
    date_trunc('second', cast(date_format(from_unixtime(finishedtime/1000), '%Y-%m-%d %H:%i:%s') as timestamp)) AS finishedtime,
    cast(elapsedtime as double) / 1000 AS elapsed_sec, memoryseconds, vcoreseconds, total_memory_mb_avg, memory_sec_cost,
    memoryseconds * memory_sec_cost AS application_cost, total_cost  
FROM
    <EMR_USAGE_DATABASE>.application_usage
    JOIN (
        SELECT 
            emr_cluster, billing_start, total_memory_mb_avg, sum(cost) as total_cost, sum(cost) / (total_memory_mb_avg * minutes_collected * 60) AS memory_sec_cost
        FROM
        (
            SELECT 
                split_part(line_item_resource_id, '/', 2) AS emr_cluster, line_item_usage_start_date AS billing_start, 
                sum(line_item_unblended_cost) AS cost 
            FROM 
                <MY_CUR_DB>.<MY_CUR_TABLE>
            WHERE 
                product_product_name = 'Amazon Elastic MapReduce' 
                AND line_item_usage_start_date >= now() - interval '6' month
            GROUP BY 1,2
            UNION  
            SELECT 
                resource_tags_aws_elasticmapreduce_job_flow_id AS emr_cluster, line_item_usage_start_date AS billing_start,
                sum(line_item_unblended_cost) AS cost 
            FROM 
                <MY_CUR_DB>.<MY_CUR_TABLE>
            WHERE 
                product_product_name = 'Amazon Elastic Compute Cloud' 
                AND resource_tags_aws_elasticmapreduce_job_flow_id NOT IN ('null', 'applications') 
                AND resource_tags_aws_elasticmapreduce_job_flow_id <> '' 
                AND line_item_usage_start_date >= now() - interval '6' month
            GROUP BY 1,2
        ) as a
        JOIN 
        (
            SELECT 
                cluster_id,
                date_trunc('hour', cast(date_format(from_unixtime(timestamp/1000), '%Y-%m-%d %H:%i:%s') as timestamp)) as DATE_HOUR,
                avg(totalmb) AS total_memory_mb_avg,
                count(*) AS minutes_collected 
            FROM 
                <EMR_USAGE_DATABASE>.cluster_usage 
            WHERE
               cast(date_format(from_unixtime(timestamp/1000), '%Y-%m-%d %H:%i:%s') as timestamp) >= now() - interval '6' month
            GROUP BY 1,2
        ) as b
        ON
        a.emr_cluster = b.cluster_id
        AND date_trunc('hour',a.billing_start) = date_trunc('hour', b.DATE_HOUR)
        GROUP BY 1,2,3,minutes_collected
    )    
    ON
    cluster_id = emr_cluster
    AND date_trunc('hour', cast(date_format(from_unixtime(startedtime/1000), '%Y-%m-%d %H:%i:%s') as timestamp)) = billing_start
    ORDER BY
        billing_start desc
