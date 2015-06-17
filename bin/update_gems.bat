call setenv.bat

cd %CD%\..

cmd /c "jruby -S bundle install"

cd %CD%\bin

