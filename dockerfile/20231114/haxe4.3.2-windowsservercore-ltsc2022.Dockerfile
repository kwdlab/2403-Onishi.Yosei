#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV HAXETOOLKIT_PATH C:\\HaxeToolkit
ENV NEKOPATH $HAXETOOLKIT_PATH\\neko
ENV HAXEPATH $HAXETOOLKIT_PATH\\haxe
ENV HAXE_STD_PATH $HAXEPATH\\std
ENV HAXELIB_PATH $HAXEPATH\\lib

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0};{1};{2}' -f $env:HAXEPATH, $env:NEKOPATH, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

# haxelib.exe needs msvcr120.dll
RUN $url = 'https://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x86.exe'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'vcredist_x86.exe'; \
	\
	Write-Host 'Verifying sha256 (89f4e593ea5541d1c53f983923124f9fd061a1c0c967339109e375c661573c17) ...'; \
	if ((Get-FileHash vcredist_x86.exe -Algorithm sha256).Hash -ne '89f4e593ea5541d1c53f983923124f9fd061a1c0c967339109e375c661573c17') { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Installing ...'; \
	Start-Process -FilePath "vcredist_x86.exe" -ArgumentList "/Q" -Wait; \
	\
	Write-Host 'Removing installer...'; \
	Remove-Item .\vcredist_x86.exe; \
	\
	Write-Host 'Complete.';

RUN New-Item -ItemType directory -Path $env:HAXETOOLKIT_PATH;

# install neko, which is a dependency of haxelib
ENV NEKO_VERSION 2.3.0
RUN $url = 'https://github.com/HaxeFoundation/neko/releases/download/v2-3-0/neko-2.3.0-win64.zip'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'neko.zip'; \
	\
	Write-Host 'Verifying sha256 (d09fdf362cd2e3274f6c8528be7211663260c3a5323ce893b7637c2818995f0b) ...'; \
	if ((Get-FileHash neko.zip -Algorithm sha256).Hash -ne 'd09fdf362cd2e3274f6c8528be7211663260c3a5323ce893b7637c2818995f0b') { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	New-Item -ItemType directory -Path tmp; \
	Expand-Archive -Path neko.zip -DestinationPath tmp; \
	if (Test-Path tmp\neko.exe) { Move-Item tmp $env:NEKOPATH } \
	else { Move-Item (Resolve-Path tmp\neko* | Select -ExpandProperty Path) $env:NEKOPATH }; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item -Path neko.zip, tmp -Force -Recurse -ErrorAction Ignore; \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  neko -version'; neko -version; \
	\
	Write-Host 'Complete.';

# install haxe
ENV HAXE_VERSION 4.3.2
RUN $url = 'https://github.com/HaxeFoundation/haxe/releases/download/4.3.2/haxe-4.3.2-win64.zip'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile haxe.zip; \
	\
	Write-Host 'Verifying sha256 (194276aa37e19945e7d993145b2c9442777f8047e78038147a684d1fb7e8e9df) ...'; \
	if ((Get-FileHash haxe.zip -Algorithm sha256).Hash -ne '194276aa37e19945e7d993145b2c9442777f8047e78038147a684d1fb7e8e9df') { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	New-Item -ItemType directory -Path tmp; \
	Expand-Archive -Path haxe.zip -DestinationPath tmp; \
	if (Test-Path tmp\haxe.exe) { Move-Item tmp $env:HAXEPATH } \
	else { Move-Item (Resolve-Path tmp\haxe* | Select -ExpandProperty Path) $env:HAXEPATH }; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item -Path haxe.zip, tmp -Force -Recurse -ErrorAction Ignore; \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  haxe -version'; haxe -version; \
	Write-Host '  haxelib version'; haxelib version; \
	\
	Write-Host 'Complete.';

RUN New-Item -ItemType directory -Path $env:HAXELIB_PATH;

# haxelib bundled in haxe 3.2 and below depends on these variables
ENV HOMEDRIVE C:
RUN $newPath = ('{0}\Users\{1}' -f $env:HOMEDRIVE, $env:USERNAME); \
	Write-Host ('Updating HOMEPATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('HOMEPATH', $newPath, [EnvironmentVariableTarget]::Machine);

# Make a request to lib.haxe.org,
# such that Windows fetches the certs, which can then used by haxelib.
RUN (New-Object System.Net.WebClient).DownloadString('https://lib.haxe.org/p/hxcpp/4.2.1/download/') >$null

CMD ["haxe"]
