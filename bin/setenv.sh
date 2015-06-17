#!/bin/sh

########################################################################### ##
# SoftServe, Inc.
# Copyright (c) SoftServe, Inc. 1999-2015
# All Rights Reserved.
## ######################################################################### ##

## ######################################################################### ##
## SET ENVIRONMENT VARIABLES                                                  ##
## ######################################################################### ##

export MGT_HOME=$PWD/..
export JRE_HOME=$MGT_HOME/vendor/linux/jre
export JRUBY_HOME=$MGT_HOME/jruby
export GIT_BINARIES=$MGT_HOME/vendor/linux/git/bin
#export JAVA_HOME=$MGT_HOME/lib/jdkz
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MGT_HOME/vendor/linux/svn/lib"

export DEFAULT_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

#export PATH="$JAVA_HOME/bin:$JRUBY_HOME/bin:$MGT_HOME/lib/bin:$DEFAULT_PATH"
export PATH="$JRE_HOME/bin:$JRUBY_HOME/bin:$JRUBY_HOME/lib/ruby/gems/shared/bin:$MGT_HOME/lib/bin:$GIT_BINARIES:$DEFAULT_PATH"

echo $JRE_HOME
echo $JRUBY_HOME
echo $PATH

export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx2048m -XX:PermSize=128m -XX:MaxPermSize=256m -XX:+UseParallelGC -XX:+CMSClassUnloadingEnabled"
# RJ: Jruby 1.7.1 does not need this to be mentioned explicitly
export JRUBY_OPTS="$JRUBY_OPTS --1.9"


# RJ: Temporarily disable setting RUBYLIB
# export RUBYLIB=$JRUBY_HOME/lib/ruby/site_ruby/1.8
export GEM_HOME=$JRUBY_HOME/lib/ruby/gems/shared
