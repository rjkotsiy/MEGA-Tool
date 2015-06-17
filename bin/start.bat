@echo off

rem ---------------------------------------------------------------------------
rem Start tests for MGT
rem ---------------------------------------------------------------------------

@echo on
call setenv.bat

cd %CD%\..

cmd /c "jruby -S bundle exec jruby main.rb"

cd %CD%\bin

pause