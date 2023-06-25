#!/bin/bash

# Env Vars
PROGRESS_FILE=~/Library/d3d12_rosetta_installstages.txt
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SUPPORTED='\033[1;32m'
UNSUPPORTED='\033[1;31m'
UNKNOWN='\033[1;33m'
NC='\033[0m'

TOOLKIT_PATH="Downloads/Game_porting_toolkit_beta.dmg"
TOOLKIT_MOUNT_POINT="/tmp/d3d12_toolkit"
XCODE_CMDL_PATH="Downloads/Command_Line_Tools_for_Xcode_15_beta.dmg"
XCODE_CMDL_MOUNT_POINT="/tmp/d3d12_xcode"

source langs/en.env
if [[ "$*" == *--kr* ]]; then
    source langs/kr.env
fi

echo "#######Script Release#######"
echo "Script Written: 2023-June-09 EDT"
echo "Script Updated: 2023-June-24 EDT"
echo "Tested on: macOS 14.0 Developer Beta 2"
echo "############################"
echo ""
echo "#######Disclaimer / 경고#######"
echo "This script is written by 410-dev, and is not affiliated with Apple Inc. or any other company."
echo "This script will allow you to run some Windows games on macOS, but it is not guaranteed to work on all games and performance."
echo "This script is provided as-is, and the author is not responsible for any damage caused by this script."
echo "이 스크립트는 410-dev가 작성한 것으로, Apple Inc. 나 다른 회사와 관련이 없습니다."
echo "이 스크립트는 macOS에서 일부 Windows 게임을 실행할 수 있게 해주지만, 모든 게임에서 작동 여부 및 성능을 보장하지는 않습니다."
echo "이 스크립트는 그대로 제공되며, 작성자는 이 스크립트로 인해 발생하는 모든 손해에 대해 책임지지 않습니다."
echo "##############################"
echo ""
echo "$SCRIPT_DOC_INFO"
echo "https://www.applegamingwiki.com/wiki/Game_Porting_Toolkit"
echo ""
echo ""
echo "$D3D12EMU_START"
echo "$SYS_COMPAT_CHECK"

# If argument contains "--skip-version-check" then skip version check by adding environment variable
if [[ "$*" == *--skip-version-check* ]]; then
    export SKIP_VERSION_CHECK="1"
fi

# Copy the compatibility check script to tmp
cp subsh/compatchk.sh /tmp/compatchk.sh

# Copy the language directory to tmp
cp -r langs /tmp/langs

# Run the compatibility check script
chmod +x /tmp/compatchk.sh
/tmp/compatchk.sh "$@" --arm64
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "$FS_CHECK"
if [[ "$*" == *--reinstall* ]]; then
    echo "$REINSTALL_DETECTED"
    rm -f "$PROGRESS_FILE"
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "$NO_STATUS_FILE"
    echo "done:rosetta" > "$PROGRESS_FILE" 2>/dev/null
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo -e "${RED}$ERROR_STATUS_FILE_ACCESS${NC}"
    echo -e "${RED}$STAT_FILE_PATH $PROGRESS_FILE${NC}"
    echo -e "${RED}$RETRY_AFTER_DELETE${NC}"
    exit 1
fi
echo -e "${GREEN}$ACCESSIBLE_STATUS_FILE${NC}"

echo "$D3D12_EMU_RS_READY"

# 로제타2 설치 시작
ROSETTA=$(/usr/bin/pgrep -q oahd && echo Yes || echo No)
if [[ "$ROSETTA" == "No" ]] && [[ "$*" != *--skip-rosetta* ]]; then
    echo "$ROSETTA_NOT_INSTALLED"
    echo "$ROSETTA_INSTALL_START"
    softwareupdate --install-rosetta --agree-to-license
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$ROSETTA_INSTALL_FAILED${NC}"
        echo "$ROSETTA_SKIP_NOTIFY"
        echo "$ROSETTA_SKIP_COMMAND"
        exit 1
    fi
    echo -e "$STATUS_RECORDED"
    echo "done:rosetta" > "$PROGRESS_FILE"
    echo -e "${GREEN}$ROSETTA_INSTALL_DONE${NC}"
    echo -e "${GREEN}$DX12INSTALL_READY${NC}"
    echo "$RESTART_SCRIPT"
    exit 0
