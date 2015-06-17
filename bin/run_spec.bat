call setenv.bat
call setenv.batcall setenv.batcall setenv.batcall setenv.batcall setenv.batcall setenv.bat
call setenv.bat

call setenv.bat
call setenv.bat

cd %CD%\..

cmd /c "jruby -S bundle exec rspec spec\lib\components\params_parser_spec.rb"

cd %CD%\bin

