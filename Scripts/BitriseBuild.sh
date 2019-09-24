#!/bin/bash
set -ex

brew install awscli
aws --version

sh Scripts/DownloadCacheFromS3.sh