fi

VALUE=$(cat "$PROGRESS_FILE")

# 파일 다운로드 확인
if [[ "$VALUE" == "done:rosetta" ]]; then
    echo ""
    echo "$DOWNLOAD_FILE"
    echo "$DOWNLOAD_URL"
    echo "$DOWNLOAD_FILE_AFTER_LOGIN"
    echo "$DOWNLOAD_LIST"
    echo " - Command Line Tools for Xcode 15 beta"
    echo " - Game porting toolkit beta"
    echo ""
    echo "$DOWNLOAD_SAVE_WITHOUT_NAMEMOD"
    echo "$DOWNLOAD_THEN_PRESS_ENTER"
    read -r
    if [[ -f ~/"$XCODE_CMDL_PATH" ]]; then
        echo -e "${GREEN}$XCODE_CONFIRMED${NC}"
    else
        echo -e "${RED}$XCODE_NOT_FOUND${NC}"
        echo "$DOWNLOAD_AGAIN_THEN_RESTART"
        exit 1
    fi
    if [[ -f ~/"$TOOLKIT_PATH" ]]; then
        echo -e "${GREEN}$GAME_PORTING_TOOLKIT_CONFIRMED${NC}"
    else
        echo -e "${RED}$GAME_PORTING_TOOLKIT_NOT_FOUND${NC}"
        echo "$DOWNLOAD_AGAIN_THEN_RESTART"
        exit 1
    fi
    echo "$STATUS_RECORDED"
    echo "done:download-files" > "$PROGRESS_FILE"
fi

# Xcode 커맨드 라인 이미지 마운트
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:download-files" ]]; then
    echo "$IMAGE_MOUNTPOINT_GENERATE"
    mkdir -p "$XCODE_CMDL_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$IMAGE_MOUNTPOINT_GENERATE_FAILED${NC}"
        exit 1
    fi
    echo "$IMAGE_MOUNTING"
    hdiutil attach ~/"$XCODE_CMDL_PATH" -mountpoint "$XCODE_CMDL_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$XCODE_IMAGE_MOUNT_FAILED${NC}"
        exit 1
    fi
    echo -e "${GREEN}$XCODE_IMAGE_MOUNT_SUCCESS${NC}"
    echo "$STATUS_RECORDED"
    echo "done:mount-xcode" > "$PROGRESS_FILE"
fi

# Xcode 커맨드 라인 설치
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:mount-xcode" ]]; then
    echo "$XCODE_INSTALL_START"
    echo "$SUDO_REQUIRED"
    sudo installer -pkg "$XCODE_CMDL_MOUNT_POINT"/"Command Line Tools.pkg" -target /
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$XCODE_INSTALL_FAILED${NC}"
        exit 1
    fi
    echo -e "${GREEN}$XCODE_INSTALL_DONE${NC}"
    echo "$XCODE_DISMOUNT_START"
    hdiutil detach "$XCODE_CMDL_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}$XCODE_DISMOUNT_FAILED${NC}"
    fi
    echo "$STATUS_RECORDED"
    echo "done:unmount-xcode" > "$PROGRESS_FILE"
fi

# 보조 스크립트 실행
# 보조 스크립트는 x86_64 환경에서 실행됨
# x86 버전 홈브루 설치 과정
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:unmount-xcode" ]]; then
    echo "$SUBSCRIPT_EXEC_PREP"
    echo "$SUBSCRIPT_EXEC_PREP_RSCOPY"
    cp -r "$(dirname "$0")"/subsh/x86env_install.sh /tmp/
    echo "$SUBSCRIPT_IN_X8664"
    arch -x86_64 /tmp/x86env_install.sh "$@"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$SUBSCRIPT_FAILED${NC}"
        exit 1
    fi
    echo -e "${GREEN}$SUBSCRIPT_DONE${NC}"
    echo "$STATUS_RECORDED"
    echo "done:subshell-x86env" > "$PROGRESS_FILE"
fi

