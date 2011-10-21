@echo off

if [%1]==[] goto usage
set INPUTFILE=%1
shift

rem del /q /s log\
rem del /q /s out\
rem del /q /s tmp\

rem set PROXY=-Dhttp.proxyHost=172.22.7.16 -Dhttp.proxyPort=8080

set CMD=java -cp .;lib\resolver.jar;lib\calabash-0.9.35.jar;lib\grtjn-xproc-utils.jar %PROXY% -Dcom.xmlcalabash.phonehome=false -Djava.util.logging.config.file=logging.properties com.xmlcalabash.drivers.Main -D -E org.apache.xml.resolver.tools.CatalogResolver -U org.apache.xml.resolver.tools.CatalogResolver -c lib/grtjn-xproc-utils.xml -i source=%INPUTFILE% src\nl\grtjn\xproc\ebook\main.xpl %1 %2 %3 %4 %5 %6 %7 %8 %9
echo %CMD%
%CMD%
if errorlevel 1 goto error
goto done

:usage
echo.
echo Usage:
echo     %0 {ebook-layout.xml} ["{option}={value}"]*
echo.
echo Options:
echo - debug            (false^|true)              [default: false]
echo - output-method    (epub^|pdf)                [default: epub]
echo - output-style     (#default^|dbnl^|medieval) [default: #default]
echo - verbose          (false^|true)              [default: true]
echo.
goto end

:error
echo Aborted..
goto end

:done
echo Done..
goto end

:end
