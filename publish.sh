#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage ./publish. <version>"
    exit 1
fi

if [ ! -f ./VERSION ]
then
    echo "Wrong folder!!"
    exit 1
fi

VERSION=$1

echo "$1" > VERSION

git add VERSION
git commit -m "Bump version to $VERSION"
git push

git tag -a "$VERSION" -m "$VERSION"

git push origin "$VERSION"