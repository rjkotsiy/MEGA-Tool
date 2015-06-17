@echo off

rem ---------------------------------------------------------------------------
rem Start MGT
rem ---------------------------------------------------------------------------

call .\setenv.bat

cd %MGT_HOME%\vendor\win

echo %cd%

IF EXIST "%JRE_HOME%" GOTO JRE_INSTALLED
echo Installing jre ...
  unzip jre7-x86.zip >nul
:JRE_INSTALLED
echo jre already installed.

echo Installing git ...
IF EXIST "%GIT_BINARIES%" GOTO GIT_INSTALLED
  unzip Git.zip >nul
:GIT_INSTALLED
echo git already installed.

echo Installing jruby ...
IF EXIST "%JRUBY_HOME%" GOTO JRUBY_INSTALLED
  unzip -d "%MGT_HOME%" "..\jruby.zip" > nul
  jruby -S bundle install
:JRUBY_INSTALLED
echo jruby already installed.

cd %MGT_HOME%\bin

echo MGT Installed Successfully.

@echo on

IF [%1]==[/ci] GOTO EXIT_SCRIPT

pause
:EXIT_SCRIPT
