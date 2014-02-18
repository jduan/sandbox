#!/bin/bash

export AUTO_CI_FAIL_SLOW=1
export FILE_FLAKY_JIRAS=1

# TODO(jsirois): Consolidate these env vars: https://jira.twitter.biz/browse/AWESOME-5336
export CI_RUN=1
export SBT_CI=1
export MVN_CI=1

export LAST_GREEN=f40e0b5a62b78e1088302573e5fe534b81b5d396

./pants-support/jenkins/scripts/auto-ci-jvm.sh
