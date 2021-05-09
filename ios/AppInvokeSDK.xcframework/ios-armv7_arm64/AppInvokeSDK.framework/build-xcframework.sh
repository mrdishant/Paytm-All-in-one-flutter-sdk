FRAMEWORK_APP_PATH="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
# 1. Copying FRAMEWORK to FRAMEWORK_APP_PATH
find "$SRCROOT" -name '*.framework' -type d | while read -r FRAMEWORK
do
if [[ $FRAMEWORK == *"FAT_FRAMEWORK.framework" ]]
then
    echo "Copying $FRAMEWORK into $FRAMEWORK_APP_PATH"
    cp -r $FRAMEWORK "$FRAMEWORK_APP_PATH"
fi
done
# 2. Loops through the frameworks embedded in the application and removes unused architectures.
find "$FRAMEWORK_APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
if [[ $FRAMEWORK == *"FAT_FRAMEWORK.framework" ]]
then
     
    echo "Strip framework: $FRAMEWORK"
    FRAMEWORK_EXECUTABLE_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "$FRAMEWORK/Info.plist")
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
    echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"
    EXTRACTED_ARCHS=()
    for ARCH in $ARCHS
    do
    echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
    lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
    EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done
    echo "Merging extracted architectures: ${ARCHS}"
    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"
    echo "Replacing original executable with thinned version"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
    codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS:-} --preserve-metadata=identifier,entitlements $FRAMEWORK_EXECUTABLE_PATH
else
    echo "Ignored strip on: $FRAMEWORK"
fi
done
