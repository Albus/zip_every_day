@echo off & chcp 65001 > nul & call:%* & goto:eof



:normalize_path
    :: Нормализует путь файловой системы
    :: Параметры: VAR "PATH"
    ::            - VAR  [out] - имя переменной, в которую нужно пометсть результат
    ::            - PATH [in]  - путь файловой системы
    set "%~1=%~f2"
exit /b



:echo
    :: Выводит сообщение
    :: Параметры: COLOR "MESSAGE"
    ::            - COLOR   [in] - цвет собщения
    ::            - MASSAGE [in] - текст сообщения

    if exist "%WORK_DIR%\bin\cecho.exe" (
        "%WORK_DIR%\bin\cecho.exe" %~1 "%~2"
    ) else ( echo %~2 )

exit /b



:jdate2date
    :: converts julian days to gregorian date format
    :: Параметры: JD YYYY MM DD
    ::            - JD   [in]  - julian days
    ::            - YYYY [out] - gregorian year, i.e. 2006
    ::            - MM   [out] - gregorian month, i.e. 12 for december
    ::            - DD   [out] - gregorian day, i.e. 31

    setlocal EnableDelayedExpansion & chcp 1252 > nul
    set /a "L= %~1+68569,     N= 4*L/146097, L= L-(146097*N+3)/4, I= 4000*(L+1)/1461001"
    set /a "L= L-1461*I/4+31, J= 80*L/2447,  K= L-2447*J/80,      L= J/11"
    set /a "J= J+2-12*L,      I= 100*(N-49)+I+L"
    set /a "YYYY= I,  MM=100+J,  DD=100+K"
    set "MM=%MM:~-2%"
    set "DD=%DD:~-2%"
    ( endlocal & :: RETURN VALUES
        if "%~2" neq "" (set "%~2=%YYYY%") else echo.%YYYY%
        if "%~3" neq "" (set "%~3=%MM%"  ) else echo.%MM%
        if "%~4" neq "" (set "%~4=%DD%"  ) else echo.%DD%
    )

exit /b



:jdate
    :: converts a date string to julian day number with respect to regional date format
    :: Параметры: JD DateStr
    ::            - JD      [out,opt] - julian days
    ::            - DateStr [in,opt]  - date string, e.g. "03/31/2006" or "Fri 03/31/2006" or "31.3.2006"

    setlocal & chcp 1252 > nul
    set "DateStr=%~2"
    if "%~2"=="" set "DateStr=%date%"
    for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
        for /f "tokens=1-3 delims=/.- " %%A in ("%DateStr:* =%") do (
            set %%a=%%A&set %%b=%%B&set %%c=%%C
    )   )
    set /a "yy=10000%yy% %%10000,mm=100%mm% %% 100,dd=100%dd% %% 100"
    if %yy% LSS 100 set /a "yy+=2000 &rem Adds 2000 to two digit years"
    set /a "JD=dd-32075+1461*(yy+4800+(mm-14)/12)/4+367*(mm-2-(mm-14)/12*12)/12-3*((yy+4900+(mm-14)/12)/100)/4"
    endlocal & if "%~1" neq "" (set "%~1=%JD%") else (echo.%JD%)

exit /b
