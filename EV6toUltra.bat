@ECHO OFF
SetLocal enabledelayedexpansion 
CLS
COLOR 0F
ECHO TO USE: Drag and drop a zip file from 
ECHO         Examview 6.0 on this batch file 
ECHO.

REM Checks for blank drag/drop file
IF [%~n1]==[] (
   COLOR F4
   ECHO Whoops. You need to drag and drop a zip file on the batch file.
   GOTO END
   )

REM Extract the zip file
powershell -Command "& {Expand-Archive -Path '%~f1' -Destination %~n1 -Force}"

REM Rename res00000.dat to res00001.dat
IF EXIST %~n1\res00001.dat (
   COLOR F4
   ECHO It looks like zip file is already fixed, so exiting...
   GOTO CLEANUP
   )   
REN %~n1\res00000.dat res00001.dat

REM Write a good manifest file
(
ECHO ^<^?xml version=^"1.0^" encoding=^"UTF-8^"^?^>
ECHO ^<manifest identifier=^"man00001^"^>^<organization default=^"toc00001^"^>^<tableofcontents identifier=^"toc00001^"/^>^</organization^>^<resources^>^<resource baseurl=^"res00001^" file=^"res00001.dat^" identifier=^"res00001^" type=^"assessment/x-bb-pool^"/^>^</resources^>^</manifest^>
)>%~n1\imsmanifest.xml

REM Backup original zip file
MOVE /Y "%~f1" %~n1.bak >nul 2>&1

REM Recompress zip file
powershell -Command "& {Compress-Archive -Path '%~n1\*' -DestinationPath .\%~n1 -Force}"

:CLEANUP
REM Cleanup directories
RMDIR /S /Q %~n1

:END
ECHO.
PAUSE
