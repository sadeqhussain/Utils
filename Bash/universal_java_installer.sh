##########################################################################################################
## Script Name: universal_java_installer.sh
## Author:      Sadequl Hussain
## Copyright:   2016, Sadequl Hussain (Free for anyone to use, comes with no warranty)
##
## Purpose:     This script can be used in userdata when provisioning a cloud based Linux server.
##              It installs Open JDK 8 or Oracle JDK 7 or 8 in most popular Linux distos.
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
##                  Debian 8.6 (Jessie)
##                  Ubuntu 12.04, 14.04, 16.04, 16.10, 
##                  RHEL 7.3
##                  CentOS 7.2, 6.8 
##                  Fedora 23, 24 (64 bit)
##                  Amazon Linux 2016.09 (64 bit)
##                  SuSE Enterprise 12 (64 bit)
##
## Nuance:      1. In DigitalOcean, it may take some time for Java to be installed even after the node 
##                 has been provisioned. This is not the case for AWS-hosted nodes.
##              2. In AWS, the $PATH variable does not reflect the $JAVA_HOME/bin even though
##                 it sets the $JAVA_HOME. Have to run source /etc/environment after provisioning.           
##########################################################################################################

#!/bin/bash

JAVA_VERSION=8      # Two possible values: 7 or 8 for Oracle JDK. One possible value: 8 for Open JDK
JAVA_DISTRO=Open    # Two possible values: "Oracle" for OracleJDK and "Open" for OpenJDK

check_linux_distro() {
  if /bin/cat /proc/version | /bin/grep Debian; then
    LINUX_DISTRO="Debian"
  elif /bin/cat /proc/version | /bin/grep Ubuntu; then
    LINUX_DISTRO="Ubuntu"
  elif /bin/cat /proc/version | /bin/grep "Red Hat"; then
    LINUX_DISTRO="Red Hat"
  elif /bin/cat /proc/version | /bin/grep "SUSE"; then
    LINUX_DISTRO="SUSE"	
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
  # At the time of writing JDK 9 was not available. This will of course change in future
  if [ "$JAVA_DISTRO" != "Oracle" ] && [ "$JAVA_DISTRO" != "Open" ]; then
    exit
  fi
  if [ "$JAVA_DISTRO" = "Oracle" ]; then
    if [ "$JAVA_VERSION" -lt 7 ] || [ "$JAVA_VERSION" -gt 8 ]; then
      exit
    fi
  fi
  if [ "$JAVA_DISTRO" = "Open" ]; then
    if [ "$JAVA_VERSION" -ne 8 ]; then
      exit
    fi
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
  elif [ "$LINUX_DISTRO" = "SUSE" ]; then
    if  ! /usr/bin/zypper search | grep wget; then
      /usr/bin/zypper install -y wget
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
  elif [ "$LINUX_DISTRO" = "SUSE" ]; then
    JAVA_PACKAGE_NAME="java-1_"$JAVA_VERSION"_0-openjdk-devel"	
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
  elif [ "$LINUX_DISTRO" = "SUSE" ]; then
    ALTERNATIVES_PATH="/usr/sbin/update-alternatives"	
  fi
  $ALTERNATIVES_PATH --install /usr/bin/java java /usr/local/$JAVA_DIR_NAME/bin/java 2
  $ALTERNATIVES_PATH --install /usr/bin/javac javac /usr/local/$JAVA_DIR_NAME/bin/javac 3
  $ALTERNATIVES_PATH --install /usr/bin/jar jar /usr/local/$JAVA_DIR_NAME/bin/jar 4
  $ALTERNATIVES_PATH --set java /usr/local/$JAVA_DIR_NAME/bin/java
  $ALTERNATIVES_PATH --set javac /usr/local/$JAVA_DIR_NAME/bin/javac
  $ALTERNATIVES_PATH --set jar /usr/local/$JAVA_DIR_NAME/bin/jar
  /bin/echo "export JAVA_HOME=/usr/local/"$JAVA_DIR_NAME >> /etc/environment
  source /etc/environment
  /bin/echo "export PATH=$PATH:/usr/local/"$JAVA_DIR_NAME"/bin/" >> /etc/environment
  source /etc/environment
}

install_open_jdk() {
  get_open_jdk_installer_name
  if [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    INSTALL_COMMAND="/usr/bin/add-apt-repository ppa:openjdk-r/ppa -y"
    eval "$INSTALL_COMMAND"
    INSTALL_COMMAND="/usr/bin/apt-get update -y"
    eval "$INSTALL_COMMAND"
    INSTALL_COMMAND="/usr/bin/apt-get install -y "$JAVA_PACKAGE_NAME
  elif [ "$LINUX_DISTRO" = "Debian" ]; then
    INSTALL_COMMAND="/bin/echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list"
    eval "$INSTALL_COMMAND"
    INSTALL_COMMAND="/usr/bin/apt-get update -y"
    eval "$INSTALL_COMMAND"
    INSTALL_COMMAND="/usr/bin/apt-get install -y "$JAVA_PACKAGE_NAME    
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    INSTALL_COMMAND="/usr/bin/yum install -y "$JAVA_PACKAGE_NAME
  elif [ "$LINUX_DISTRO" = "SUSE" ]; then
    INSTALL_COMMAND="/usr/bin/zypper install -y "$JAVA_PACKAGE_NAME
  fi    
  eval "$INSTALL_COMMAND"
}

configure_open_jdk() {
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    ALTERNATIVES_PATH="/usr/bin/update-alternatives"
    INSTALL_DIR=/usr/lib/jvm
    JAVA_DIR_NAME=$(/bin/ls $INSTALL_DIR | /bin/grep java-$JAVA_VERSION) 
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    ALTERNATIVES_PATH="/usr/sbin/alternatives"
    INSTALL_DIR=/usr/lib/jvm
    JAVA_DIR_NAME=$(/bin/ls $INSTALL_DIR | /bin/grep java-1.$JAVA_VERSION.0-openjdk-)
  elif [ "$LINUX_DISTRO" = "SUSE" ]; then
    ALTERNATIVES_PATH="/usr/sbin/update-alternatives"
    if [ "$BIT_VERSION" = "64" ]; then 
      INSTALL_DIR=/usr/lib64/jvm
	else
	  INSTALL_DIR=/usr/lib/jvm
	fi
    JAVA_DIR_NAME=$(/bin/ls $INSTALL_DIR | /bin/grep java-1.$JAVA_VERSION.0-openjdk-)	
  fi
  $ALTERNATIVES_PATH --install /usr/bin/java java $INSTALL_DIR/$JAVA_DIR_NAME/bin/java 2
  $ALTERNATIVES_PATH --install /usr/bin/javac javac $INSTALL_DIR/$JAVA_DIR_NAME/bin/javac 3
  $ALTERNATIVES_PATH --install /usr/bin/jar jar $INSTALL_DIR/$JAVA_DIR_NAME/bin/jar 4
  $ALTERNATIVES_PATH --set java $INSTALL_DIR/$JAVA_DIR_NAME/bin/java
  $ALTERNATIVES_PATH --set javac $INSTALL_DIR/$JAVA_DIR_NAME/bin/javac
  $ALTERNATIVES_PATH --set jar $INSTALL_DIR/$JAVA_DIR_NAME/bin/jar  
  /bin/echo "export JAVA_HOME="$INSTALL_DIR/$JAVA_DIR_NAME >> /etc/environment
  source /etc/environment
  /bin/echo "export PATH=$PATH:"$INSTALL_DIR/$JAVA_DIR_NAME"/bin/" >> /etc/environment
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