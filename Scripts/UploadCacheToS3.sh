#!/bin/bash
set -e

aws s3 sync ./Carthage/Build/iOS/ s3://app-build-caches/Aika/Carthage/Build/iOS
