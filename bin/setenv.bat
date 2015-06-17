@echo off

set "MGT_HOME=%CD%\.."
set "JRUBY_HOME=%MGT_HOME%\jruby"
set "GIT_BINARIES=%MGT_HOME%\vendor\win\Git\cmd"
set "UNZIP_PATH=%MGT_HOME\vendor\win%"

set "JRE_HOME=%MGT_HOME%\vendor\win\jre7-x86"
set "JAVA_HOME=%JRE_HOME%"

set "PATH=%JRE_HOME%\bin;%JRUBY_HOME%\bin;%GIT_BINARIES%;%UNZIP_PATH%;%PATH%"

echo %JRE_HOME%
echo %JRUBY_HOME%
echo %PATH%

set GEM_HOME=%JRUBY_HOME%\lib\ruby\gems\shared
set JRUBY_OPTS=%JRUBY_OPTS% --1.9

