#!/bin/bash

FROM_IMAGE="localhost/cinncentvnc:latest"
BUILD_IMAGE_NAME="localhost/cinncentvnc:latest2"
JAVA_HOME="/usr/java/latest"
LD_LIBRARY_PATH="/usr/lib/oracle/12.2/client64/lib:/usr/lib/oracle/12.2/client/lib"


EXTRA_RPM_PATH="/opt/distr"
#EXTRA_RPM='zip unzip libaio java'
#EXTRA_RPM_LOCAL='/opt/distr/codium-1.44.2-1587206677.el7.x86_64.rpm /opt/distr/jdk-8u251-linux-x64.rpm /opt/distr/sqldeveloper-19.4.0.354.1759-19.4.0-354.1759.noarch.rpm /opt/distr/'

buildah rm -a

BUILD_START=$(date '+%s')

container=$(buildah from $FROM_IMAGE)
containermnt=$(buildah mount $container)

echo "begin build...."
echo "container: $container"
echo "container mount: $containermnt"

buildah config --env JAVA_HOME=${JAVA_HOME} --env LD_LIBRARY_PATH=${LD_LIBRARY_PATH} $container

buildah copy $container distr /opt/distr
buildah copy $container lnks /opt/lnks
#buildah run $container -- yum -y install ${EXTRA_RPM} ${EXTRA_RPM_LOCAL}
buildah run $container -- cp /opt/distr/startup.sh /
buildah run $container -- rm -rfv ${EXTRA_RPM_PATH}
buildah run $container -- yum clean all
buildah run $container -- rm -rfv /var/cache/yum

echo "end build..."

buildah run $container -- chmod a+xs /usr/local/bin/gosu-amd64

echo "container: $container"
echo "container mount: $containermnt"

buildah umount $container
image=$(buildah commit $container $BUILD_IMAGE_NAME)

BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`


cat << EOF

  Build image completed in $BUILD_ELAPSED seconds.

EOF
