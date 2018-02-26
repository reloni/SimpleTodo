#!/bin/bash
set -e

aws s3 sync s3://app-build-caches/Aika/Carthage/Build/iOS ./Carthage/Build/iOS/

#(cd Carthage/Build/iOS/ && for i in `find . | grep -E ".framework.tar.gz$"`; do tar -xzf "$i" ; done)
