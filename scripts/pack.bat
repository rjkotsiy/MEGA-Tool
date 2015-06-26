del mgt_windows.zip
del mgt_macos.zip
del mgt_linux.zip

rmdir /S /Q  ..\vendor\linux\git
rmdir /S /Q  ..\vendor\linux\jre

rmdir /S /Q  ..\vendor\win\Git
rmdir /S /Q  ..\vendor\win\jre7-x86

rmdir /S /Q  ..\vendor\mac_os\jre1.7.0_75.jre


7z.exe a mgt_windows.zip @arclist

7z.exe d mgt_windows.zip lib\java-sources\

copy mgt_windows.zip mgt_linux.zip
copy mgt_windows.zip mgt_macos.zip


7z.exe d mgt_windows.zip bin\*.sh
7z.exe d mgt_windows.zip vendor\linux\
7z.exe d mgt_windows.zip vendor\mac_os\

7z.exe d mgt_linux.zip bin\*.bat
7z.exe d mgt_linux.zip bin\*mac*
7z.exe d mgt_linux.zip vendor\win\
7z.exe d mgt_linux.zip vendor\mac_os

7z.exe d mgt_macos.zip bin\*.bat
7z.exe d mgt_macos.zip bin\install.sh
7z.exe d mgt_macos.zip bin\setenv.sh
7z.exe d mgt_macos.zip bin\start.sh
7z.exe d mgt_macos.zip vendor\win\
7z.exe d mgt_macos.zip vendor\linux
