##########################################################################################################
## Script Name: universal_java_installer.sh
## Author:      Sadequl Hussain
## Copyright:   2016, Sadequl Hussain (Free for anyone to use, comes with no warranty)
##
## Purpose:     This script can be used in userdata when provisioning a cloud based Linux server.
##              It installs Open JDK or Oracle JDK v. 7 or 8 in most popular Linux distos.
##              It can be used in an existing Linux server as well, however in such case it does not
##              check for existing Java installations. The script also creates the $JAVA_HOME 
##              environment variable and update the $PATH variable.
##
## Usage:       1. Copy and paste the script in the userdata section when provisioning a Linux server.
##              2. Change the Java distribution (Oracle or Open) and the version (7,8,...)
##
## Tested on:   Cloud Platform: 
##                   AWS, DigitalOcean
##              Linux distros and editions (for both 32 bit and 64 bit):
##                  Debian 7, 8
##                  Ubuntu 12.04, 14.04, 14.10, 16.10, 
##                  RHEL 7.2, 6.8
##                  CentOS 7.2, 6.8 
##                  Fedora 23, 24 (x64 bit)
##                  Amazon Linux 2016.11
##                  SuSE Enterprise
##########################################################################################################

#!/bin/bash

JAVA_VERSION=8      # Two possible versions: 7 or 8 (this will change later with JDK 9)
JAVA_DISTRO=Oracle  # Two possible values: "Oracle" for OracleJDK and "Open" for OpenJDK

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

check_bit() {
  if [[ $(/bin/uname -m) = "x86_64" ]]; then
    BIT_VERSION="64"
  else
    BIT_VERSION="32"
  fi
}

check_java_distro_version() {
  # At the time of writing JDK 9 was not available. This will of course change
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
    if [ "$BIT_VERSION" = "64" ]; then
      JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz"
      JAVA_PACKAGE="jdk-8u112-linux-x64.tar.gz"
    else
      JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-i586.tar.gz"
      JAVA_PACKAGE="jdk-8u112-linux-i586.tar.gz"
    fi	  
  elif [ "$JAVA_VERSION" -eq 7 ]; then
    if [ "$BIT_VERSION" = "64" ]; then
      JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz"
      JAVA_PACKAGE="jdk-7u79-linux-x64.tar.gz"
    else
      JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-i586.tar.gz"
      JAVA_PACKAGE="jdk-7u79-linux-i586.tar.gz"
    fi
  fi
}

get_open_jdk_installer_name() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    JAVA_PACKAGE_NAME="openjdk-"$JAVA_VERSION"-jdk"
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    JAVA_PACKAGE_NAME="java-1."$JAVA_VERSION".0-openjdk-devel"
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
}

configure_open_jdk() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    ALTERNATIVES_PATH="/usr/bin/update-alternatives"
    JAVA_DIR_NAME=$(/bin/ls /usr/lib/jvm/ | /bin/grep java-$JAVA_VERSION) 
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    ALTERNATIVES_PATH="/usr/sbin/alternatives"
    JAVA_DIR_NAME=$(/bin/ls /usr/lib/jvm/ | /bin/grep java-1.$JAVA_VERSION.0-openjdk-)
  fi
  $ALTERNATIVES_PATH --install /usr/bin/java java /usr/lib/jvm/$JAVA_DIR_NAME/bin/java 2
  $ALTERNATIVES_PATH --install /usr/bin/javac javac /usr/lib/jvm/$JAVA_DIR_NAME/bin/javac 3
  $ALTERNATIVES_PATH --install /usr/bin/jar jar /usr/lib/jvm/$JAVA_DIR_NAME/bin/jar 4
  /bin/echo "export JAVA_HOME=/usr/lib/jvm/"$JAVA_DIR_NAME >> /etc/environment
  /bin/echo "export PATH=$PATH:/usr/lib/jvm/"$JAVA_DIR_NAME"/bin/" >> /etc/environment
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
check_bit
check_java_distro_version
install_configure_java