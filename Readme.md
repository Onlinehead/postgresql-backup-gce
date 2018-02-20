## Why?
Sometimes you need to run cron for create a database dump.

Because I use a CloudSQL and a GKE, I want to get regular dumps of databases (which you can restore anywhere, not as 'gcloud sql export') for restore it to database servers for developers in other places, even out of GCE.

## How to build
Just run `docker build` as you usually do.
But you can `docker pull onlinehead/postgresql-backup-gce`.

## How to run

Run `docker run -i onlinehead/postgresql-backup-gce dump --help` for get help about how to create dumps and `docker run -i onlinehead/postgresql-backup-gce restore --help` for the same about restore. Configuration based on envrironment variables.


