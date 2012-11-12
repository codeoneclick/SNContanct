#!/bin/bash -x

/Applications/Xcode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --output-format human-readable-text --compile "$1" "$2" --sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk

