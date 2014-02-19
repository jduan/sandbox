#!/bin/bash -x

export NUM_OF_SHARDS=6

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

  ./pants-support/jenkins/scripts/auto-ci-jvm.sh
fi;
