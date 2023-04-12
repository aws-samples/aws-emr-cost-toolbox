import argparse
import boto3
import json
import requests
import socket

from io import StringIO
from time import time
from datetime import date


parser = argparse.ArgumentParser()
parser.add_argument("-b", "--bucket", type=str)

args = parser.parse_args()
bucket_name = args.bucket
bucket_prefix = 'emr_usage_report'

# Retrieve cluster id
with open('/emr/instance-controller/lib/info/job-flow.json', "rb") as f:
    json_data = json.load(f)
    cluster_id = json_data['jobFlowId']

# Clients
s3 = boto3.resource('s3')
session = requests.session()

# YARN RM accepts requests only on the FQDN
host_fqdn = socket.getfqdn()
rm_url = f'http://{host_fqdn}:8088'


# Current timestamp
timestamp = int(time() * 1000)
current_date = date.today()
year = current_date.year
month = current_date.month
day = current_date.day


def yarn_apps_metrics():
    url = f'{rm_url}/ws/v1/cluster/apps'
    response = session.get(url, timeout=5)
    data = json.loads(response.text)

    if data['apps']:
        file = StringIO()
        for entry in data['apps']['app']:
            json.dump(entry, file)
            file.write('\n')

        apps_object = s3.Object(
            bucket_name, f'{bucket_prefix}/application_usage/cluster_id={cluster_id}/application_metrics.json'
        )
        apps_object.put(Body=(bytes(file.getvalue().encode('UTF-8'))))
        file.close()


def yarn_cluster_metrics():
    url = f'{rm_url}/ws/v1/cluster/metrics'
    response = session.get(url, timeout=5)
    data = json.loads(response.text)['clusterMetrics']
    data['timestamp'] = timestamp

    cluster_object = s3.Object(
        bucket_name, f'{bucket_prefix}/cluster_usage/cluster_id={cluster_id}/year={year}/month={month}/day={day}/{timestamp}.json'
    )
    cluster_object.put(Body=(bytes(json.dumps(data).encode('UTF-8'))))


# Collect YARN metrics
yarn_apps_metrics()
yarn_cluster_metrics()
