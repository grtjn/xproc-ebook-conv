@echo off

del /q nl\grtjn\xproc\util\osutils\*.class

javac -cp ..\lib\calabash.jar nl\grtjn\xproc\util\osutils\*.java
if errorlevel 1 goto error

jar cvf ..\lib\grtjn-xproc-utils.jar nl\grtjn\xproc\util\osutils\*.class
goto done

:error
echo Fail..
goto end

:done
echo Done..
goto end

:end
