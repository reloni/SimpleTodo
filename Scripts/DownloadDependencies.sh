FIRFILENAME=firebase.zip
curl -o ./$FIRFILENAME https://dl.google.com/firebase/sdk/ios/3_16_0/Firebase-3.16.0.zip && unzip -o $FIRFILENAME -d Carthage && rm -rf $FIRFILENAME || return 1
