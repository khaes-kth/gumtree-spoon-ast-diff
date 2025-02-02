#!/bin/bash
#
# Deploy a jar, source jar, and javadoc jar to Sonatype Maven Central repo.
#
# Inspired from https://github.com/square/retrofit/blob/fccedbeb4d5181c926fff450cdf5c5116ef0eeaa/.buildscript/deploy_snapshot.sh

SLUG="SpoonLabs/gumtree-spoon-ast-diff"
JDK="oraclejdk8"
BRANCH="master"

set -e

if [ "$TRAVIS_REPO_SLUG" != "$SLUG" ]; then
  echo "Skipping deployment: wrong repository. Expected '$SLUG' but was '$TRAVIS_REPO_SLUG'."
elif [ "$TRAVIS_JDK_VERSION" != "$JDK" ]; then
  echo "Skipping deployment: wrong JDK. Expected '$JDK' but was '$TRAVIS_JDK_VERSION'."
elif [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skipping deployment: was pull request."
elif [ "$TRAVIS_BRANCH" != "$BRANCH" ]; then
  echo "Skipping deployment: wrong branch. Expected '$BRANCH' but was '$TRAVIS_BRANCH'."
else
  echo "Deploying ..."
  # made with "travis encrypt-file codesigning.asc -r SpoonLabs/gumtree-spoon-ast-diff --add"
  openssl aes-256-cbc -K $encrypted_9809c3ea697e_key -iv $encrypted_9809c3ea697e_iv -in .buildscript/codesigning.asc.enc -out codesigning.asc -d
  gpg --fast-import codesigning.asc

  # getting the previous version on Maven Central
  PREVIOUS_MAVEN_CENTRAL_VERSION=`curl "http://search.maven.org/solrsearch/select?q=a:gumtree-spoon-ast-diff+g:fr.inria.gforge.spoon.labs&rows=20&wt=json" | jq -r .response.docs[0].latestVersion | egrep -o "[0-9]+$"`

  # and incrementing it
  mvn versions:set -DnewVersion=1.$((PREVIOUS_MAVEN_CENTRAL_VERSION+1))

  mvn -Prelease deploy --settings .buildscript/settings.xml -Dmaven.test.skip=true
  echo "Well deployed!"
fi
