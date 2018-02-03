eval SYMROOT="$(pwd)/Static"
#MACH_O_TYPE=mh_dylib
MACH_O_TYPE=staticlib
FRAMEWORK_PATH=RxHttpClient.framework
FRAMEWORK=RxHttpClient
(cd Carthage/Checkouts/RxHttpClient && xcodebuild -scheme "RxHttpClient" -project "RxHttpClient.xcodeproj" -sdk "iphoneos" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=$MACH_O_TYPE SYMROOT="$SYMROOT/temp" clean build)
(cd Carthage/Checkouts/RxHttpClient && xcodebuild -scheme "RxHttpClient" -project "RxHttpClient.xcodeproj" -sdk "iphonesimulator" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=$MACH_O_TYPE SYMROOT="$SYMROOT/temp" clean build)
#file "$SYMROOT/temp/Release-iphoneos/RxHttpClient.framework/RxHttpClient"
#file "$SYMROOT/temp/Release-iphonesimulator/RxHttpClient.framework/RxHttpClient"
#cp -R "$SYMROOT/Release-iphoneos/RxHttpClient.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

cp -RL $SYMROOT/temp/Release-iphoneos $SYMROOT/Release-universal
cp -RL $SYMROOT/temp/Release-iphonesimulator/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule/* $SYMROOT/Release-universal/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule
lipo -create $SYMROOT/temp/Release-iphoneos/$FRAMEWORK_PATH/$FRAMEWORK $SYMROOT/temp/Release-iphonesimulator/$FRAMEWORK_PATH/$FRAMEWORK -output $SYMROOT/Release-universal/$FRAMEWORK_PATH/$FRAMEWORK


#lipo -create -output "$SYMROOT/RxHttpClient.framework/RxHttpClient" "$SYMROOT/temp/Release-iphoneos/RxHttpClient.framework/RxHttpClient" "$SYMROOT/temp/Release-iphonesimulator/RxHttpClient.framework/RxHttpClient"
