#!/bin/bash -e

GIT_MV=""
PREFIX="$1"

if [ "$(echo -n $PREFIX | wc -m)" != "1" ]; then
    echo "Invalid prefix"
    exit 1
fi

set -x

# Step 1: Edit dependency libs names
for i in `ls *.so|grep -E "^lib"`; do # All libraries beginning with lib
    NEW_NAME=$(echo -n ${i}|sed "s|.|${PREFIX}|4")
    sed -i "s|${i}|${NEW_NAME}|g" *
done
if [ "$GIT_MV" ]; then
    git add .
fi

# Step 2: Rename filenames
if [ "$GIT_MV" ]; then
	MV="git mv"
else
	MV="mv"
fi
for i in `ls *.so|grep -E "^lib"`; do
    NEW_NAME=$(echo -n ${i}|sed "s|.|${PREFIX}|4")
    ${MV} ${i} ${NEW_NAME}
done

exit 0