#!/bin/bash

export AUTO_CI_FAIL_SLOW=1
export FILE_FLAKY_JIRAS=1

# TODO(jsirois): Consolidate these env vars: https://jira.twitter.biz/browse/AWESOME-5336
export CI_RUN=1
export SBT_CI=1
export MVN_CI=1

# For details on the mysql control below see:
#  http://confluence.twitter.biz/display/APPSERVICES/MySQL+support+in+JVM-CI

source /data/jenkins/bin/manage_mysql.sh clean

/data/jenkins/bin/manage_mysql.sh start
trap "/data/jenkins/bin/manage_mysql.sh stop" EXIT

function create_database() {
  envvar=$1
  prefix=$2
  
  dbname=$(echo "$prefix-$(uuidgen)" | tr '-' _)
  echo CREATE DATABASE IF NOT EXISTS $dbname | mysql -u root -S $MYSQL_UNIX_PORT 
  trap "echo DROP DATABASE $dbname | mysql -u root -S $MYSQL_UNIX_PORT" EXIT

  export $envvar=$dbname
}

# querulous/querulous-core test support
export DB_HOST="localhost:$MYSQL_TCP_PORT"
create_database DB_NAME querulous
export LAST_GREEN=f40e0b5a62b78e1088302573e5fe534b81b5d396

./pants-support/jenkins/scripts/auto-ci-jvm.sh
