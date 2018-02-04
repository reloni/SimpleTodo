#!/bin/bash

set -e

#carthage update --no-build --no-use-binaries
mkdir -p Carthage/Build/iOS

#sh ./Scripts/BuildStaticFramework.sh RxSwift RxSwift RxSwift-iOS
#sh ./Scripts/BuildStaticFramework.sh RxSwift RxCocoa RxCocoa-iOS
#sh ./Scripts/BuildStaticFramework.sh SnapKit SnapKit SnapKit
#sh ./Scripts/BuildStaticFramework.sh SimpleKeychain SimpleKeychain SimpleKeychain-iOS

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxGesture/Carthage"
#sh ./Scripts/BuildStaticFramework.sh RxGesture/RxGesture RxGesture RxGesture-iOS

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxHttpClient/Carthage"
#sh ./Scripts/BuildStaticFramework.sh RxHttpClient RxHttpClient RxHttpClient

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxDataFlow/Carthage"
#sh ./Scripts/BuildStaticFramework.sh RxDataFlow RxDataFlow RxDataFlow-iOS

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/RxDataSources/Carthage"
#sh ./Scripts/BuildStaticFramework.sh RxDataSources Differentiator Differentiator
#sh ./Scripts/BuildStaticFramework.sh RxDataSources RxDataSources RxDataSources

#ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/realm-cocoa/Carthage"
#sh ./Scripts/BuildStaticFramework.sh realm-cocoa Realm "Realm iOS static" -static
#sh ./Scripts/BuildStaticFramework.sh realm-cocoa RealmSwift RealmSwift

#sh ./Scripts/BuildStaticFramework.sh OneSignal-iOS-SDK/iOS_SDK OneSignal OneSignal-Dynamic

#sh ./Scripts/BuildStaticFramework.sh Motion Motion "Motion iOS"

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/Material/Carthage"
#sh ./Scripts/BuildStaticFramework.sh Material Material "Material"

#sh ./Scripts/BuildStaticFramework.sh JWTDecode.swift JWTDecode "JWTDecode-iOS"

ln -sf "$(pwd)/Carthage/Build" "$(pwd)/Carthage/Checkouts/Auth0.swift/Carthage"
sh ./Scripts/BuildStaticFramework.sh Auth0.swift Auth0 "Auth0.iOS"
