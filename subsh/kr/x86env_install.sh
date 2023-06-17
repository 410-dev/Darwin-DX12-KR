#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "x86_64 일반 응용프로그램 에뮬레이션 환경 설치 준비 단계를 시작합니다..."
echo "시스템 적합성을 검사합니다..."

# Darwin 커널 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (커널 유형 불일치)${NC}"
    echo -e "${RED}macOS에서 실행해 주세요.${NC}"
    exit 1
fi
echo -e "${GREEN}시스템 커널은 Darwin 입니다.${NC}"

if [[ -z "$SKIP_VERSION_CHECK" ]]; then
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
else
    echo -e "${YELLOW}버전 검사를 건너뜁니다.${NC}"
fi

# 아키텍쳐 확인
if [[ "$(arch)" != "i386" ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (구현 환경 아키텍처 불일치)${NC}"
    exit 1
fi
echo -e "${GREEN}구현 환경 아키텍처는 i386 입니다.${NC}"
echo "시스템 적합성 검사를 완료했습니다."

echo "Homebrew 설치 상태를 체크합니다..."
if [[ "$(which brew)" == "/opt/homebrew/bin/brew" ]]; then
    echo -e "${YELLOW}arm64 Homebrew가 설치되어 있습니다.${NC}"
fi
if [[ "$(which brew)" == "/usr/local/bin/brew" ]]; then
    echo -e "${YELLOW}x86_64 Homebrew가 설치되어 있습니다.${NC}"
    echo "Brew 를 업데이트 합니다..."
    brew update
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}오류: Brew 업데이트에 실패했습니다.${NC}"
        echo -e "${RED}터미널을 재시작하고 다시 시도해 주세요.${NC}"
        exit 1
    fi
fi

if [[ "$(which brew)" != "/usr/local/bin/brew" ]]; then
    echo -e "x86_64 Homebrew가 설치되어 있지 않습니다."
    echo "x86_64 Homebrew를 설치합니다..."
    echo -e "${YELLOW}경고: Homebrew 설치 중에 관리자 암호를 입력해야 할 수 있습니다. 암호 입력시 터미널에 아무것도 나타나지 않습니다. 계속 진행하려면 return 키를 누르십시오.${NC}"
    read -r
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    eval "$(/usr/local/bin/brew shellenv)"
    echo "x86_64용 Homebrew 설치를 완료했습니다."
fi

echo "Homebrew 에서 Apple Tap 을 설치합니다..."
/usr/local/bin/brew tap apple/apple http://github.com/apple/homebrew-apple
if [[ $? -ne 0 ]]; then
    echo -e "${RED}오류: Apple Tap 설치에 실패했습니다.${NC}"
    exit 1
fi

echo -e "${GREEN}Apple Tap 설치를 완료했습니다.${NC}"

echo "Homebrew 에서 game-porting-toolkit 을 설치합니다..."
if [[ -z "$(/usr/local/bin/brew list | grep game-porting-toolkit)" ]]; then
    echo -e "${RED}########## 경고 ##########${NC}"
    echo -e "${RED}이 과정은 매우 오래 걸리며, 중간에 컴퓨터를 종료하거나 터미널을 종료하면 안됩니다.${NC}"
    echo -e "${RED}터미널을 종료하지 마시고, 컴퓨터가 종료되지 않도록 주의해 주세요.${NC}"
    echo -e "${RED}이 과정에서 컴퓨터가 매우 느려지고 CPU 사용량이 최대로 올라갑니다. 이는 정상입니다.${NC}"
    echo -e "${RED}M1 Max 환경에서 테스트 되었을 때, 약 1시간이 소요되었습니다.${NC}"
    echo -e "${RED}##########################${NC}"
    echo -e "${YELLOW}계속 진행하려면 return 키를 누르십시오.${NC}"
    read -r
    /usr/local/bin/brew -v install apple/apple/game-porting-toolkit
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}오류: game-porting-toolkit 설치에 실패했습니다.${NC}"
        exit 1
    fi

    echo -e "${GREEN}game-porting-toolkit 설치를 완료했습니다.${NC}"
else
    echo -e "${YELLOW}game-porting-toolkit이 이미 설치되어 있습니다. 설치를 건너뜁니다.${NC}"
fi

echo "보조 작업이 완료되었습니다."
echo "보조 스크립트를 정상적으로 종료합니다."
exit 0
