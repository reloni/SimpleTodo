# using manual update because carthage can't build frameworks in proper order
carthage checkout
carthage update RxSwift --platform iOS
carthage update SnapKit --platform iOS
carthage update Material --platform iOS
carthage update RxState --platform iOS
carthage update RxHttpClient --platform iOS
carthage update OHHTTPStubs --platform iOS
