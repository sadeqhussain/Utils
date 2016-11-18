#!/bin/bash

####################################################################################################
## Script Name: universal_java_installer.sh
## Author:      Sadequl Hussain
## Copyright:   2016, Sadequl Hussain
## Purpose:     Installs Java in a 64 bit Linux server as part of userdata provisioning. 
## Usage:       1. Copy and paste the script in the userdata section of a cloud based Linux server.
##              2. Change the Java distribution (Oracle or Open) and the version (7,8,...)
## Tested on:   Debian 7, 8, Ubuntu 12, 14, 16, RHEL 7, CentOS 6, 7 servers in AWS, DigitalOcean
####################################################################################################

JAVA_VERSION=7    # Change this to a lower version (say 7.0) when necessary
JAVA_DISTRO=Open  # Two possible values: "Oracle" for OracleJDK and "Open" for OpenJDK

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
  if [ "$JAVA_VERSION" -lt 7 ] || [ "$JAVA_VERSION" -gt 8 ]; then
    exit
  fi
}

install_wget() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    if  ! /usr/bin/dpkg -l | grep wget; then
      /usr/bin/apt-get install -y wget
    fi
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    if  ! /bin/rpm -qa | grep wget; then
      /usr/bin/yum install -y wget
    fi
  fi
}

get_oracle_jdk_installer_name() {
  if [ "$JAVA_VERSION" -eq 8 ]; then
    JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz"
    JAVA_PACKAGE="jdk-8u112-linux-x64.tar.gz"
  elif [ "$JAVA_VERSION" -eq 7 ]; then
    JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"
    JAVA_PACKAGE="jdk-7u80-linux-x64.tar.gz"
  else
    exit
  fi
}

get_open_jdk_installer_name() {
  if [ "$JAVA_VERSION" -eq 8 ]; then
    if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
      JAVA_PACKAGE_NAME="openjdk-"$JAVA_VERSION"-jdk"
    elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
      JAVA_PACKAGE_NAME="java-1."$JAVA_VERSION".0-openjdk-devel"
    fi
  elif [ "$JAVA_VERSION" -eq 7 ]; then
    if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
      JAVA_PACKAGE_NAME="openjdk-"$JAVA_VERSION"-jdk"
    elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
      JAVA_PACKAGE_NAME="java-1."$JAVA_VERSION".0-openjdk-devel"
    fi
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
  JAVA_DIR_NAME=$(/bin/ls . | /bin/grep jdk1.)
  /bin/mv $JAVA_DIR_NAME/ /usr/local/
}

configure_oracle_jdk() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    ALTERNATIVES_PATH="/usr/bin/update-alternatives"
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    ALTERNATIVES_PATH="/usr/sbin/alternatives"
  fi
   
  $ALTERNATIVES_PATH --install /usr/bin/java java /usr/local/$JAVA_DIR_NAME/bin/java 2
  $ALTERNATIVES_PATH --install /usr/bin/javac javac /usr/local/$JAVA_DIR_NAME/bin/javac 3
  $ALTERNATIVES_PATH --install /usr/bin/jar jar /usr/local/$JAVA_DIR_NAME/bin/jar 4

  /bin/echo "export JAVA_HOME=/usr/local/"$JAVA_DIR_NAME >> /etc/environment
  /bin/echo "export PATH=$PATH:/usr/local/"$JAVA_DIR_NAME"/bin/" >> /etc/environment
  
  source /etc/environment

}

install_open_jdk() {
  get_open_jdk_installer_name
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    INSTALL_COMMAND="/usr/bin/add-apt-repository ppa:openjdk-r/ppa -y"
    eval "$INSTALL_COMMAND"
    INSTALL_COMMAND="/usr/bin/apt-get update -y"
    eval "$INSTALL_COMMAND"
    INSTALL_COMMAND="/usr/bin/apt-get install -y "$JAVA_PACKAGE_NAME
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    INSTALL_COMMAND="/usr/bin/yum install -y "$JAVA_PACKAGE_NAME
  fi          
  eval "$INSTALL_COMMAND"
  JAVA_DIR_NAME=$(/bin/ls /usr/lib/jvm/ | /bin/grep java-$JAVA_VERSION) 
}

configure_open_jdk() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    ALTERNATIVES_PATH="/usr/bin/update-alternatives"
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    ALTERNATIVES_PATH="/usr/sbin/alternatives"
  fi
   
  $ALTERNATIVES_PATH --install /usr/bin/java java /usr/lib/jvm/$JAVA_DIR_NAME/bin/java 2
  $ALTERNATIVES_PATH --install /usr/bin/javac javac /usr/lib/jvm/$JAVA_DIR_NAME/bin/javac 3
  $ALTERNATIVES_PATH --install /usr/bin/jar jar /usr/lib/jvm/$JAVA_DIR_NAME/bin/jar 4

  /bin/echo "export JAVA_HOME=/usr/lib/jvm/"$JAVA_DIR_NAME >> /etc/environment
  /bin/echo "export PATH=$PATH:/usr/lib/jvm/"$JAVA_DIR_NAME"bin/" >> /etc/environment

  source /etc/environment
}

install_configure_java() {
  if [ "$JAVA_DISTRO" = "Oracle" ]; then
    install_oracle_jdk
    configure_oracle_jdk
  elif [ "$JAVA_DISTRO" = "Open" ]; then
    install_open_jdk
    configure_open_jdk    
  fi
}
	
check_linux_distro
check_java_distro_version
install_configure_java