#!/bin/bash
# push surefire-reports to https://github.com/SpoonLabs/spoon-ci-data/
# push spoon-public-methods.txt and spoon-public-classes.txt to https://github.com/SpoonLabs/spoon-ci-data/

set -e

echo starting $0

git config --global user.name "spoon-bot"
git clone --single-branch --branch master https://github.com/INRIA/spoon.git
cd spoon

COMMIT=`git log --format="%H" -n 1`
cd ..
git clone https://github.com/SpoonLabs/spoon-ci-data.git
cd spoon-ci-data

# if there is already one commit we do not do anything
if git log --oneline | grep $COMMIT ;
then
  echo already processed $COMMIT, there is a branch for it
  exit
fi

# otherwise we proceed
cd ../spoon
cp ./chore/logback.xml src/main/java
mvn -q package # create jar and run tests
groovy -cp target/spoon-core-*-jar-with-dependencies.jar ../list-public-methods.groovy > spoon-public-methods.txt
groovy -cp target/spoon-core-*-jar-with-dependencies.jar ../list-public-classes.groovy > spoon-public-classes.txt

# now we push the new data
cd ../spoon-ci-data
git remote rm origin
git remote add origin https://spoon-bot:$GITHUB_TOKEN@github.com/SpoonLabs/spoon-ci-data.git
cp -r ../spoon/target/surefire-reports/ .
git add surefire-reports/*.xml
cp ../spoon/spoon-public-methods.txt .
cp ../spoon/spoon-public-classes.txt .
git commit -m $COMMIT --allow-empty -a
git push origin master
