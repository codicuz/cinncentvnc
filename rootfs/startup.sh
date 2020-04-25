#!/bin/sh -x

ID=$(id -u)
GOSU="/usr/local/bin/gosu-amd64"
DEFAULT_HOME="/opt/default/home"
VNC_PASSWORD="${VNC_PASSWORD:-resu2020}"
VNC_PASSWORDR="${VNC_PASSWORDR:-res2020r}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1280x720}"

if [ -z "${HOME}" ] || [ "${HOME}" = "/" ]
then
 echo 'ERROR: Wrong ENV $HOME is set. Aborting'
 exit 1
fi

if [ ${ID} -eq 0 ] 
then
echo "User is 0. Skipping useradd instruction"
elif [ -f ${GOSU} ]
then
  echo "Creating user with uid ${ID}."
  gosu-amd64 0 bash -c "useradd -u ${ID} -s /usr/bin/bash user"
  gosu-amd64 0 bash -c "printf '%s\n' ${VNC_PASSWORD} ${VNC_PASSWORD} | passwd user"
else
  echo "Gosu is not present. Error"
  exit 1
fi

[ -d ${HOME}/.vnc ] || (
 echo "Info: Bootstrapping ${HOME} directory from ${DEFAULT_HOME}"
 mkdir -vp "${HOME}/.vnc"
 cp -rav "${DEFAULT_HOME}/." "${DEFAULT_HOME}/.vnc" "${HOME}/"
 printf '%s\n' ${VNC_PASSWORD} ${VNC_PASSWORD} y ${VNC_PASSWORDR} ${VNC_PASSWORDR} | vncpasswd
)

# start VNC server

exec vncserver -fg -geometry ${VNC_GEOMETRY}
