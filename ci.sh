PRODUCT_NAME="SwiftSyncPreviewer"
VERSION="0.0.1"

rm -rf "build"
# pushd "$PRODUCT_NAME"
xcodebuild archive -scheme "$PRODUCT_NAME" -archivePath "build/$PRODUCT_NAME.xcarchive" "BUNDLE_VERSION=$VERSION"
xcodebuild -exportArchive -exportOptionsPlist "$PRODUCT_NAME/export-options.plist" -archivePath "build/$PRODUCT_NAME.xcarchive" -exportPath "build/$PRODUCT_NAME"
# popd