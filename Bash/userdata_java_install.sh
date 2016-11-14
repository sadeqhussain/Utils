#!/bin/bash

####################################################################################################
## Script Name: userdata_java_install.sh
## Author:      Sadequl Hussain
## Copyright:   2016, Sadequl Hussain
## Purpose:     Installs Java in a Linux system as part of a userdata operation. 
## Usage:       1. Copy and paste the script in the userdata section of a cloud based Linux server.
##              2. Change the Java distribution (Oracle or Open) and the version (7,8,...)
## Tested on:   Debian 7, 8, Ubuntu 12, 14, 16 RHEL 7, CentOS 6, 7 servers in AWS, DigitalOcean
####################################################################################################

JAVA_INSTALL_VERSION=7 # Change this to a lower version (say 7.0) when necessary
JAVA_DISTRO=Oracle       # Two possible values: "Oracle" for OracleJDK and "Open" for OpenJDK

LINUX_DISTRO=""
INSTALL_COMMAND=""

check_linux_distro() {
  if /bin/cat /proc/version | /bin/grep Debian; then
    LINUX_DISTRO="Debian"
  elif /bin/cat /proc/version | /bin/grep Ubuntu; then
    LINUX_DISTRO="Ubuntu"
  elif /bin/cat /proc/version | /bin/grep "Red Hat"; then
    LINUX_DISTRO="Red Hat"
  else
    exit
  fi
}

check_java_distro_version() {
  # At the time of writing OpenJDK 9 was not available. This will of course change
  if [ "$JAVA_DISTRO" != "Oracle" ] && [ "$JAVA_DISTRO" != "Open" ]; then
    exit
  fi
  if [ "$JAVA_INSTALL_VERSION" -lt 7 ] || [ "$JAVA_INSTALL_VERSION" -gt 8 ]; then
    exit
  fi
}

install_wget() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    if  ! /bin/dpkg -l | grep wget; then
      /usr/sbin/apt-get install -y wget
    fi
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    if  ! /bin/rpm -qa | grep wget; then
      /usr/sbin/yum install -y wget
    fi
  fi
}

get_oracle_jdk_installer_name() {
  if [ "$JAVA_INSTALL_VERSION" -eq 8 ]; then
    JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz"
	JAVA_PACKAGE="jdk-8u112-linux-x64.tar.gz"
  elif [ "$JAVA_INSTALL_VERSION" -eq 7 ]; then
    JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"
	JAVA_PACKAGE="jdk-7u80-linux-x64.tar.gz"
  else
    exit
  fi
}

install_oracle_jdk() {
  install_wget
  get_oracle_jdk_installer_name
  /usr/bin/wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_INSTALLER_URL
  /bin/tar xvzf $JAVA_PACKAGE
  /bin/rm -f $JAVA_PACKAGE
  JAVA_DIR_NAME=eval "/bin/ls . | /bin/grep "jdk1.""
  /bin/mv $JAVA_DIR_NAME/ /usr/local/
}

configure_oracle_jdk() {
  /usr/sbin/alternatives --install /usr/bin/java java /usr/local/$JAVA_DIR_NAME/bin/java 2
  /usr/sbin/alternatives --install /usr/bin/javac javac /usr/local/$JAVA_DIR_NAME/bin/javac 3
  /usr/sbin/alternatives --install /usr/bin/jar jar /usr/local$JAVA_DIR_NAME/bin/jar 4

  /bin/echo "export JAVA_HOME=/usr/local/"$JAVA_DIR_NAME >> /etc/environment
  /bin/echo "export PATH=$PATH:/usr/local/"$JAVA_DIR_NAME"/bin/" >> /etc/environment
}

## To do: Have to cater for OpenJDK 8 not being available for Ubuntu 14.04 and less and being available from 14.10 and above.
## Same goes for Debian
## http://askubuntu.com/questions/464755/how-to-install-openjdk-8-on-14-04-lts

install_open_jdk_debian_ubuntu() {
  INSTALL_COMMAND="/usr/bin/apt-get install -y openjdk-"$JAVA_INSTALL_VERSION"-jdk"
  eval "$INSTALL_COMMAND"  
}

install_open_jdk_redhat() {
  INSTALL_COMMAND="/usr/bin/yum install -y java-1."$JAVA_INSTALL_VERSION".0-openjdk"
  eval "$INSTALL_COMMAND"  
}

install_configure_java() {
  if [ "$JAVA_DISTRO" = "Oracle" ]; then
    install_oracle_jdk
	configure_oracle_jdk
  elif [ "$JAVA_DISTRO" = "Open" ]; then
    if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
      install_open_jdk_debian_ubuntu
	elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
      install_open_jdk_redhat
	fi
  fi
}
	
check_linux_distro
check_java_distro_version
install_configure_java

## Testing 
# Open JDK 7 => CentOS 6 passed
# Open JDK 8 => CentOS 6 passed
# Open JDK 7 => CentOS 7 passed
# Open JDK 8 => CentOS 7 passed

# Open JDK 7 => Debian 7 passed
# Open JDK 7 => Ubuntu 14 passed