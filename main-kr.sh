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

echo "#######Script Release#######"
echo "Script Written: 2023-June-09 EDT"
echo "Script Updated: 2023-June-09 EDT"
echo "macOS Version: macOS 14.0 Developer Beta 1"
echo "############################"
echo ""
echo "이 스크립트는 Apple Gaming Wiki 의 Game Porting Toolkit 문서를 참고하여 작성되었습니다."
echo "https://www.applegamingwiki.com/wiki/Game_Porting_Toolkit"
echo ""
echo ""
echo "D3D12 에뮬레이션 환경 설치 준비 단계를 시작합니다..."
echo "시스템 적합성을 검사합니다..."

# Darwin 커널 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (커널 유형 불일치)${NC}"
    echo -e "${RED}macOS에서 실행해 주세요.${NC}"
    exit 1
fi
echo -e "${GREEN}시스템 커널은 Darwin 입니다.${NC}"

# 커널 버전 확인
if [[ "$OSTYPE" != "darwin23"* ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (커널 버전 불일치)${NC}"
    echo -e "${RED}macOS 14.0 Developer Beta 1 이상에서 실행해 주세요.${NC}"
    exit 1
fi
echo -e "${GREEN}시스템 커널 버전은 23.x 입니다.${NC}"

# Production 버전 확인  
OSVER=$(sw_vers -productVersion)
if [[ -z "$(echo "$OSVER" | grep "14.")" ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (Production 버전 불일치)${NC}"
    echo -e "${RED}macOS 14.0 Developer Beta 1 이상에서 실행해 주세요.${NC}"
    exit 1
fi
echo -e "${GREEN}시스템 프러덕션 버전은 14.x 입니다.${NC}"

# 아키텍쳐 확인
if [[ "$(arch)" != "arm64" ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (CPU 아키텍처 불일치)${NC}"
    echo -e "${RED}Apple Silicon 칩이 탑재된 Mac에서 실행해 주세요.${NC}"
    exit 1
fi
echo -e "${GREEN}시스템 CPU 아키텍처는 arm64 입니다.${NC}"
echo "시스템 적합성 검사를 완료했습니다."

echo "상태 파일 액세스를 점검합니다."
if [[ "$*" == *--reinstall* ]]; then
    echo "재설치 옵션이 감지되었습니다. 상태 파일을 삭제합니다."
    rm -f "$PROGRESS_FILE"
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "상태 파일이 존재하지 않습니다. 새로 생성합니다."
    echo "done:rosetta" > "$PROGRESS_FILE" 2>/dev/null
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo -e "${RED}오류: 상태 파일에 액세스할 수 없습니다.${NC}"
    echo -e "${RED}상태 파일 경로: $PROGRESS_FILE${NC}"
    echo -e "${RED}상태 파일을 삭제하고 다시 시도해 주세요.${NC}"
    exit 1
fi
echo -e "${GREEN}상태 파일에 액세스할 수 있습니다.${NC}"

echo "D3D12 에뮬레이션 환경 리소스 준비 단계를 시작합니다..."

# 로제타2 설치 시작
ROSETTA=$(/usr/bin/pgrep -q oahd && echo Yes || echo No)
if [[ "$ROSETTA" == "No" ]] && [[ "$*" != *--skip-rosetta* ]]; then
    echo "Rosetta 2 가 설치되지 않았습니다."
    echo "Rosetta 2 설치 단계를 시작합니다..."
    softwareupdate --install-rosetta --agree-to-license
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Rosetta 2 설치에 실패했습니다.${NC}"
        echo "Rosetta 2 설치를 건너 뛰려면, 이 스크립트를 다음과 같이 실행하세요."
        echo "./main-kr.sh --skip-rosetta"
        exit 1
    fi
    echo -e "진행 단계를 파일시스템에 기록합니다..."
    echo "done:rosetta" > "$PROGRESS_FILE"
    echo -e "${GREEN}Rosetta 2 설치가 완료되었습니다.${NC}"
    echo -e "${GREEN}DX12 설치 준비 단계를 완료했습니다.${NC}"
    echo "스크립트를 재시작 해 주세요."
    exit 0
fi

VALUE=$(cat "$PROGRESS_FILE")

# 파일 다운로드 확인
if [[ "$VALUE" == "done:rosetta" ]]; then
    echo ""
    echo "다음 링크에서 필요한 파일을 다운로드 받으세요."
    echo "https://developer.apple.com/download/all/"
    echo "일반 Apple 계정을 사용하여 로그인 할 수 있습니다."
    echo "다운로드 할 파일:"
    echo " - Command Line Tools for Xcode 15 beta"
    echo " - Game porting toolkit beta"
    echo ""
    echo "다운로드 폴더에 파일 이름을 변경하지 않고 저장해 주세요."
    echo "다운로드가 완료되면, 엔터키를 눌러 설치를 진행하세요."
    read -r
    if [[ -f ~/"$XCODE_CMDL_PATH" ]]; then
        echo -e "${GREEN}Xcode Command Line Tools 를 확인하였습니다.${NC}"
    else
        echo -e "${RED}Xcode Command Line Tools 를 찾을 수 없습니다.${NC}"
        echo "https://developer.apple.com/download/all/ 에서 다운로드 받은 후 이 스크립트를 다시 실행 해 주세요."
        exit 1
    fi
    if [[ -f ~/"$TOOLKIT_PATH" ]]; then
        echo -e "${GREEN}Game Porting Toolkit 을 확인하였습니다.${NC}"
    else
        echo -e "${RED}Game Porting Toolkit 을 찾을 수 없습니다.${NC}"
        echo "https://developer.apple.com/download/all/ 에서 다운로드 받은 후 이 스크립트를 다시 실행 해 주세요."
        exit 1
    fi
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:download-files" > "$PROGRESS_FILE"
fi

# Xcode 커맨드 라인 이미지 마운트
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:download-files" ]]; then
    echo "이미지 파일 마운트 포인트를 생성합니다..."
    mkdir -p "$XCODE_CMDL_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}이미지 파일 마운트 포인트를 생성할 수 없습니다.${NC}"
        exit 1
    fi
    echo "이미지 파일을 마운트 합니다..."
    hdiutil attach ~/"$XCODE_CMDL_PATH" -mountpoint "$XCODE_CMDL_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Xcode Command Line Tools 를 마운트 할 수 없습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Xcode Command Line 이미지 마운트 단계를 완료하였습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:mount-xcode" > "$PROGRESS_FILE"
fi

# Xcode 커맨드 라인 설치
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:mount-xcode" ]]; then
    echo "Xcode Command Line Tools 설치를 시작합니다..."
    echo "해당 작업은 관리자 비밀번호를 요구합니다. 비밀번호 입력시 화면에 표시되지 않습니다."
    sudo installer -pkg "$XCODE_CMDL_MOUNT_POINT"/"Command Line Tools.pkg" -target /
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Xcode Command Line Tools 설치에 실패하였습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Xcode Command Line Tools 설치를 완료하였습니다.${NC}"
    echo "Xcode Command Line Tools 마운트를 해제합니다..."
    hdiutil detach "$XCODE_CMDL_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Xcode Command Line Tools 마운트 해제에 실패하였습니다.${NC}"
    fi
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:unmount-xcode" > "$PROGRESS_FILE"
fi

# 보조 스크립트 실행
# 보조 스크립트는 x86_64 환경에서 실행됨
# x86 버전 홈브루 설치 과정
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:unmount-xcode" ]]; then
    echo "보조 스크립트 실행을 준비합니다..."
    echo "리소스를 복사합니다..."
    cp -r "$(dirname "$0")"/subsh/kr/x86env_install.sh /tmp/
    echo "x86_64 환경 셸에서 보조 스크립트를 실행합니다..."
    arch -x86_64 /tmp/x86env_install.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}x86_64 보조 스크립트 실행에 실패하였습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}x86_64 보조 스크립트 실행을 완료하였습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:subshell-x86env" > "$PROGRESS_FILE"
fi

# Wine Prefix 설정
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:subshell-x86env" ]]; then
    echo "Wine Prefix 를 설정합니다..."
    echo -e "${YELLOW}Wine Prefix 설정 방법을 따라주세요.${NC}"
    echo "Wine Prefix 생성 윈도우에서 Windows 10 버전을 선택해 주세요."
    echo "버전 선택은 생성 윈도우 우측 하단, Windows Version 의 드롭다운 메뉴를 통해 가능합니다. (기본값: Windows 7, Windows 10 으로 변경)"
    echo "이후, Apply 버튼을 클릭 후 OK 버튼을 눌러 창을 닫아주세요."
    echo "계속 진행하려면 return 키를 눌러주세요. (진행시 모든 Wine 및 Wine 서버가 종료됩니다!)"
    read
    echo "Wine64 프리로더를 종료합니다..."
    if [[ $(pgrep -x wine64-preloader) ]]; then
        killall wine64-preloader
    fi
    echo "Wine64 서버를 종료합니다..."
    if [[ $(pgrep -x wineserver) ]]; then
        killall wineserver
    fi
    echo "Wine Prefix 생성 창이 곧 열립니다..."
    arch -x86_64 /bin/bash -c 'eval "$(/usr/local/bin/brew shellenv)"; WINEPREFIX=~/WindowsPrefix `brew --prefix game-porting-toolkit`/bin/wine64 winecfg'
    echo -e "${GREEN}Wine Prefix 설정 단계를 마쳤습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."   
    echo "done:wine-prefix" > "$PROGRESS_FILE"
fi

# Game Port Toolkit 이미지 마운트
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:wine-prefix" ]]; then
    echo "Game Port Toolkit 이미지 마운트 단계를 시작합니다..."
    echo "이미지 파일 마운트 포인트를 생성합니다..."
    mkdir -p "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}이미지 파일 마운트 포인트를 생성할 수 없습니다.${NC}"
        exit 1
    fi
    echo "이미지 파일을 마운트 합니다..."
    hdiutil attach ~/"$TOOLKIT_PATH" -mountpoint "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Game Porting Toolkit 을 마운트 할 수 없습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Game Porting Toolkit 이미지 마운트 단계를 완료하였습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:mount-gameport" > "$PROGRESS_FILE"
fi

# Ditto 실행
# x86 버전에서 실행됨
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:mount-gameport" ]]; then
    echo "Ditto 작업 단계를 시작합니다..."
    echo "Ditto 보조 스크립트를 복사합니다..."
    cp -r "$(dirname "$0")"/subsh/kr/x86env_ditto.sh /tmp/
    echo "x86_64 환경 셸에서 Ditto 보조 스크립트를 실행합니다..."
    arch -x86_64 /tmp/x86env_ditto.sh "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}x86_64 Ditto 보조스크립트 실행에 실패하였습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}x86_64 Ditto 보조스크립트 실행을 완료하였습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:ditto" > "$PROGRESS_FILE"
fi

# Toolkit 명령어 복사
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:ditto" ]]; then
    echo "Toolkit 명령어 복사 단계를 시작합니다..."
    echo "Toolkit 명령어를 복사합니다..."
    cp -vr "$TOOLKIT_MOUNT_POINT"/gameportingtoolkit* /usr/local/bin/
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Toolkit 명령어 복사에 실패하였습니다.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Toolkit 명령어 복사 단계를 완료하였습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:copy-toolkit" > "$PROGRESS_FILE"
fi

# Toolkit 이미지 마운트 해제
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:copy-toolkit" ]]; then
    echo "Toolkit 이미지 마운트 해제 단계를 시작합니다..."
    echo "Toolkit 이미지 마운트를 해제합니다..."
    hdiutil detach "$TOOLKIT_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Toolkit 이미지 마운트 해제에 실패하였습니다.${NC}"
    fi
    echo -e "${GREEN}Toolkit 이미지 마운트 해제 단계를 완료하였습니다.${NC}"
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:unmount-gameport" > "$PROGRESS_FILE"
fi

# Toolkit 이미지 삭제
# --cleanup 옵션을 사용하면 자동 삭제
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:unmount-gameport" ]]; then
    echo "Toolkit 이미지를 삭제하시겠습니까? (y/n)"
    if [[ "$*" == *--cleanup* ]]; then
        echo "자동 삭제 옵션이 활성화되어 있습니다."
        DELETE="y"
    else
        read DELETE
    fi
    if [[ "$DELETE" == "y" ]]; then
        echo "Toolkit 이미지를 삭제합니다..."
        rm -rf ~/"$TOOLKIT_PATH"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}Toolkit 이미지 삭제에 실패하였습니다.${NC}"
        fi
        echo -e "${GREEN}Toolkit 이미지 삭제 단계를 완료하였습니다.${NC}"
    else
        echo -e "${YELLOW}Toolkit 이미지 삭제 단계를 건너뜁니다.${NC}"
    fi
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:delete-gameport" > "$PROGRESS_FILE"
fi

# Xcode Command Line 이미지 삭제
# --cleanup 옵션을 사용하면 자동 삭제
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:delete-gameport" ]]; then
    echo "Xcode Command Line 이미지를 삭제하시겠습니까? (y/n)"
    if [[ "$*" == *--cleanup* ]]; then
        echo "자동 삭제 옵션이 활성화되어 있습니다."
        DELETE="y"
    else
        read DELETE
    fi
    if [[ "$DELETE" == "y" ]]; then
        echo "Xcode Command Line 이미지를 삭제합니다..."
        rm -rf ~/"$XCODE_PATH"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}Xcode Command Line 이미지 삭제에 실패하였습니다.${NC}"
        fi
        echo -e "${GREEN}Xcode Command Line 이미지 삭제 단계를 완료하였습니다.${NC}"
    else
        echo -e "${YELLOW}Xcode Command Line 이미지 삭제 단계를 건너뜁니다.${NC}"
    fi
    echo "진행 단계를 파일시스템에 기록합니다..."
    echo "done:delete-xcode" > "$PROGRESS_FILE"
fi

# 기반 구조 설치 완료
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:delete-xcode" ]]; then
    echo -e "${GREEN}기반 구조 설치 단계를 완료하였습니다.${NC}"
    echo "게임 서비스 설치 단계를 시작합니다..."
    echo "아래 목록에서 선택 해 주세요."
    echo -e "1. ${SUPPORTED}Steam${NC}"
    echo -e "2. ${UNKNOWN}Battle.net [미완] ${NC}"
    echo -e "3. ${UNKNOWN}Epic Games / GOG.com [미완] ${NC}"
    echo "1, 2, 3 >>> "
    read GAME_INSTALLER
    if [[ "$GAME_INSTALLER" == "1" ]]; then
        echo "Steam 설치 서브셸을 시작합니다..."
        echo "Steam 설치 스크립트를 복사합니다..."
        cp -r "$(dirname "$0")"/subsh/kr/x86env_steaminst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "x86_64 환경 셸에서 Steam 설치 스크립트를 실행합니다..."
        arch -x86_64 /tmp/x86env_steaminst.sh 
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}x86_64 Steam 설치 스크립트 실행에 실패하였습니다.${NC}"
            exit 1
        fi
        echo -e "${GREEN}x86_64 Steam 설치 스크립트 실행을 완료하였습니다.${NC}"
        echo "이 단계는 파일 시스템에 기록되지 않습니다."
    elif [[ "$GAME_INSTALLER" == "2" ]]; then
        echo "Battle.net 설치 서브셸을 시작합니다..."
        echo "Battle.net 설치 스크립트를 복사합니다..."
        cp -r "$(dirname "$0")"/subsh/kr/x86env_battlenetinst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "x86_64 환경 셸에서 Battle.net 설치 스크립트를 실행합니다..."
        arch -x86_64 /tmp/x86env_battlenetinst.sh
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}x86_64 Battle.net 설치 스크립트 실행에 실패하였습니다.${NC}"
            exit 1
        fi
        echo -e "${GREEN}x86_64 Battle.net 설치 스크립트 실행을 완료하였습니다.${NC}"
        echo "이 단계는 파일 시스템에 기록되지 않습니다."
    elif [[ "$GAME_INSTALLER" == "3" ]]; then
        echo "Epic Games / GOG.com 설치 서브셸을 시작합니다..."
        echo "Epic Games / GOG.com 설치 스크립트를 복사합니다..."
        cp -r "$(dirname "$0")"/subsh/kr/x86env_epicgoginst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "x86_64 환경 셸에서 Epic Games / GOG.com 설치 스크립트를 실행합니다..."
        arch -x86_64 /tmp/x86env_epicgoginst.sh
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}x86_64 Epic Games / GOG.com 설치 스크립트 실행에 실패하였습니다.${NC}"
            exit 1
        fi
        echo -e "${GREEN}x86_64 Epic Games / GOG.com 설치 스크립트 실행을 완료하였습니다.${NC}"
        echo "이 단계는 파일 시스템에 기록되지 않습니다."
    else
        echo -e "${RED}선택이 잘못되었습니다.${NC}"
        exit 1
    fi
    echo "게임 서비스 설치 단계를 완료하였습니다."
fi

echo "모든 단계를 완료하였습니다. 스크립트를 종료합니다."
exit 0
