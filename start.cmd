@echo off & setlocal EnableDelayedExpansion & chcp 65001 > nul

call lib.cmd jdate DATE_NOW

:parse
    :: Дата оканчания периода архивации (31.01.2020), по умолчанию сегодняшний день
    if /i "%~1"=="--date" call lib.cmd jdate DATE_START "%~2" & shift & shift & goto:parse
    :: Количество дней которые необходимо пропустить с даты окончания архивации (реверсивно), по умолчанию 1 день
    :: к примеру дата архивации 15.01.2020, пропускаем 5 дней - дата архивации будет установлена на 10.01.2020
    if /i "%~1"=="--skip" set "SKIP=%~2"              & shift & shift & goto:parse
    :: Количество дней периода архивации (30), по умолчанию 1 день
    if /i "%~1"=="--days" set "DAYS=%~2"              & shift & shift & goto:parse
    :: Папка назначения, будет создана структура yyyy\mm\file.zip
    if /i "%~1"=="-dest"  set "DEST=%~f2"             & shift & shift & goto:parse
    :: Папка источник
    if /i "%~1"=="-src"   set "SRC=%~f2"              & shift & shift & goto:parse
    if    "%~1"==""       goto:validate               & shift &         goto:parse

:validate
    if not defined SKIP       set "SKIP=0"
    if not defined DAYS       set "DAYS=1"
    if not defined DATE_START set "DATE_START=%DATE_NOW%"
    if not defined DEST       call lib.cmd echo red "Param -dest not found" & goto:eof
    if not defined SRC        call lib.cmd echo red "Param -src  not found" & goto:eof

set /a "DATE_START=%DATE_START%-%SKIP%+1"
set /a "DATE_FINISH=%DATE_START%-%DAYS%+1"

for /l %%D in (%DATE_START%,-1,%DATE_FINISH%) do (
    call lib.cmd jdate2date %%D TBC_YYYY TBC_MM TBC_DD
    call lib.cmd jdate2date %%D-1 TAC_YYYY TAC_MM TAC_DD
    set "NAME=!TAC_YYYY!_!TAC_MM!_!TAC_DD!"
    set "DEST=%DEST%\!TAC_YYYY!\!TAC_MM!\!NAME!"
    call lib.cmd normalize_path DEST "!DEST!"
    2>nul mkdir "!DEST!"
    call "archive.cmd" -src "%SRC%" -name "!DEST!" -tac !TAC_YYYY!!TAC_MM!!TAC_DD! -tbc !TBC_YYYY!!TBC_MM!!TBC_DD!
    echo.
)

endlocal & goto:eof
