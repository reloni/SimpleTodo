#!/bin/bash

set -e

carthage update RxSwift --cache-builds --platform iOS
carthage update --cache-builds --platform ios

sh ./Scripts/DownloadFabric.sh
