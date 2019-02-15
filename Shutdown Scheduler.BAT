::20180618
::JimmyWilliams
::Description: This program allows users to schedule a future shutdown, and cancel them.
::
::Bug:
::	If shutdown is scheduled far into the future, and then computer is shutdown before this scheduled shutdown
::	Program will continue to say the future date even though it is no longer scheduled.
::	Remove by typing "Stop" or entering new shutdown.
::Warning: Does not show the timer when shutdown will occur.

@echo off
setlocal enabledelayedexpansion
::Checks to make sure that WMIC.EXE exists, to get date and time (independent of how the computer's time is displayed/region settings).
cls
WMIC.EXE Alias /? >NUL 2>&1 || GOTO Exe_DNE_Error
goto :CURRENT

:Exe_DNE_Error
Echo    WMIC.EXE is not installed; this program cannot obtain dates and times to show when a shutdown is scheduled until this EXE is available.
pause
goto :QUIT

:INVALID
Echo X = "%input01%" is invalid.
timeout 5
goto :CURRENT

:NOW
C:\Windows\System32\shutdown /s
Echo    Shutting down now.
Echo    You have a few seconds to type "Stop", if you wish.
timeout 5
goto :CURRENT

:STOP
Echo    Attempting to stop any Scheduled Shutdowns.
Echo/
C:\Windows\System32\shutdown /a 2>NUL
if NOT ERRORLEVEL 1116 (Echo    Scheduled shutdown stopped.) ELSE (
Echo    Unable to abort the system because no shutdown was in progress (1116^)
)
If EXIST "%~dp0Schdule Scheduler(TEMP).txt" del "%~dp0Schdule Scheduler(TEMP).txt"
timeout 5
goto :RESETSCHEDULE

:TOOLARGE
Echo X = "%input01%" is invalid.
Echo X must be less than 5256000 (10 years).
timeout 5
goto :CURRENT

:CURRENT
:: Use WMIC to retrieve current date and time.
:: Compares current time and date to the Scheduled shutdown within "Schdule Scheduler(TEMP).txt"
FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
   IF "%%~L"=="" goto s_done
      Set _yyyy=%%L
      Set _mm=00%%J
      Set _dd=00%%G
      Set _hr=00%%H
      Set _mi=00%%I
)
:s_done

:: Pad digits with leading zeros
Set _mm=%_mm:~-2%
Set _dd=%_dd:~-2%
Set _hr=%_hr:~-2%
Set _mi=%_mi:~-2%

:: Display the date/time in ISO 8601 format:
Set _isodate=%_yyyy%-%_mm%-%_dd% %_hr%:%_mi%
If EXIST "%~dp0Schdule Scheduler(TEMP).txt" goto :SCHEDULECHECKER
goto :RESETSCHEDULE

:SCHEDULECHECKER
set /p PulledDate=<"%~dp0Schdule Scheduler(TEMP).txt"
Set _ySch=%PulledDate:~0,4%
Set _mthS=%PulledDate:~5,2%
Set _dSch=%PulledDate:~8,2%
Set _hSch=%PulledDate:~11,2%
Set _mSch=%PulledDate:~14,2%
Set _dateSch=%_ySch%-%_mthS%-%_dSch% %_hSch%:%_mSch%

If /I %_ySch% LSS %_yyyy% goto :RESETSCHEDULE
If /I %_ySch% EQU %_yyyy% If /I %_mthS% LSS %_mm% goto :RESETSCHEDULE
If /I %_ySch% EQU %_yyyy% If /I %_mthS% EQU %_mm% If /I %_dSch% LSS %_dd% goto :RESETSCHEDULE
If /I %_ySch% EQU %_yyyy% If /I %_mthS% EQU %_mm% If /I %_dSch% EQU %_dd% If /I %_hSch% LSS %_hr% goto :RESETSCHEDULE
If /I %_ySch% EQU %_yyyy% If /I %_mthS% EQU %_mm% If /I %_dSch% EQU %_dd% If /I %_hSch% EQU %_hr% If /I %_mSch% LSS %_mi% goto :RESETSCHEDULE
goto :MAIN

