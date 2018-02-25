#!/bin/bash
set -e

aws s3 sync s3://app-build-caches/Aika/Carthage/Build/iOS ./Carthage/Build/iOS/
