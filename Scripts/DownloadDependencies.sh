FIRFILENAME=firebase.zip
curl -o ./$FIRFILENAME https://dl.google.com/firebase/sdk/ios/3_17_0/Firebase-3.17.0.zip && unzip -o $FIRFILENAME -d Carthage && rm -rf $FIRFILENAME || return 1
