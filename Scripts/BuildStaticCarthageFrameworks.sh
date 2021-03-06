#!/bin/bash

set -e

carthage update --no-build --no-use-binaries
mkdir -p Carthage/Build/iOS

sh ./Scripts/BuildStaticFramework.sh RxSwift RxSwift RxSwift-iOS mh_dylib
sh ./Scripts/BuildStaticFramework.sh RxSwift RxRelay RxRelay mh_dylib
sh ./Scripts/BuildStaticFramework.sh RxSwift RxCocoa RxCocoa-iOS mh_dylib

sh ./Scripts/BuildStaticFramework.sh SnapKit SnapKit SnapKit staticlib
sh ./Scripts/BuildStaticFramework.sh SimpleKeychain SimpleKeychain SimpleKeychain-iOS staticlib

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxGesture/Carthage"
sh ./Scripts/BuildStaticFramework.sh RxGesture/RxGesture RxGesture RxGesture-iOS staticlib

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxHttpClient/Carthage"
sh ./Scripts/BuildStaticFramework.sh RxHttpClient RxHttpClient RxHttpClient staticlib

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxDataFlow/Carthage"
sh ./Scripts/BuildStaticFramework.sh RxDataFlow RxDataFlow RxDataFlow-iOS staticlib

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxDataSources/Carthage"
sh ./Scripts/BuildStaticFramework.sh RxDataSources Differentiator Differentiator staticlib
sh ./Scripts/BuildStaticFramework.sh RxDataSources RxDataSources RxDataSources staticlib

sh ./Scripts/BuildStaticFramework.sh JWTDecode.swift JWTDecode "JWTDecode-iOS" staticlib

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/Auth0.swift/Carthage"
sh ./Scripts/BuildStaticFramework.sh Auth0.swift Auth0 "Auth0.iOS" staticlib

# build dynamic frameworks
carthage update realm-cocoa --platform ios --cache-builds
sh ./Scripts/BuildStaticFramework.sh OneSignal-iOS-SDK/iOS_SDK OneSignal OneSignalFramework mh_dylib

#ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/realm-cocoa/Carthage"
#sh ./Scripts/BuildStaticFramework.sh realm-cocoa Realm "Realm iOS static" staticlib -static
#sh ./Scripts/BuildStaticFramework.sh realm-cocoa RealmSwift RealmSwift mh_dylib
