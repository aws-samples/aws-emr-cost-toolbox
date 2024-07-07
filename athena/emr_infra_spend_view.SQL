/* Run below statement in Athena Query Editor

Creates Athena View with name, emr_infra_spend_view that correlates and aggregates the cost usage 
details by cluster-id and usage type for the past 6 months. Modify the look back period as needed. 
This view is useful to show cost usage breakdown of the cluster related to AWS resource usage 
types such as EC2 instance types, On-Demand or Spot, EBS volume types and Data Transfer. 

Replace <MY_CUR_DB> and <MY_CUR_TABLE> with your Glue database and table of Cost and Usage Report 
respectively.
*/
CREATE OR REPLACE VIEW emr_infra_spend_view AS
SELECT
  split_part(line_item_resource_id, '/', 2) AS cluster_id, product_product_family AS family,
  line_item_usage_start_date AS billing_start, line_item_usage_type AS usage_type,
  sum(line_item_unblended_cost) as cost
FROM
  <MY_CUR_DB>.<MY_CUR_TABLE>
WHERE
  product_product_name = 'Amazon Elastic MapReduce' 
  AND split_part(line_item_resource_id, '/', 2) != 'applications' 
  AND line_item_usage_start_date >= now() - interval '6' month
GROUP BY 1,2,3,4
UNION
SELECT
  resource_tags_aws_elasticmapreduce_job_flow_id AS cluster_id, product_product_family AS family,
  line_item_usage_start_date AS billing_start, line_item_usage_type AS usage_type,
  sum(line_item_unblended_cost) as cost
FROM
  <MY_CUR_DB>.<MY_CUR_TABLE>
WHERE
  product_product_name = 'Amazon Elastic Compute Cloud'
  AND resource_tags_aws_elasticmapreduce_job_flow_id NOT IN ('null', 'applications')
  AND resource_tags_aws_elasticmapreduce_job_flow_id <> ''
  AND line_item_usage_start_date >= now() - interval '6' month
GROUP BY 1,2,3,4
