#!/bin/bash
# Script for dump PostgreSQL database and uploading it to Google Cloud Storage
# Maintainer: Anton Kostenko <anton@kostenko.me>
set -e

function show_help
{
echo '''
List and description of environment variables need to set:

PGPASSWORD - password for access a database
PGUSER - PostgreSQL user
PGHOST - PostgreSQL server address
BUCKET - Google Storage bucket for store backups
PGDATABASE - database for backup

Optional:
UPDATE_LATEST - if set then script will also update file 'latest.dump' to current backup.
PGPORT - PostgreSQL port
PREFIX - Custom prefix in dump name

Example of backup filename - $PREFIX-my_database_1-20180220191154.dump.gz'''
}

# Show help if need
if [[ $1 = "help" ]] || [[ $1 = "--help" ]] || [[ $1 = "-h" ]]; then
        echo '''
For run script, you need to mount json key file with credentials for your service account to /credentials.json'''
        show_help
        exit 0
fi

if [ -z ${PGPASSWORD+x} ] || [ -z ${PGUSER+x} ] || [ -z ${PGHOST+x} ] || [ -z ${BUCKET} ] || [ -z ${PGDATABASE} ]; then
	show_help
	exit 1
fi

# Basic validation of credentials
if [ -d /credentials.json ]; then
        echo "Credentials not mount. Run with --help to read how to use."
        exit 1
fi

# Login to GCE
if ! gcloud auth activate-service-account --key-file /credentials.json; then
	exit 1
fi

# Set dump name
if [ ! -z ${PREFIX+x} ]; then
	DUMP_NAME=$(printf "%s-%s-%s.dump.gz" "$PREFIX" "$PGDATABASE" "$(date '+%Y%m%d%H%M%S')")
else
	DUMP_NAME=$(printf "%s-%s.dump.gz" "$PGDATABASE" "$(date '+%Y%m%d%H%M%S')")
fi

# Set port
if [ -z ${PGPORT+x} ]; then
	PGPORT=5432
fi

echo "Dump database $PGDATABASE to $DUMP_NAME"

# Dumping database
pg_dump -U $PGUSER -h $PGHOST -p $PGPORT --no-owner $PGDATABASE | gzip > $DUMP_NAME

# Uploading dump
gsutil cp $DUMP_NAME gs://$BUCKET/$DUMP_NAME

if [ ! -z ${UPDATE_LATEST+x} ]; then
	echo "Updating latest dump to current one"
	gsutil cp gs://$BUCKET/$DUMP_NAME gs://$BUCKET/latest.dump.gz
fi

