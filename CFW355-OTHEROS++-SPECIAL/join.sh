#!/bin/bash
# This file has been automatically generated. Please do not change any part of this file to ensure it is functioning correctly.
CHECKSUM=e46f9cdc9b471b7bca6ced201d6f49cb
echo "Joining files..."
rm "./CFW355-OTHEROS++-SPECIAL.PUP" 2> /dev/null
touch "./CFW355-OTHEROS++-SPECIAL.PUP"
cat 7sguaZqKC5QA >> "./CFW355-OTHEROS++-SPECIAL.PUP"
cat Nrcri5QqtkoU >> "./CFW355-OTHEROS++-SPECIAL.PUP"
cat xZL6vxdVm6Wr >> "./CFW355-OTHEROS++-SPECIAL.PUP"
cat d6o16QOCdW9a >> "./CFW355-OTHEROS++-SPECIAL.PUP"
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
