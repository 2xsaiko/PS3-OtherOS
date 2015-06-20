#!/bin/bash

rm CFW355-OTHEROS++-SPECIAL.PUP
echo Joining files...
touch CFW355-OTHEROS++-SPECIAL.PUP
cat CFW355-OTHEROS++-SPECIAL.PUP.split.0 >> CFW355-OTHEROS++-SPECIAL.PUP
cat CFW355-OTHEROS++-SPECIAL.PUP.split.1 >> CFW355-OTHEROS++-SPECIAL.PUP
cat CFW355-OTHEROS++-SPECIAL.PUP.split.2 >> CFW355-OTHEROS++-SPECIAL.PUP
cat CFW355-OTHEROS++-SPECIAL.PUP.split.3 >> CFW355-OTHEROS++-SPECIAL.PUP
echo "Done. Checking checksum (rofl)"
if [ "$(cat CFW355-OTHEROS++-SPECIAL.PUP.md5)" = "$(md5sum CFW355-OTHEROS++-SPECIAL.PUP)" ]; then
  echo "Joined files successfully. Enjoy your CFW355-OTHEROS++-SPECIAL.PUP!"
else
  echo "Files not joined correctly: Expected MD5:"
  cat CFW355-OTHEROS++-SPECIAL.PUP.md5
  echo "Got:"
  md5sum CFW355-OTHEROS++-SPECIAL.PUP
fi
