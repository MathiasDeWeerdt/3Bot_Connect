# !bin/bash
shouldBuild=false

if [ $1 == "--run" ]
then
    shouldBuild=true
fi

if [ $1 == "--build" ]
then
    shouldBuild=false
fi

if [ $2 == "--local" ]
then
    if grep -q "org.jimber.threebotlogin.staging" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/google-services.json
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_staging"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml   
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if ! grep -q "org.jimber.threebotlogin.local" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/google-services.json
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot"/android:label="3bot_local"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.local/g' ios/Runner/Info.plist
    fi

    if [ $shouldBuild == true ]
    then
        flutter run -t lib/main_local.dart
    else
        flutter build apk -t lib/main_local.dart
    fi
fi

if [ $2 == "--staging" ]
then
    if grep -q "org.jimber.threebotlogin.local" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/google-services.json
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_local"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if ! grep -q "org.jimber.threebotlogin.staging" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/google-services.json
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot"/android:label="3bot_staging"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin/org.jimber.threebotlogin.staging/g' ios/Runner/Info.plist
    fi

    if [ $shouldBuild == true ]
    then
        flutter run -t lib/main_staging.dart
    else
        flutter build apk -t lib/main_staging.dart
    fi
fi

if [ $2 == "--production" ]
then
    if grep -q "org.jimber.threebotlogin.local" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/google-services.json
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_local"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.local/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if grep -q "org.jimber.threebotlogin.staging" "android/app/build.gradle";
    then
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/build.gradle
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/google-services.json
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/debug/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/android:label="3bot_staging"/android:label="3bot"/g' android/app/src/main/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/profile/AndroidManifest.xml
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' android/app/src/main/java/org/jimber/threebotlogin/MainActivity.java
        sed -i -e 's/org.jimber.threebotlogin.staging/org.jimber.threebotlogin/g' ios/Runner/Info.plist
    fi

    if [ $shouldBuild == true ]
    then
        flutter run -t lib/main_prod.dart
    else
        flutter build apk -t lib/main_prod.dart
    fi
fi