#!/bin/bash
#==============================================================================
#!# emr-install_reporter.sh - Install YARN metric reporter on an EMR cluster
#!#
#!#  version         1.1
#!#  author          ripani
#!#  license         MIT license
#!#
#==============================================================================
#?#
#?# usage: ./emr-install_reporter.sh <S3_PYTHON_SCRIPT> <S3_REPORT_BUCKET> 
#?#        ./emr-install_reporter.sh s3://BUCKET/emr_usage_reporter.py my_report_bucket_name
#?#
#?#  S3_PYTHON_SCRIPT         S3 path where the python script is located
#?#  S3_REPORT_BUCKET         S3 bucket name to store metric data
#?#
#==============================================================================

function usage() {
	[ "$*" ] && echo "$0: $*"
	sed -n '/^#?#/,/^$/s/^#?# \{0,1\}//p' "$0"
	exit 1
}

# make sure to run as root
if [ $(id -u) != "0" ]; then
	sudo "$0" "$@"
	exit $?
fi

[[ $# -ne 2 ]] && echo "error: missing parameters" && usage

# configurations
S3_PYTHON_SCRIPT="$1"
S3_REPORT_BUCKET="$2"

# requirements
pip3 install boto3
pip3 install requests

# setup
aws s3 cp $S3_PYTHON_SCRIPT /opt/emr_usage_reporter.py
(crontab -l 2>/dev/null; echo "*/1 * * * * /usr/bin/python3 /opt/emr_usage_reporter.py -b $S3_REPORT_BUCKET") | crontab -