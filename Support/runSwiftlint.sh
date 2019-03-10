#!/bin/sh

#  runSwiftlint.sh
#  Arkonia
#
#  Created by Rob Bishop on 2/5/19.
#  Copyright © 2019 Rob Bishop. All rights reserved.
set -e

if ! which swiftlint > /dev/null; then
echo "error: SwiftLint is not installed. Vistit http://github.com/realm/SwiftLint to learn more."
exit 1
fi

swiftlint
