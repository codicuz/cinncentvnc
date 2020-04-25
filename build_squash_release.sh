#!/bin/bash

FROM_IMAGE="localhost/cinncentvnc:dev"
BUILD_IMAGE_NAME="localhost/cinncentvnc:1.1"

buildah rm -a

BUILD_START=$(date '+%s')

container=$(buildah from $FROM_IMAGE)
containermnt=$(buildah mount $container)

echo "begin build...."
echo "container: $container"
echo "container mount: $containermnt"

buildah run $container -- sed -i -e 's/#!\/bin\/sh -x/#!\/bin\/sh/' /startup.sh

echo "end build..."
echo "container: $container"
echo "container mount: $containermnt"

buildah umount $container
image=$(buildah commit --squash $container $BUILD_IMAGE_NAME)

BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`


cat << EOF

  Build image completed in $BUILD_ELAPSED seconds.

EOF
