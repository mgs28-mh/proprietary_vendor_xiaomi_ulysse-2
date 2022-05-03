#!/bin/bash -xe
MY_PATH=$(dirname $(realpath "$0"))
cd $MY_PATH

SRC="$1"
if [ ! -d "$SRC" ]; then
    echo "Specify path to vendor/xiaomi in 1st argument!"
    exit
fi

# Camera
#if false; then
cd camera
for d in `ls`; do
    cd $d # go to /camera/device/
    PREFIX="$(cat prefix.txt)"
    if [ -d vendor ]; then rm -rf vendor ; fi
    mkdir -p vendor/{bin,lib,etc/camera}
    if [ -f "dir.txt" ]; then DIR="$(cat dir.txt)"; else DIR="$d"; fi
    for f in `cat list.txt`; do
        cp $SRC/$DIR/proprietary/$f $f
    done
    cd vendor # go to /camera/device/vendor/
    $MY_PATH/scripts/rename-camera-blobs.sh $PREFIX
    cd bin
    mv mm-qcamera-daemon ${DIR}_mm-qcamera-daemon
    cd ..
    cd .. # back to /camera/device/
    cd .. # back to /camera/
done
cd .. # back to /
#fi

# Fingerprint
#if false; then
cd fingerprint
for d in `ls`; do
    cd $d # go to /fingerprint/device/
    PREFIX="$(cat prefix.txt)"
    if [ -d vendor ]; then rm -rf vendor ; fi
    mkdir -p vendor/{bin,lib64/hw}
    for f in `cat list.txt`; do
        cp $SRC/$d/proprietary/$f $f
    done
    cd vendor # go to /fingerprint/device/vendor/
    NUM_FILES=`find . -type f|wc -l`
    COUNT=0
    for f in `find . -type f`; do
        eval FILE_${COUNT}_NAME=`filename $f`
        eval FILE_${COUNT}_PATH=$f
        let COUNT+=1
    done
    if [ -d tmp ]; then rm -rf tmp ; fi
    mkdir tmp
    cd tmp # go to /fingerprint/device/vendor/tmp/
    # move files to tmp
    COUNT=0
    until [ $COUNT -eq $NUM_FILES ]; do
        eval mv ../\$FILE_${COUNT}_PATH \$FILE_${COUNT}_NAME
        let COUNT+=1
    done
    # do rename
    $MY_PATH/scripts/rename-blobs.sh $PREFIX
    # get new filenames
    COUNT=0
    until [ $COUNT -eq $NUM_FILES ]; do
        if eval echo -n \$FILE_${COUNT}_NAME|grep -E '^lib' > /dev/null; then # if it's a lib
            NEW_NAME=$(eval echo -n \$FILE_${COUNT}_NAME|sed "s|.|${PREFIX}|4")
            eval FILE_${COUNT}_NAME="$NEW_NAME"
            NEW_PATH="$(eval dirname \$FILE_${COUNT}_PATH)/$NEW_NAME"
            eval FILE_${COUNT}_PATH=$NEW_PATH
        fi
        let COUNT+=1
    done
    # move files back
    COUNT=0
    until [ $COUNT -eq $NUM_FILES ]; do
        eval mv \$FILE_${COUNT}_NAME ../\$FILE_${COUNT}_PATH
        let COUNT+=1
    done
    cd .. # back to /fingerprint/device/vendor/
    rm -rf tmp
    cd bin
    mv gx_fpd ${d}_gx_fpd
    if [ -f "gx_fpcmd" ]; then mv gx_fpcmd ${d}_gx_fpcmd ; fi
    cd ..
    cd lib64/hw
    mv fingerprint.fpc.so fingerprint.${d}_fpc.so
    mv fingerprint.goodix.so fingerprint.${d}_goodix.so
    mv gxfingerprint.default.so gxfingerprint.${d}.so
    cd ../..
    cd .. # back to /fingerprint/device/
    cd .. # back to /fingerprint/
done
cd .. # back to /
#fi