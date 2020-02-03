#!/bin/sh

#  Script.sh
#  YSRoomSDK
#
#  Created by 云枢科技 on 2019/10/16.
#  Copyright © 2019 MAC-MiNi. All rights reserved.

#  YSWhiteBoardSDK
cp -Rf /Users/yunshukeji/Library/Developer/Xcode/DerivedData/EduClass-hgsiwjqbdlycqbbxdlgeozcuqomp/Build/Products/Release-iphoneos/YSWhiteBoard.framework "/Users/yunshukeji/Documents/Release/ys/YSWiteBoardSDK/iphoneos/"

cp -Rf /Users/yunshukeji/Library/Developer/Xcode/DerivedData/EduClass-hgsiwjqbdlycqbbxdlgeozcuqomp/Build/Products/Release-iphoneos/YSWhiteBoard.framework "/Users/yunshukeji/Documents/Release/ys/YSWiteBoardSDK/iphoneos+iphonesimulator/"

lipo -create /Users/yunshukeji/Library/Developer/Xcode/DerivedData/EduClass-hgsiwjqbdlycqbbxdlgeozcuqomp/Build/Products/Release-iphoneos/YSWhiteBoard.framework/YSWhiteBoard /Users/yunshukeji/Library/Developer/Xcode/DerivedData/EduClass-hgsiwjqbdlycqbbxdlgeozcuqomp/Build/Products/Release-iphonesimulator/YSWhiteBoard.framework/YSWhiteBoard -output "/Users/yunshukeji/Documents/Release/ys/YSWiteBoardSDK/iphoneos+iphonesimulator/YSWhiteBoard.framework/YSWhiteBoard"