:RESETSCHEDULE
If EXIST "%~dp0Schdule Scheduler(TEMP).txt" del "%~dp0Schdule Scheduler(TEMP).txt"
Set "_ySch="
Set "_mthS="
Set "_dSch="
Set "_hSch="
Set "_mSch="
Set "_dateSch="
goto :MAIN

:MAIN
cls
if "%_dateSch%"=="" (set _dateSch1=No Scheduled Shutdown.) ELSE (
Set _dateSch1=%_dateSch%
)
set "input01="
set "ExVal01="
Echo JimmyWilliams - 20180618
Echo/
Echo This will cause the computer to automatically shutdown in X minutes,
Echo and will override any existing scheduled shutdown.
Echo/
Echo Current clock time is: %_isodate%
Echo Shutdown scheduled at: %_dateSch1%
Echo/
Echo Enter "X = Stop", cancel any currently active future shutdown.
Echo Enter "X = Quit", to close this program.
Echo/
Set /p "input01=1. Enter a whole positive number: X = "
if "%input01%"=="" goto :INVALID
Set /a ExVal01="%input01%"*60
if /I "%input01%"=="Quit" goto :QUIT
if /I "%input01%"=="Stop" goto :STOP
if /I %input01% GEQ 5256000 GOTO :TOOLARGE
if %input01%==0 goto :NOW
if %ExVal01%==0 goto :INVALID
if %input01% LSS 0 goto :INVALID
C:\Windows\System32\shutdown /s /t %ExVal01% 2>NUL
if ERRORLEVEL 1190 (echo    Rescheduled to shutdown to %input01% mins from now.
C:\Windows\System32\shutdown /a
C:\Windows\System32\shutdown /s /t %ExVal01%
) ELSE (echo    Shutdown to %input01% mins from now.
)
Set /a _mSch=input01+_mi
Set /a _hSch=_mSch/60
Set /a _mSch=_mSch%%60
Set /a _hSch=_hSch+_hr
Set /a _dSch=_hSch/24
Set /a _hSch=_hSch%%24
Set /a _dSch=_dSch+_dd
pause
goto :FEB

:FEB
::Tests to see if the month of Feburary is a leap year for that year or not.
Set /a test1=_yyyy%%4
Set /a test2=_yyyy%%100
Set /a test3=_yyyy%%400
Set /a test4="" 2>NUL
if /I %_mm% EQU 2 (
if /I %test1% EQU 0 (
if /I %test2% EQU 0 (
if /I %test3% EQU 0 (Set /a test4=29) ELSE (Set /a test4=28)
) ELSE (Set /a test4=29)
) ELSE (Set /a test4=28)

GOTO :MYBREAK
)
GOTO :MONTH31

:MONTH31
FOR %%G IN (1 3 5 7 8 10 12) DO (
if /I %_mm% EQU %%G (Set /a test4=31
GOTO :MYBREAK)
)
Set /a test4=30
GOTO :MYBREAK

:MYBREAK
if /I %_dSch% GTR %test4% (
Set /a _dSch=_dSch-test4
if /I %_mm% EQU 12 (
Set /a _yyyy=_yyyy+1
Set /a _mm=1
) ELSE (Set /a _mm=_mm+1)

GOTO :FEB
)
Set "_mSch=00%_mSch%
Set _mSch=%_mSch:~-2%
Set "_hSch=00%_hSch%
Set _hSch=%_hSch:~-2%
Set "_dSch=00%_dSch%
Set _dSch=%_dSch:~-2%
Set "_mm=00%_mm%"
Set _mm=%_mm:~-2%
:: Display the date/time in ISO 8601 format:
Set _isodate=%_yyyy%-%_mm%-%_dSch% %_hSch%:%_mSch%
> "%~dp0Schdule Scheduler(TEMP).txt" Echo %_yyyy%-%_mm%-%_dSch% %_hSch%:%_mSch%
Goto :CURRENT

:QUIT
Echo    Quiting the Program.
pause
:EOF: