curl -o ./fabric.zip https://s3.amazonaws.com/kits-crashlytics-com/ios/com.twitter.crashlytics.ios/3.9.3/com.crashlytics.ios-manual.zip && unzip -o fabric.zip -d Carthage && rm -rf fabric.zip || return 1
curl -o ./answers.zip https://s3.amazonaws.com/kits-crashlytics-com/ios/com.twitter.answers.ios/1.3.6/com.twitter.answers.ios-manual.zip && unzip -o answers.zip -d Carthage && rm -rf answers.zip || return 1
