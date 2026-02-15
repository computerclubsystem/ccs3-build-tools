set VERSION=%1



if "%1"=="" (
  echo You must provide a version number.
  echo Usage: push-all.cmd 1.2.3
  exit /b 1 
)


docker rmi computerclubsystem/operator-connector:dev computerclubsystem/operator-connector:%VERSION%
docker rmi computerclubsystem/pc-connector:dev computerclubsystem/pc-connector:%VERSION%
docker rmi computerclubsystem/state-manager:dev computerclubsystem/state-manager:%VERSION%
docker rmi computerclubsystem/qrcode-signin:dev computerclubsystem/qrcode-signin:%VERSION%
docker rmi computerclubsystem/static-files-service:dev computerclubsystem/static-files-service:%VERSION%
docker rmi computerclubsystem/client-app:dev
docker rmi computerclubsystem/client-app-windows-service:dev
docker rmi computerclubsystem/client-app-bootstrap-windows-service:dev
docker rmi computerclubsystem//operator-web-app-static-files:dev
docker rmi computerclubsystem//qrcode-signin-web-app-static-files:dev


docker system prune -f
docker image prune -a
