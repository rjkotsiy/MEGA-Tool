#!/bin/bash

########################################################################### ##
# SoftServe, Inc.
# Copyright (c) SoftServe, Inc. 1999-2015
# All Rights Reserved.
## ######################################################################### ##

## ######################################################################### ##
## SET ENVIRONMENT VARIABLES                                                 ##
## ######################################################################### ##

export MGT_HOME=$PWD/..
export JRUBY_HOME=$MGT_HOME/vendor/jruby
export JRE_HOME=$MGT_HOME/vendor/mac_os/jre1.7.0_75.jre
export JAVA_HOME=$JRE_HOME/Contents/Home		
export MAIN_PATH=$PATH

export PATH="$JRUBY_HOME/bin:$JRUBY_HOME/lib/ruby/gems/shared/bin:$JAVA_HOME/bin:$MAIN_PATH"

export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx2048m -XX:PermSize=128m -XX:MaxPermSize=256m -XX:+UseParallelGC -XX:+CMSClassUnloadingEnabled"

# RJ: Jruby 1.7.1 does not need this to be mentioned explicitly
export JRUBY_OPTS="$JRUBY_OPTS --1.9"

# RJ: Temporarily disable setting RUBYLIB
# export RUBYLIB=$JRUBY_HOME/lib/ruby/site_ruby/1.8
export GEM_HOME=$JRUBY_HOME/lib/ruby/gems/shared

echo $PATH