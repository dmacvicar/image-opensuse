NAME =			opensuse
VERSION =		latest
VERSION_ALIASES =	harlequin 13.2
TITLE =			openSUSE 13.2
DESCRIPTION =		openSUSE 13.2 (Harlequin)
SOURCE_URL =		https://github.com/scaleway/image-opensuse

IMAGE_VOLUME_SIZE =	50G
IMAGE_BOOTSCRIPT =	stable
IMAGE_NAME =		openSUSE 13.2

## Image tools  (https://github.com/scaleway/image-tools)
all:    docker-rules.mk
docker-rules.mk:
	wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
