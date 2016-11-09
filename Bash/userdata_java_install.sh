#!/bin/bash

############################################################################################################################
## Script Name: install_datastax_ddc_rhel.sh
## Author: 		Sadequl Hussain
## Purpose:		Installs Java 8 and Datastax Cassandra in a RHEL system as part of a  user data operation. 
## 				Of course there is Puppet/Chef/Ansible for this sort of operation, but this is a quick and dirty installer. 
#############################################################################################################################


java_installer_url=http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz

## Check if Java exists. If it is, exit program

## check for Linux distro and version

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