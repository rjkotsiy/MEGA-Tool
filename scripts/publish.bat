@echo ... publishing MGT distribution ...


net use s: \\sdo\MetricsGatheringTool$ /user:SOFTSERVE\rkotsiy 55Molaadebisi555


del s:\*.zip

copy ..\version c:\inetpub\wwwroot\version.txt /Y /Y
copy *.zip s:\ /Y

net use s: /Delete

@echo ... DONE ...
