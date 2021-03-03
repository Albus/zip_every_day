@echo off & setlocal EnableDelayedExpansion & pushd & set "WORK_DIR=%~dp0"
set "WORK_DIR=%WORK_DIR:~0,-1%" & cd /d "%WORK_DIR%" & chcp 65001 > nul

:parse
    if    "%~1"==""       goto:validate
    :: источник данных (папка или файл) для архивации
    if /i "%~1"=="-src"  set "FLDR_SRC=%~f2"    & shift & shift & goto:parse
    :: имя файла архива (расширение не имеет значения, все равно будет zip)
    if /i "%~1"=="-name" set "FILE_NAME=%~dpn2" & shift & shift & goto:parse
    :: начало периода выборки файлов (по дате создания), попадает в период выборки
    if /i "%~1"=="-tac"  set "PERIOD_A=%~2"     & shift & shift & goto:parse
    :: окончание периода выборки файлов (по дате создания), не попадает в период выборки
    if /i "%~1"=="-tbc"  set "PERIOD_B=%~2"     & shift & shift & goto:parse
    :: не выводить запрос на продолжение работы после вывода настроек архивации
    if /i "%~1"=="--y"   set "YES=TRUE"         & shift &         goto:parse
    shift & goto:parse

:validate
    if not defined FLDR_SRC  call lib.cmd echo red "Param -src  not found" & goto:eof
    if not defined FILE_NAME call lib.cmd echo red "Param -name not found" & goto:eof
    if not defined PERIOD_A  call lib.cmd echo red "Param -tac  not found" & goto:eof
    if not defined PERIOD_B  call lib.cmd echo red "Param -tbc  not found" & goto:eof

set "FILE_STD_OUT=%FILE_NAME%.stdout.log"
set "FILE_STD_ERR=%FILE_NAME%.stderr.log"

set "LOG_FILES=%FILE_NAME%.files.log"
set "LOG_ERROR=%FILE_NAME%.error.log"

set "FILE_ZIP=%FILE_NAME%.zip"
set "FLDR_TMP=%WORK_DIR%\tmp"

set "CMD=m"
set "KEYS=-r -cfg- -@ -ep1 -y -ibck -idv -isnd- -scF -dh -ai -m1 -mt4 -o- -qo+ -ri0:10 -rr10  -tl -tsm1 -tsc1 -tsa- -tsp"
:: Тут пишем параметры периода выборки файлов (пример: -tac20191201 -tbc20200101)
set "PERIOD=-tac%PERIOD_A% -tbc%PERIOD_B%"
set CMD="C:\Program Files\WinRAR\WinRAR.exe" %CMD% %KEYS% %PERIOD% -logFU="%LOG_FILES%" -ilog"%LOG_ERROR%" -w"%FLDR_TMP%" -- "%FILE_ZIP%" "%FLDR_SRC%"

set "LOGS="%LOG_FILES%","%LOG_ERROR%","%FILE_STD_OUT%","%FILE_STD_ERR%""

call:delim & set WORK_DIR & set FLDR_TMP
call:delim & set FLDR_SRC & set FILE_ZIP
call:delim & set PERIOD_A & set PERIOD_B
call:delim & set FILE_STD_OUT & set FILE_STD_ERR
call:delim & set LOG_FILES & set LOG_ERROR
call:delim & set CMD
call:delim

if not defined YES ( goto:choice ) else ( goto:begin )

:choice
    call lib.cmd echo yellow "Are you sure you want to continue ?" & set /p choice=[Y/N]?
        if /i "%choice%" EQU "Y" goto:begin
        if /i "%choice%" EQU "N" goto:finish
    goto:choice

:begin
    call:clean & call:start 1>"%FILE_STD_OUT%" 2>"%FILE_STD_ERR%"

:finish
    call:hide_logs & popd & endlocal & goto:eof

:start
    if exist "%FILE_ZIP%" attrib +h -r -a -s "%FILE_ZIP%"
    call:timestamp & echo %CMD% & %CMD%
    echo.%CMD%>"%FILE_ZIP%:cmd" & echo.%LOGS%>"%FILE_ZIP%:logs"
    if not ERRORLEVEL 0 ( echo ERROR ERRORLEVEL with %CMDCMDLINE% >>&2 ) else ( echo EVERYTHING FINE )
    if exist "%LOG_ERROR%" echo Check %LOG_ERROR% >>&2
    call:timestamp & if exist "%FILE_ZIP%" attrib -h +r -a -s "%FILE_ZIP%"
exit /b

:timestamp
    echo %DATE%%TIME%
exit /b

:clean
    call:unhide_logs
    if not exist "%FLDR_TMP%" mkdir "%FLDR_TMP%" > nul
    for %%F in (%LOGS%) do ( if exist %%F del /f %%F )
exit /b

:delim
    call lib.cmd echo dark_blue " ------------------------------------------------------------------------------"
exit /b

:hide_logs
    for %%F in (%LOGS%) do ( if exist %%F attrib +h +r -a -s %%F )
exit /b

:unhide_logs
    for %%F in (%LOGS%) do ( if exist %%F attrib -h -r -a -s %%F )
exit /b
