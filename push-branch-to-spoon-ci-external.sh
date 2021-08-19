#!/bin/bash
# push surefire-reports and spoon-public-methods.txt and spoon-public-classes.txt 
# on a separate branch on https://github.com/SpoonLabs/spoon-ci-data/

set -e

git config --global user.name "spoon-bot"
rm -rf spoon
git clone https://github.com/INRIA/spoon.git
cd spoon
cp ./chore/logback.xml src/main/java

# preparing the data repo
git clone --single-branch --branch empty https://github.com/SpoonLabs/spoon-ci-data.git
cd spoon-ci-data
git remote rm origin
git remote add origin https://spoon-bot:$GITHUB_TOKEN@github.com/SpoonLabs/spoon-ci-data.git
cd ..

# push the last n commits
for COMMIT in `git log --format="%H" -n 4`
do
    cd spoon-ci-data
    # branches already pushed
    if git ls-remote --exit-code --heads origin branch-$COMMIT; then cd ..; continue; fi
    cd ..

    mvn clean package # create jar and put test results in target/surefire-reports
    groovy -cp target/spoon-core-*-jar-with-dependencies.jar ../list-public-methods.groovy > spoon-public-methods.txt
    groovy -cp target/spoon-core-*-jar-with-dependencies.jar ../list-public-classes.groovy > spoon-public-classes.txt

    cd spoon-ci-data

    # branches already pushed
    if git ls-remote --exit-code --heads origin branch-$COMMIT; then cd ..; continue; fi

    # creating a specific branch for this commit from the empty branch
#     git checkout empty # we start from the empty branch
#     git checkout -b branch-$COMMIT
    git checkout --orphan branch-$COMMIT

    cp -r ../target/surefire-reports/ .
    git add surefire-reports/*.xml

    # save the Jacoco data
    cp -r ../target/jacoco.exec / .
    git add jacoco.exec

    # list API elements
    cp ../spoon-public-methods.txt .
    cp ../spoon-public-classes.txt .
    git add spoon-public-*.txt
    git commit -m $COMMIT -a

    # final push
    git push origin branch-$COMMIT:branch-$COMMIT

    # going back into the spoon repo
    cd ..
done
