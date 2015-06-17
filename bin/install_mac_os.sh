#!/bin/bash

########################################################################### ##
# SoftServe, Inc.
# Copyright (c) SoftServe, Inc. 1999-2015
# All Rights Reserved.
## ######################################################################### ##

## ######################################################################### ##
## INSTALL LIBRARIES                                                         ##
## ######################################################################### ##
. ./setenv_mac_os.sh > /dev/null

if ! [ -x "$(command -v brew)" ]; then
	rm -rf  /usr/local/Cellar /usr/local/.git
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! [ -x "$(command -v git)" ]; then
	echo 'Installing Git....'
	brew install git > /dev/null
fi

cd "$MGT_HOME/vendor/mac_os"

if [ ! -d "JRE_HOME" ]; then
	echo "Installing jre ..."
	tar -zxvf jre-7u75-macosx-x64.tar.gz > /dev/null 2>&1
fi 

cd "$MGT_HOME/vendor"


if [ ! -d "$JRUBY_HOME" ]; then
  echo "Installing jruby ..."
  unzip jruby.zip > /dev/null
  chmod 755 "$MGT_HOME/vendor/jruby/bin/jruby"
  jruby -S bundle install
fi

cd "$MGT_HOME/bin"

echo "MGT Successfully installed"	