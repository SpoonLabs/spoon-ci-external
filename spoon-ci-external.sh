#!/bin/bash
# additional CI jobs for Spoon

set -e

if [[ "$TRAVIS_REPO_SLUG" == "SpoonLabs/spoon-ci-external" ]] 
then
  ./push-master-to-spoon-ci-external.sh
  ./push-branch-to-spoon-ci-external.sh
fi

