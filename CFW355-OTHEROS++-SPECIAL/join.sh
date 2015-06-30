#!/bin/bash
# This file has been automatically generated. Please do not change any part of this file to ensure it is functioning correctly.

CHECKSUM=e46f9cdc9b471b7bca6ced201d6f49cb
echo "Joining files..."
rm "./CFW355-OTHEROS++-SPECIAL.PUP" 2> /dev/null
touch "./CFW355-OTHEROS++-SPECIAL.PUP"
cat GW2z4GdIarx3 >> "./CFW355-OTHEROS++-SPECIAL.PUP"
cat yyB4ipICGO4q >> "./CFW355-OTHEROS++-SPECIAL.PUP"
cat Pf4cPFKs9D2j >> "./CFW355-OTHEROS++-SPECIAL.PUP"
cat k96ao1Sn4Tuw >> "./CFW355-OTHEROS++-SPECIAL.PUP"
NEWCHKSUM="$(md5sum "CFW355-OTHEROS++-SPECIAL.PUP" | cut -d ' ' -f 1)"
if [ "x$CHECKSUM" = "x$NEWCHKSUM" ]; then
  echo "File integrity test: PASSED"
else
  echo "[31m"
  echo "File integrity test: FAILED"
  echo "Expected checksum: $CHECKSUM"
  echo "Got checksum: $NEWCHKSUM"
  echo "Please check if any files are corrupt or missing."
  echo "(B[m"
fi
echo Done!
