::20180527
::JimmyWilliams
::Description: This program allows users to schedule a future shutdown, and cancel them.
::
::Warning: Does not show the timer when shutdown will occur

@echo off
setlocal enabledelayedexpansion
goto :MAIN

:INVALID
Echo X = "%input01%" is invalid.
timeout 5
goto :MAIN

:NOW
C:\Windows\System32\shutdown /s
Echo    Shutting down now.
pause
goto :MAIN

:STOP
Echo    Attempting to stop any Scheduled Shutdowns.
Echo/
C:\Windows\System32\shutdown /a 2>NUL
if NOT ERRORLEVEL 1116 (Echo    Scheduled shutdown stopped.) ELSE (
Echo    Unable to abort the system because no shutdown was in progress (1116^)
)
Timeout 10
goto :MAIN

:MAIN
cls
set "input01="
set "ExVal01="
Echo JimmyWilliams - 20180523
Echo/
Echo This will cause the computer to automatically shutdown in X minutes,
Echo and will override any existing scheduled shutdown.
Echo/
Echo Enter "X = Stop", cancel any currently active future shutdown.
Echo Enter "X = Quit", to close this program.
Echo/
Set /p "input01=1. Enter a whole positive number: X = "
if "%input01%"=="" goto :INVALID
Set /a ExVal01="%input01%"*60
if /I "%input01%"=="Quit" goto :Quit
if /I "%input01%"=="Stop" goto :STOP
if %input01%==0 goto :NOW
if %ExVal01%==0 goto :INVALID
if %input01% LSS 0 goto :INVALID
C:\Windows\System32\shutdown /s /t %ExVal01% 2>NUL
if ERRORLEVEL 1190 (echo    Rescheduled to shutdown in %input01% mins.
C:\Windows\System32\shutdown /a
C:\Windows\System32\shutdown /s /t %ExVal01%
) ELSE (echo    Shutting down in %input01% mins.
)
Timeout 10
goto :MAIN
:QUIT
Echo    Quiting the Program.
pause
:EOF: