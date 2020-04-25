#!/bin/bash

FROM_IMAGE="localhost/cinncentvnc:1.0"
BUILD_IMAGE_NAME="localhost/cinncentvnc:1.0.1"

buildah rm -a

LNKS_PATH="/opt/lnks"
ADD_FILE1='v1.0.1/add_vnc_user'

BUILD_START=$(date '+%s')

container=$(buildah from $FROM_IMAGE)
containermnt=$(buildah mount $container)

echo "begin build...."
echo "container: $container"
echo "container mount: $containermnt"

#buildah run $container -- sed -i -e 's/#!\/bin\/sh/#!\/bin\/sh -x/' /startup.sh
#buildah run $container -- sed -i -e 's/#!\/bin\/sh -x/#!\/bin\/sh/' /startup.sh

buildah copy $container "${ADD_FILE1}" "${LNKS_PATH}/"

echo "end build..."
echo "container: $container"
echo "container mount: $containermnt"

buildah umount $container
image=$(buildah commit $container $BUILD_IMAGE_NAME)

BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`

cat << EOF

  Build image completed in $BUILD_ELAPSED seconds.

EOF
