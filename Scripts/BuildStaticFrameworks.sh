eval SYMROOT="$(pwd)/Static"
(cd Carthage/Checkouts/RxHttpClient && xcodebuild -scheme "RxHttpClient" -project "RxHttpClient.xcodeproj" -sdk "iphoneos" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=staticlib SYMROOT="$SYMROOT/temp" clean build)
(cd Carthage/Checkouts/RxHttpClient && xcodebuild -scheme "RxHttpClient" -project "RxHttpClient.xcodeproj" -sdk "iphonesimulator" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=staticlib SYMROOT="$SYMROOT/temp" clean build)
lipo -create -output "$SYMROOT/RxHttpClient.framework" "$SYMROOT/temp/Release-iphoneos/RxHttpClient.framework/RxHttpClient" "$SYMROOT/temp/Release-iphonesimulator/RxHttpClient.framework/RxHttpClient"
