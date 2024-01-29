#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0}\docker;{1}' -f $env:ProgramFiles, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

ENV DOCKER_VERSION 25.0.0-beta.1
ENV DOCKER_URL https://download.docker.com/win/static/test/x86_64/docker-25.0.0-beta.1.zip
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN Write-Host ('Downloading {0} ...' -f $env:DOCKER_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_URL -OutFile 'docker.zip'; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive docker.zip -DestinationPath $env:ProgramFiles; \
# (this archive has a "docker/..." directory in it already)
	\
	Write-Host 'Removing ...'; \
	Remove-Item @( \
			'docker.zip', \
			('{0}\docker\dockerd.exe' -f $env:ProgramFiles) \
		) -Force; \
	\
	Write-Host 'Verifying install ("docker --version") ...'; \
	docker --version; \
	\
	Write-Host 'Complete.';

# https://github.com/docker-library/docker/issues/409#issuecomment-1462868414
ENV DOCKER_BUILDX_VERSION 0.11.2
ENV DOCKER_BUILDX_URL https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.windows-amd64.exe
ENV DOCKER_BUILDX_SHA256 d9419c0838c8a08c2da28fcee585f48926c4dd64e5be1d96eb55da12fa3332d9
RUN $dir = ('{0}\docker\cli-plugins' -f $env:ProgramFiles); \
	Write-Host ('Creating {0} ...' -f $dir); \
	New-Item -ItemType Directory $dir -Force; \
	\
	$plugin = ('{0}\docker-buildx.exe' -f $dir); \
	Write-Host ('Downloading {0} ...' -f $env:DOCKER_BUILDX_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_BUILDX_URL -OutFile $plugin; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:DOCKER_BUILDX_SHA256); \
	if ((Get-FileHash $plugin -Algorithm sha256).Hash -ne $env:DOCKER_BUILDX_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Verifying install ("docker buildx version") ...'; \
	docker buildx version; \
	\
	Write-Host 'Complete.';
ENV DOCKER_COMPOSE_VERSION 2.23.0
ENV DOCKER_COMPOSE_URL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-windows-x86_64.exe
ENV DOCKER_COMPOSE_SHA256 254a2770f208d11cd131b89758c9810650521cce2e831e7478d6418e8baea3da
RUN $dir = ('{0}\docker\cli-plugins' -f $env:ProgramFiles); \
	Write-Host ('Creating {0} ...' -f $dir); \
	New-Item -ItemType Directory $dir -Force; \
	\
	$plugin = ('{0}\docker-compose.exe' -f $dir); \
	Write-Host ('Downloading {0} ...' -f $env:DOCKER_COMPOSE_URL); \
	Invoke-WebRequest -Uri $env:DOCKER_COMPOSE_URL -OutFile $plugin; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:DOCKER_COMPOSE_SHA256); \
	if ((Get-FileHash $plugin -Algorithm sha256).Hash -ne $env:DOCKER_COMPOSE_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Verifying install ("docker compose version") ...'; \
	docker compose version; \
	\
	$link = ('{0}\docker\docker-compose.exe' -f $env:ProgramFiles); \
	Write-Host ('Linking {0} to {1} ...' -f $plugin, $link); \
	New-Item -ItemType SymbolicLink -Path $link -Target $plugin; \
	\
	Write-Host 'Verifying install ("docker-compose --version") ...'; \
	docker-compose --version; \
	\
	Write-Host 'Complete.';
