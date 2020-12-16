#!/bin/bash
set -e

export UPLOADPATH=$PWD/Carthage/Build/iOS/Upload
mkdir -p $UPLOADPATH

(cd Carthage/Build/iOS/ && for i in `find . -maxdepth 1 | grep -E ".framework$"`; do tar -zvc -f "$UPLOADPATH/$i.tar.gz" "$i" ; done)
aws s3 sync $UPLOADPATH s3://app-build-caches/Aika/Carthage/Build/iOS --delete

rm -rf $UPLOADPATH
