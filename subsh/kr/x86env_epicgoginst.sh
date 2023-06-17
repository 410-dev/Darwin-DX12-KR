RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "x86_64 Epic Games / GOG.com 설치 단계를 시작합니다..."
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

# Parameter 확인
if [[ -z "$1" ]]; then
    echo -e "${RED}오류: 스크립트 실행 조건을 만족하지 않습니다. (파라미터 불일치)${NC}"
    exit 1
elif [[ ! -d "$1/lib" ]]; then
    echo -e "${RED}오류: 스크립트 실행 조건을 만족하지 않습니다. (파라미터 무효)${NC}"
    exit 1
fi

echo "시스템 적합성 검사를 완료했습니다."

echo "현재 이 기능은 테스트되지 않았습니다."
echo "이 기능을 사용하려면, run 이라고 입력해 주세요."
echo "이 기능을 사용하지 않으려면, 그냥 return 키를 눌러 주세요."
read EXITCONFIRM
if [[ "$EXITCONFIRM" != "run" ]]; then
    echo "작업을 취소하였습니다."
    exit 0
fi

echo -e "${RED}현재 이 기능은 작성되지 않았습니다.${NC}"
