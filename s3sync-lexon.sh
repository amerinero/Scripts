#!/bin/bash
REPOSITORY=/data/webs/lexon/public_html/repository/documents
S3BUCKET=s3://lexon-pre-repository
LOGFILE=lexon-sync-aws.log

cd ${REPOSITORY}
DATADIRS=`find . -maxdepth 1 -type d -printf "%f \n" | grep -v "^\..$"`

for FOLDER in ${DATADIRS}
do
	echo "${FOLDER} ---> ${S3BUCKET}/${FOLDER}"
	aws s3 sync ${FOLDER} ${S3BUCKET}/${FOLDER} --delete --only-show-errors
done