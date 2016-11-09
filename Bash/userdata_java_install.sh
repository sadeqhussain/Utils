#!/bin/bash

################################################################################################
## Script Name: userdata_java_install.sh
## Author:      Sadequl Hussain
## Copyright:   2016, Sadequl Hussain
## Purpose:     Installs Java 8 in a Linux system as part of a userdata operation.
## Usage:       Copy and paste the script in the userdata section of a cloud based Linux server.
## Tested on:   Debian 7, 8, Ubuntu 12, 14, 16 RHEL 7, CentOS 6, 7 servers in AWS, DigitalOcean
################################################################################################


JAVA_INSTALL_VERSION=8 # "Change this to a lower version (say 7.0) when necessary"
LINUX_DISTRO=""
IS_JAVA_INSTALLED=False

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
  /bin/echo $LINUX_DISTRO
}

#function check_if_java_installed()
#{
  
#}

## Check the version of JDK to be installed. It can be either 7 or 8
check_installer_version

## check for Linux distro and version
check_linux_distro

## Check if Java exists. If it is, exit program
#check_if_java_installed


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