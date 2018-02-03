eval SYMROOT="$(pwd)/Static"
#(cd ../Carthage/Checkouts/RxHttpClient && echo $SYMROOT)
(cd Carthage/Checkouts/RxHttpClient && xcodebuild -scheme "RxHttpClient" -project "RxHttpClient.xcodeproj" -sdk "iphoneos" -configuration Release MACH_O_TYPE=staticlib SYMROOT=$SYMROOT)
