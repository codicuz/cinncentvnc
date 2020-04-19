#!/bin/bash

FROM_IMAGE="centos:7"
BUILD_IMAGE_NAME="localhost/cinncentvnc:latest"

LANG="ru_RU.UTF-8"
EXTRA_YUM_PACKAGES='mc nmon iproute vim telnet git'
GOSU_RELEASE="1.12"

buildah rm -a

BUILD_START=$(date '+%s')

container=$(buildah from $FROM_IMAGE)
containermnt=$(buildah mount $container)

echo "begin build...."
echo "container: $container"
echo "container mount: $containermnt"

buildah config --env LANG=$LANG $container

buildah run $container -- localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
buildah run $container -- localedef -i ru_RU -f CP1251 ru_RU.CP1251

buildah run $container -- yum -y install epel-release
buildah run $container -- yum -y install tigervnc-server ${EXTRA_YUM_PACKAGES}
buildah run $container -- yum -y groups install "Cinnamon"
buildah run $container -- yum clean all
buildah run $container -- rm -rfv /var/cache/yum

buildah add $container rootfs /

buildah add $container https://github.com/tianon/gosu/releases/download/${GOSU_RELEASE}/gosu-amd64 /usr/local/bin
buildah run $container -- chmod a+xs /usr/local/bin/gosu-amd64

buildah config --volume /data $container
buildah config --port 5901/tcp $container
buildah config --cmd /startup.sh $container

echo "end build..."
echo "container: $container"
echo "container mount: $containermnt"

buildah umount $container
image=$(buildah commit $container $BUILD_IMAGE_NAME)

BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`

cat << EOF

  Build completed in $BUILD_ELAPSED seconds.

EOF
