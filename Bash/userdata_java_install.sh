#!/bin/bash

################################################################################################
## Script Name: userdata_java_install.sh
## Author:      Sadequl Hussain
## Copyright:   2016, Sadequl Hussain
## Purpose:     Installs Java 8 in a Linux system as part of a userdata operation.
## Usage:       Copy and paste the script in the userdata section of a cloud based Linux server.
## Tested on:   Debian 7, 8, Ubuntu 12, 14, 16 RHEL 7, CentOS 6, 7 servers in AWS, DigitalOcean
################################################################################################

   
JAVA_INSTALL_VERSION=8   # Change this to a lower version (say 7.0) when necessary
JAVA_DISTRO=Oracle       # Two possible values: "Oracle" for OracleJDK and "Open" for OpenJDK

LINUX_DISTRO=""
INSTALL_COMMAND=""


function check()
{
  if [ "$JAVA_INSTALL_VERSION" -lt 7 ]; then
    exit
  fi
  if [ "$JAVA_DISTRO" != "Oracle" ] && [ "$JAVA_DISTRO" != "Open" ]; then
    exit
  fi
}

function check_linux_distro()
{
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

function find_installer()
{
  if [ "$LINUX_DISTRO" = "Debian" ] || [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    case $JAVA_DISTRO in
      "Open")
        INSTALL_COMMAND="/usr/bin/apt-get install -y openjdk-"$JAVA_INSTALL_VERSION"-jdk"
        ;;		
      "Oracle")
        INSTALL_COMMAND="Oracle JDK install command for Debian/Ubuntu"
		;;
      "x")
        exit
        ;;		
    esac		
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    case $JAVA_DISTRO in
      "Open")
        INSTALL_COMMAND="/usr/bin/ yum install java-1."$JAVA_INSTALL_VERSION".0-openjdk"
        ;;		
      "Oracle")
        INSTALL_COMMAND="Oracle JDK install command for Red Hat"
		;;
      "*")
        exit
        ;;
    esac
  fi
  echo $INSTALL_COMMAND
}

check
check_linux_distro
find_installer



function check_installer_version()
{
  if [ "$JAVA_INSTALL_VERSION" == 8 ]; then
    JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz"
  elif [ "$JAVA_INSTALL_VERSION" == 7 ]; then
    JAVA_INSTALLER_URL="http://download.oracle.com/otn-pub/java/jdk/7u79-b15-demos/jdk-7u79-linux-x64-demos.tar.gz"
  else
    exit
  fi
  /bin/echo $JAVA_INSTALL_VERSION
}



## Still need to work on the rest of the script



## Download wget if it does not exist...

if  ! rpm -qa | grep wget; then
    /usr/sbin/yum install -y wget
fi

## Download, install and configure Java 8...

/usr/bin/wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" $java_installer_url

/usr/bin/cp ./jdk-8u101-linux-x64.tar.gz /tmp/

/usr/bin/cd /tmp/

/usr/bin/tar xzf jdk-8u101-linux-x64.tar.gz

/usr/bin/mv jdk1.8.0_101/ /usr/local/

/usr/sbin/alternatives --install /usr/bin/java java /usr/local/jdk1.8.0_101/bin/java 2
/usr/sbin/alternatives --install /usr/bin/javac javac /usr/local/jdk1.8.0_101/bin/javac 3
/usr/sbin/alternatives --install /usr/bin/jar jar /usr/local/jdk1.8.0_101/bin/jar 4

/usr/bin/echo "export JAVA_HOME=/usr/local/jdk1.8.0_101" >> ~/.bashrc
/usr/bin/echo "export PATH=$PATH:/usr/local/jdk1.8.0_101/bin/" >> ~/.bashrc