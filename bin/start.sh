#!/bin/sh

########################################################################### ##
# SoftServe, Inc.
# Copyright (c) SoftServe, Inc. 1999-2015
# All Rights Reserved.
## ######################################################################### ##

## ######################################################################### ##
## RUN MGT                                                                   ##
## ######################################################################### ##

. ./setenv.sh

cd $MGT_HOME

jruby -S bundle exec jruby main.rb
