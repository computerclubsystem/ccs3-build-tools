set VERSION=%1
set BUILD_DELAY=5
set STARTTIME=%TIME%


if "%1"=="" (
  echo You must provide a version number.
  echo Usage: build-all.cmd 1.2.3
  exit /b 1 
)


REM Ccs3ClientAppBootstrapWindowsService
call :cdOrFail ccs3-windows-apps\Ccs3ClientAppBootstrapWindowsService\Ccs3ClientAppBootstrapWindowsService
call docker buildx build --load -t computerclubsystem/client-app-bootstrap-windows-service:dev -f Dockerfile .
if errorlevel 1 exit /b %errorlevel%
cd ..\..\..


timeout /t %BUILD_DELAY% >nul


REM Ccs3ClientAppWindowsService
call :cdOrFail ccs3-windows-apps\Ccs3ClientAppWindowsService\Ccs3ClientAppWindowsService
call docker buildx build --load -t computerclubsystem/client-app-windows-service:dev -f Dockerfile .
if errorlevel 1 exit /b %errorlevel%
cd ..\..\..


timeout /t %BUILD_DELAY% >nul


REM Ccs3ClientApp
call :cdOrFail ccs3-windows-apps\Ccs3ClientApp\Ccs3ClientApp
call docker buildx build --load -t computerclubsystem/client-app:dev -f Dockerfile .
if errorlevel 1 exit /b %errorlevel%
cd ..\..\..


timeout /t %BUILD_DELAY% >nul


REM ccs3-operator
call :cdOrFail ccs3-operator
call npm run update-version -- %VERSION%
if errorlevel 1 exit /b %errorlevel%
call npm run build-image
if errorlevel 1 exit /b %errorlevel%
cd ..


timeout /t %BUILD_DELAY% >nul


REM ccs3-qrcode-signin
call :cdOrFail ccs3-qrcode-signin
call npm run update-version -- %VERSION%
if errorlevel 1 exit /b %errorlevel%
call npm run build-image
if errorlevel 1 exit /b %errorlevel%
cd ..


timeout /t %BUILD_DELAY% >nul


REM Update backend versions
call :cdOrFail ccs3-backend
call npm run update-version -- %VERSION%
if errorlevel 1 exit /b %errorlevel%


timeout /t %BUILD_DELAY% >nul


REM static-files-service
call :cdOrFail devops
call docker buildx build --load -t computerclubsystem/static-files-service:dev -f Dockerfile.static-files-service ./static-files-service
if errorlevel 1 exit /b %errorlevel%
cd ..


timeout /t %BUILD_DELAY% >nul


REM operator-connector
call docker buildx build --load -t computerclubsystem/operator-connector:dev -f devops/Dockerfile.operator-connector .


timeout /t %BUILD_DELAY% >nul


REM pc-connector
call docker buildx build --load -t computerclubsystem/pc-connector:dev -f devops/Dockerfile.pc-connector .


timeout /t %BUILD_DELAY% >nul


REM qrcode-signin
call docker buildx build --load -t computerclubsystem/qrcode-signin:dev -f devops/Dockerfile.qrcode-signin .


timeout /t %BUILD_DELAY% >nul


REM state-manager
call docker buildx build --load -t computerclubsystem/state-manager:dev -f devops/Dockerfile.state-manager .



cd ..

echo Started at: %STARTTIME%
echo Ended at: %TIME%

goto :eof



:cdOrFail 
if not exist "%~1" ( 
  echo Directory "%~1" not found
  exit /b 1
  goto :eof
)
cd "%~1" || ( 
  echo Failed to cd into "%~1" 
  exit /b 1
  goto :eof
)