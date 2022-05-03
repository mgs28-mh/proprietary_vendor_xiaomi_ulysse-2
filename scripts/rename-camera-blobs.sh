#!/bin/bash -e

GIT_MV=""
PREFIX="$1"

if [ ! -d "bin" ] && [ ! -d "lib" ]; then
	echo "Please enter vendor/MANUFACTURER/DEVICE/proprietary/vendor first"
	exit 1
fi

if [ "$(echo -n $PREFIX | wc -m)" != "1" ]; then
    echo "Invalid prefix"
    exit 1
fi

if [ "$GIT_MV" ]; then
	MV="git mv"
else
	MV="mv"
fi

set -x

cd bin
sed -i "s|libmmcamera_|lib${PREFIX}mcamera_|g" *
sed -i "s|libmmcamera2_|lib${PREFIX}mcamera2_|g" *
if [ "$GIT_MV" ]; then
    git add .
fi
cd ..

if [ -d "etc/camera" ]; then
cd etc
${MV} camera ${PREFIX}amera
cd ..
fi

cd lib
# Common blobs
sed -i "s|libactuator_|lib${PREFIX}ctuator_|g" libmmcamera2_sensor_modules.so
sed -i "s|libchromatix_|lib${PREFIX}hromatix_|g" libmmcamera2_sensor_modules.so
sed -i "s|libflash_|lib${PREFIX}lash_|g" libmmcamera2_sensor_modules.so
sed -i "s|etc/camera|etc/${PREFIX}amera|g" libmmcamera2_sensor_modules.so
sed -i "s|libmmcamera_|lib${PREFIX}mcamera_|g" *.so
sed -i "s|libmmcamera2_|lib${PREFIX}mcamera2_|g" *.so
# Misc blobs
for blob in `ls *.so|grep -vE "libactuator_|libchromatix_|libmmcamera_|libmmcamera2_"`; do
	NEW_NAME=$(echo ${blob}|sed "s|.|${PREFIX}|4")
	sed -i "s|${blob}|${NEW_NAME}|g" $(ls *.so|grep -vE "libactuator_|libchromatix_")
done

if [ "$GIT_MV" ]; then
    git add .
fi

for blob in `ls *.so`; do
	${MV} ${blob} $(echo ${blob}|sed "s|.|${PREFIX}|4")
done
cd ..