# Wine Prefix 설정
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:subshell-x86env" ]]; then
    echo "$WINE_PREFIX_SETTING"
    echo -e "${YELLOW}$WINE_PREFIX_SETTING_INSTRUCTION_FOLLOW${NC}"
    echo "$WINE_PREFIX_SETTING_INSTRUCTION"
    read
    echo "$WINE_PREFIX_QUIT_PRELOADER"
    if [[ $(pgrep -x wine64-preloader) ]]; then
        killall wine64-preloader
    fi
    echo "$WINE_PREFIX_QUIT_SERVER"
    if [[ $(pgrep -x wineserver) ]]; then
        killall wineserver
    fi
    echo "$WINE_PREFIX_WINDOW_OPEN"
    arch -x86_64 /bin/bash -c 'eval "$(/usr/local/bin/brew shellenv)"; WINEPREFIX=~/WindowsPrefix `brew --prefix game-porting-toolkit`/bin/wine64 winecfg'
    echo -e "${GREEN}$WINE_PREFIX_SETTING_DONE${NC}"
    echo "$STATUS_RECORDED"   
    echo "done:wine-prefix" > "$PROGRESS_FILE"
fi

# Game Port Toolkit 이미지 마운트
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:wine-prefix" ]]; then
    echo "$GPT_IMAGE_MOUNT_STAGE"
    echo "$GPT_IMAGE_MOUNT_CREATE"
    mkdir -p "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$GPT_IMAGE_MOUNT_CREATE_FAILED${NC}"
        exit 1
    fi
    echo "$GPT_IMAGE_MOUNT"
    hdiutil attach ~/"$TOOLKIT_PATH" -mountpoint "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$GPT_IMAGE_MOUNT_FAILED${NC}"
        exit 1
    fi
    echo -e "${GREEN}$GPT_IMAGE_MOUNT_DONE${NC}"
    echo "$STATUS_RECORDED"
    echo "done:mount-gameport" > "$PROGRESS_FILE"
fi

# Ditto 실행
# x86 버전에서 실행됨
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:mount-gameport" ]]; then
    echo "$DITTO_STAGE"
    echo "$DITTO_HELPER_SCRIPT_COPY"
    cp -r "$(dirname "$0")"/subsh/x86env_ditto.sh /tmp/
    echo "$DITTO_HELPER_IN_8664"
    arch -x86_64 /tmp/x86env_ditto.sh "$TOOLKIT_MOUNT_POINT" "$@"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$DITTO_HELPER_FAILED${NC}"
        exit 1
    fi
    echo -e "${GREEN}$DITTO_HELPER_DONE${NC}"
    echo "$STATUS_RECORDED"
    echo "done:ditto" > "$PROGRESS_FILE"
fi

# Toolkit 명령어 복사
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:ditto" ]]; then
    echo "$TOOLKIT_COPY_STAGE"
    echo "$TOOLKIT_COPY"
    cp -vr "$TOOLKIT_MOUNT_POINT"/gameportingtoolkit* /usr/local/bin/
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$TOOLKIT_COPY_FAILED${NC}"
        exit 1
    fi
    echo -e "${GREEN}$TOOLKIT_COPY_DONE${NC}"
    echo "$STATUS_RECORDED"
    echo "done:copy-toolkit" > "$PROGRESS_FILE"
fi

# Toolkit 이미지 마운트 해제
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:copy-toolkit" ]]; then
    echo "$TOOLKIT_DISMOUNT_STAGE"
    echo "$TOOLKIT_DISMOUNT"
    hdiutil detach "$TOOLKIT_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}$TOOLKIT_DISMOUNT_FAILED${NC}"
    fi
    echo -e "${GREEN}$TOOLKIT_DISMOUNT_DONE${NC}"
    echo "$STATUS_RECORDED"
    echo "done:unmount-gameport" > "$PROGRESS_FILE"
fi

# Toolkit 이미지 삭제
# --cleanup 옵션을 사용하면 자동 삭제
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:unmount-gameport" ]]; then
    echo "$TOOLKIT_DELETION_CONFIRMATION"
    if [[ "$*" == *--cleanup* ]]; then
        echo "$TOOLKIT_DELETION_ENABLED"
        DELETE="y"
    else
        read DELETE
    fi
    if [[ "$DELETE" == "y" ]]; then
        echo "$TOOLKIT_DELETION"
        rm -v ~/"$TOOLKIT_PATH"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}$TOOLKIT_DELETION_FAILED${NC}"
        fi
        echo -e "${GREEN}$TOOLKIT_DELETION_DONE${NC}"
    else
        echo -e "${YELLOW}$TOOLKIT_DELETION_SKIP${NC}"
    fi
    echo "$STATUS_RECORDED"
    echo "done:delete-gameport" > "$PROGRESS_FILE"
