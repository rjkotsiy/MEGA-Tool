#!/bin/sh

########################################################################### ##
# SoftServe, Inc.
# Copyright (c) SoftServe, Inc. 1999-2015
# All Rights Reserved.
## ######################################################################### ##

## ######################################################################### ##
## INSTALL LIBRARIES                                                         ##
## ######################################################################### ##
. ./setenv.sh > /dev/null

cd "$MGT_HOME/vendor/linux" 

echo "Installing jre ..."
if [ ! -d "$JRE_HOME" ]; then
  unzip jre.zip > /dev/null
  chmod 755 "$MGT_HOME/vendor/linux/jre/bin/java"
fi

echo "Installing git libraries ..."
if [ ! -d "$GIT_BINARIES" ]; then
  unzip git.zip > /dev/null
fi

cd "$MGT_HOME" 

echo "Installing jruby ..."
if [ ! -d "$JRUBY_HOME" ]; then
  unzip  "$MGT_HOME/vendor/jruby.zip" > /dev/null
  chmod 755 "$MGT_HOME/jruby/bin/jruby"
  jruby -S bundle install
fi

cd "$MGT_HOME/bin"
chmod +x start.sh

echo "MGT Successfully installed"

