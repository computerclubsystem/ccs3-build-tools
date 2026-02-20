# ComputerClubSystem build tools

## Build all images with specific version
Execute the following by changing the version `1.2.3` to the real version (the parameters `DockerIdleSeconds` and `SleepSeconds` are optional - they are just to give some time to BuildKit to clean-up after each build to avoid build failures under heavy load):
```bash
powershell -ExecutionPolicy Bypass -File build-all.ps1 -Version 1.2.3 -DockerIdleSeconds 3 -SleepSeconds 2
```
Or first start PowerShell and then:
```bash
.\build-all.ps1 -Version 1.2.3 -DockerIdleSeconds 3 -SleepSeconds 2
```

## Clean images
```bash
powershell -ExecutionPolicy Bypass -File cleanup-images.ps1 -Version 1.2.3
```