fi

# Xcode Command Line 이미지 삭제
# --cleanup 옵션을 사용하면 자동 삭제
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:delete-gameport" ]]; then
    echo "$XCODE_IMG_DELETION_CONFIRMATION"
    if [[ "$*" == *--cleanup* ]]; then
        echo "$XCODE_IMG_DELETION_ENABLED"
        DELETE="y"
    else
        read DELETE
    fi
    if [[ "$DELETE" == "y" ]]; then
        echo "$XCODE_IMG_DELETION"
        rm -v ~/"$XCODE_CMDL_PATH"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}$XCODE_IMG_DELETION_FAILED${NC}"
        fi
        echo -e "${GREEN}$XCODE_IMG_DELETION_DONE${NC}"
    else
        echo -e "${YELLOW}$XCODE_IMG_DELETION_SKIP${NC}"
    fi
    echo "$STATUS_RECORDED"
    echo "done:delete-xcode" > "$PROGRESS_FILE"
fi

# 기반 구조 설치 완료
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:delete-xcode" ]]; then
    echo -e "${GREEN}$BASE_DONE${NC}"
    echo "$GAMESERVICE_INSTALL_STAGE"
    echo "$GAMESERVICE_CHOOSE_FROM_LIST"
    echo -e "1. ${SUPPORTED}$STEAM${NC}"
    echo -e "2. ${UNKNOWN}$BATTLENET${NC}"
    echo -e "3. ${UNKNOWN}$OTHERS${NC}"
    echo "$SELECTION_PROMPT"
    read GAME_INSTALLER
    if [[ "$GAME_INSTALLER" == "1" ]]; then
        echo "$STEAM_INSTALL_SUBSHELL_START"
        echo "$STEAM_INSTALL_SUBSHELL_COPY"
        cp -r "$(dirname "$0")"/subsh/x86env_steaminst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "$STEAM_INSTALL_SUBSHELL_8664"
        arch -x86_64 /tmp/x86env_steaminst.sh  "$@"
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}$STEAM_INSTALL_SUBSHELL_FAILED${NC}"
            exit 1
        fi
        echo -e "${GREEN}$STEAM_INSTALL_SUBSHELL_DONE${NC}"
        echo "$NOT_RECORDED_ON_FS"
    elif [[ "$GAME_INSTALLER" == "2" ]]; then
        echo "$BATTLENET_INSTALL_SUBSHELL_START"
        echo "$BATTLENET_INSTALL_SUBSHELL_COPY"
        cp -r "$(dirname "$0")"/subsh/x86env_battlenetinst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "$BATTLENET_INSTALL_SUBSHELL_8664"
        arch -x86_64 /tmp/x86env_battlenetinst.sh "$@"
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}$BATTLENET_INSTALL_SUBSHELL_FAILED${NC}"
            exit 1
        fi
        echo -e "${GREEN}$BATTLENET_INSTALL_SUBSHELL_DONE${NC}"
        echo "$NOT_RECORDED_ON_FS"
    elif [[ "$GAME_INSTALLER" == "3" ]]; then
        echo "$OTHERS_INSTALL_SUBSHELL_START"
        echo "$OTHERS_INSTALL_SUBSHELL_COPY"
        cp -r "$(dirname "$0")"/subsh/x86env_epicgoginst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "$OTHERS_INSTALL_SUBSHELL_8664"
        arch -x86_64 /tmp/x86env_epicgoginst.sh "$@"
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}$OTHERS_INSTALL_SUBSHELL_FAILED${NC}"
            exit 1
        fi
        echo -e "${GREEN}$OTHERS_INSTALL_SUBSHELL_DONE${NC}"
        echo "$NOT_RECORDED_ON_FS"
    else
        echo -e "${RED}$SELECTION_INVALID${NC}"
        exit 1
    fi
    echo "$NOT_RECORDED_ON_FS"
fi

echo "$DONE"
exit 0
