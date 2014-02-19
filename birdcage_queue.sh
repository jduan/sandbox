#!/bin/bash -x

export NUM_OF_SHARDS=6

function create_database() {
  envvar=$1
  prefix=$2

  dbname=$(echo "$prefix-$(uuidgen)" | tr '-' _)
  echo CREATE DATABASE IF NOT EXISTS $dbname | mysql -u root -S $MYSQL_UNIX_PORT
  trap "echo DROP DATABASE $dbname | mysql -u root -S $MYSQL_UNIX_PORT" EXIT

  export $envvar=$dbname
}

if [[ ${build:-0} == 'maven' ]]; then
  export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=256m"
  find ~/.m2 -name *SNAPSHOT -type d | xargs rm -rf
  list=$(/usr/local/bin/maven_helper --root-pom pom-ci.xml -d meta)
  /usr/local/bin/mvn -B -fae -f pom-ci.xml -T 8 -DMVN_CI=1 -DSBT_CI=1 -DSKIP_FLAKY=1 -Dmaven.test.failure.ignore=true $list install
else
  export CI_RUN=1
  export SBT_CI=1
  export HOME=$WORKSPACE
  export SUBMIT_QUEUE_MODE=1
  export AUTO_CI_FAIL_SLOW=1

  source /data/jenkins/bin/manage_mysql.sh clean

  /data/jenkins/bin/manage_mysql.sh start
  trap "/data/jenkins/bin/manage_mysql.sh stop" EXIT

  # querulous/querulous-core test support
  export DB_HOST="localhost:$MYSQL_TCP_PORT"
  create_database DB_NAME querulous

  ./pants-support/jenkins/scripts/auto-ci-jvm.sh
fi;

