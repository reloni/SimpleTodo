#!/bin/bash

set -e

CARTHAGE_PATH="$1"
FRAMEWORK="$2"
FRAMEWORK_PATH="$2.framework"
SCHEME="$3"
EXPORT_PATH_SUFFIX="$4"

eval SYMROOT="$(pwd)/Carthage/Build"

MACH_O_TYPE=staticlib
(cd Carthage/Checkouts/$CARTHAGE_PATH && xcodebuild -scheme "$SCHEME" -sdk "iphoneos" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=$MACH_O_TYPE SYMROOT="$SYMROOT/temp" build)
(cd Carthage/Checkouts/$CARTHAGE_PATH && xcodebuild -scheme "$SCHEME" -sdk "iphonesimulator" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=$MACH_O_TYPE SYMROOT="$SYMROOT/temp" build)

cp -RL $SYMROOT/temp/Release-iphoneos$EXPORT_PATH_SUFFIX/ $SYMROOT/iOS
if [ -d "$SYMROOT/temp/Release-iphonesimulator$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule" ]; then
cp -RL $SYMROOT/temp/Release-iphonesimulator$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule/* $SYMROOT/iOS/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule
fi
#cp -RL $SYMROOT/temp/Release-iphonesimulator/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule/* $SYMROOT/iOS/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule
lipo -create $SYMROOT/temp/Release-iphoneos$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/$FRAMEWORK $SYMROOT/temp/Release-iphonesimulator$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/$FRAMEWORK -output $SYMROOT/iOS/$FRAMEWORK_PATH/$FRAMEWORK
#cp -rf $SYMROOT/universal/$FRAMEWORK_PATH $SYMROOT
rm -rf $SYMROOT/temp
#rm -rf $SYMROOT/universal

echo "complete build $FRAMEWORK"
