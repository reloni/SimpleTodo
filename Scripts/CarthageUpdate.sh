# using manual update because carthage can't build frameworks in proper order
carthage update --no-build
carthage update RxSwift --cache-builds --platform iOS
carthage update SnapKit --cache-builds --platform iOS
carthage update Material --cache-builds --platform iOS
#carthage update RxHttpClient  --cache-builds --platform iOS
#carthage update RxDataFlow  --cache-builds --platform iOS
carthage update RxDataSources  --cache-builds --platform iOS
#carthage update Unbox  --cache-builds --platform iOS
#carthage update Wrap  --cache-builds --platform iOS
carthage update RxGesture  --cache-builds --platform iOS
#carthage update AMScrollingNavbar --cache-builds --platform iOS
carthage update OneSignal-iOS-SDK --cache-builds --platform iOS
carthage update Auth0.swift --cache-builds --platform iOS
carthage update JWTDecode.swift --cache-builds --platform iOS
carthage update realm-cocoa --cache-builds --platform iOS
