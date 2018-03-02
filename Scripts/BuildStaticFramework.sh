#!/bin/bash

set -e

CARTHAGE_PATH="$1"
FRAMEWORK="$2"
FRAMEWORK_PATH="$2.framework"
SCHEME="$3"
MACH_O_TYPE="$4"
EXPORT_PATH_SUFFIX="$5"


eval SYMROOT="$(pwd)/Carthage/Build"

(cd Carthage/Checkouts/$CARTHAGE_PATH && xcodebuild -scheme "$SCHEME" -sdk "iphoneos" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=$MACH_O_TYPE SYMROOT="$SYMROOT/temp" BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" build)
(cd Carthage/Checkouts/$CARTHAGE_PATH && xcodebuild -scheme "$SCHEME" -sdk "iphonesimulator" -configuration Release ONLY_ACTIVE_ARCH=NO MACH_O_TYPE=$MACH_O_TYPE SYMROOT="$SYMROOT/temp" build)

cp -RL $SYMROOT/temp/Release-iphoneos$EXPORT_PATH_SUFFIX/ $SYMROOT/universal
if [ -d "$SYMROOT/temp/Release-iphonesimulator$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule" ]; then
  cp -RL $SYMROOT/temp/Release-iphonesimulator$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule/* $SYMROOT/universal/$FRAMEWORK_PATH/Modules/$FRAMEWORK.swiftmodule
fi

lipo -create $SYMROOT/temp/Release-iphoneos$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/$FRAMEWORK $SYMROOT/temp/Release-iphonesimulator$EXPORT_PATH_SUFFIX/$FRAMEWORK_PATH/$FRAMEWORK -output $SYMROOT/universal/$FRAMEWORK_PATH/$FRAMEWORK

rm -rf $SYMROOT/iOS/$FRAMEWORK_PATH
mv -f $SYMROOT/universal/$FRAMEWORK_PATH $SYMROOT/iOS/$FRAMEWORK_PATH
rm -rf $SYMROOT/temp
rm -rf $SYMROOT/universal

echo "complete build $FRAMEWORK"
