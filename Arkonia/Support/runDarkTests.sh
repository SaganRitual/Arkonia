#!/bin/sh

#  runDarkTests.sh
#  Arkonia
#
#  Created by Rob Bishop on 2/5/19.
#  Copyright © 2019 Rob Bishop. All rights reserved.
xcodebuild -quiet -project ../../Arkonia.xcodeproj -scheme DTGenome test
xcodebuild -quiet -project ../../Arkonia.xcodeproj -scheme DTNetMeat test
xcodebuild -quiet -project ../../Arkonia.xcodeproj -scheme DTSignalRelay test
