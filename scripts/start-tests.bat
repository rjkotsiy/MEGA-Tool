@echo on
echo %cd%
rem ---------------------------------------------------------------------------
rem Start tests for MGT
rem ---------------------------------------------------------------------------

call ..\bin\setenv.bat

cd ..\

rem ! Uncomment lines below when all specs test will be written !

rem cmd /c "jruby -S bundle exec rspec spec" > test_spec.out
rem find /c "failures" test_spec.out
