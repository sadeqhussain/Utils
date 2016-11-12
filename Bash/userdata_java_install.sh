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

   
JAVA_INSTALL_VERSION=8 # Change this to a lower version (say 7.0) when necessary
JAVA_DISTRO=Open       # Two possible values: "Oracle" for OracleJDK and "Open" for OpenJDK

LINUX_DISTRO=""
INSTALL_COMMAND=""

function check_linux_distro() {
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

function check_java_version() {
  if [ "$JAVA_INSTALL_VERSION" -lt 7 ]; then
    exit
  fi
  # At the time of writing OpenJDK 9 was not available
  if [ "$JAVA_DISTRO" = "Open" ] && [ "$JAVA_INSTALL_VERSION" -gt 8 ]; then
    exit
  fi
  if [ "$JAVA_DISTRO" != "Oracle" ] && [ "$JAVA_DISTRO" != "Open" ]; then
    exit
  fi
}




## To do: Have to cater for OpenJDK 8 not being available for Ubuntu 14.04 and less and being available from 14.10 and above.
## Same goes for Debian
## http://askubuntu.com/questions/464755/how-to-install-openjdk-8-on-14-04-lts

function install_open_jdk_debian() {
  INSTALL_COMMAND="/usr/bin/apt-get install -y openjdk-"$JAVA_INSTALL_VERSION"-jdk"
  eval "$INSTALL_COMMAND"  
}

function install_open_jdk_ubuntu() {
  INSTALL_COMMAND="/usr/bin/apt-get install -y openjdk-"$JAVA_INSTALL_VERSION"-jdk"
  eval "$INSTALL_COMMAND"  
}

function install_open_jdk_redhat() {
  INSTALL_COMMAND="/usr/bin/yum install -y java-1."$JAVA_INSTALL_VERSION".0-openjdk"
  eval "$INSTALL_COMMAND"  
}

function install_oracle_jdk_debian() {
  INSTALL_COMMAND="/usr/bin/apt-get install -y python-software-properties"
  eval "$INSTALL_COMMAND"  
  INSTALL_COMMAND="/usr/bin/add-apt-repository ppa:webupd8team/java -y"
  eval "$INSTALL_COMMAND"
  INSTALL_COMMAND="/usr/bin/apt-get update -y"
  eval "$INSTALL_COMMAND"
  INSTALL_COMMMAND="/usr/bin/apt-get install -y oracle-java"$JAVA_INSTALL_VERSION"-installer"
}

function install_oracle_jdk_ubuntu() {
  INSTALL_COMMAND="/usr/bin/apt-get install -y python-software-properties"
  eval "$INSTALL_COMMAND"  
  INSTALL_COMMAND="/usr/bin/add-apt-repository ppa:webupd8team/java -y"
  eval "$INSTALL_COMMAND" 
  INSTALL_COMMAND="/usr/bin/apt-get update -y"
  eval "$INSTALL_COMMAND" 
  INSTALL_COMMMAND="/usr/bin/apt-get install -y oracle-java"$JAVA_INSTALL_VERSION"-installer"
}

function install_java() {
  if [ "$LINUX_DISTRO" = "Debian" ] ; then
    case $JAVA_DISTRO in
      "Open")
        install_open_jdk_debian
        ;;		
      "Oracle")
        install_oracle_jdk_debian
		;;
      "x")
        exit
        ;;		
    esac
  elif [ "$LINUX_DISTRO" = "Ubuntu" ]; then
    case $JAVA_DISTRO in
      "Open")
        install_open_jdk_ubuntu
        ;;		
      "Oracle")
        install_oracle_jdk_ubuntu
		;;
      "*")
        exit
        ;;
    esac  	
  elif [ "$LINUX_DISTRO" = "Red Hat" ]; then
    case $JAVA_DISTRO in
      "Open")
        install_open_jdk_redhat
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

#install

check_linux_distro
check_java_version
install_java


## Testing 
# Open JDK 7 => CentOS 6 passed
# Open JDK 8 => CentOS 6 passed
# Open JDK 7 => CentOS 7 passed
# Open JDK 8 => CentOS 7 passed

# Open JDK 7 => Debian 7 passed
# Open JDK 7 => Ubuntu 14 passed



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