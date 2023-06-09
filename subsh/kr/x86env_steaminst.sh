RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "x86_64 Steam 설치 단계를 시작합니다..."
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
if [[ "$(arch)" != "i386" ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (구현 환경 아키텍처 불일치)${NC}"
    exit 1
fi
echo -e "${GREEN}구현 환경 아키텍처는 i386 입니다.${NC}"

echo "시스템 적합성 검사를 완료했습니다."

echo "Steam for Windows x86_64 를 설치 단계를 시작합니다..."
echo "Steam for Windows x86_64 를 다운로드합니다..."
curl -L -o /tmp/steamsetup.exe "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" --progress-bar
FILE="$(file /tmp/steamsetup.exe)"
if [[ -z "$(echo "$FILE" | grep "PE32 executable (GUI) Intel 80386")" ]]; then
    echo -e "${RED}오류: 스크립트를 실행할 수 없습니다. (SteamSetup.exe 실행 불가능)${NC}"
    echo -e "${RED}파일 타입: ${FILE}${NC}"
    exit 1
fi
echo -e "${GREEN}SteamSetup.exe 를 다운로드했습니다.${NC}"
echo "Steam for Windows x86_64 를 설치합니다..."
echo -e "${YELLOW}경고: 설치 완료시 Run Steam 에 체크표시를 해제하십시오.${NC}"
echo "계속 진행하려면 return 키를 눌러주세요."
read
eval "$(/usr/local/bin/brew shellenv)"
gameportingtoolkit ~/WindowsPrefix /tmp/steamsetup.exe
echo "Steam for Windows x86_64 를 설치 프로세스가 종료되었습니다."
echo "Steam 설치 화면이 정상적으로 표시되었고, 설치 과정을 정상적으로 마쳤나요? (한글 깨짐은 정상으로 간주합니다.) (y/n)"
read yn
if [[ "$yn" != "y" ]]; then
    echo -e "${RED}오류: 스크립트를 계속 진행할 수 없습니다. (SteamSetup.exe 설치 실패 [사용자 보고])${NC}"
    exit 1
fi
echo -e "${GREEN}Steam for Windows x86_64 를 설치했습니다.${NC}"

echo "로그인을 위한 Steam for Windows x86_64 를 실행합니다..."
echo -e "${YELLOW}이 과정에서 로그인 화면이 정상적으로 실행되지 않을 수 있습니다.${NC}"
echo -e "${YELLOW}그러할 경우, Steam for Windows x86_64 의 로그인 화면을 완전히 종료해 주세요. 완전 종료의 기준은 macOS 의 Dock 에서 실행중인 Steam 아이콘이 없어지는 것 입니다.${NC}"
echo "계속 진행하려면 return 키를 눌러주세요."
while true; do
    MTL_HUD_ENABLED=1 WINEESYNC=1 WINEPREFIX=~/WindowsPrefix /usr/local/Cellar/game-porting-toolkit/1.0/bin/wine64 'C:\Program Files (x86)\Steam\steam.exe' >/dev/null 2>/dev/null 3>/dev/null
    echo -e "${YELLOW}Steam for Windows x86_64 의 로그인 화면이 종료되었습니다.${NC}"
    echo "로그인이 성공적으로 완료 되었나요?"
    read -p "로그인이 완료되었다면, [Y]를 입력해 주세요. (다시 시도하려면 [N]) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Y 또는 N을 입력해 주세요.";;
    esac
    echo "모든 Wine 및 Wine 서버를 종료합니다..."
    if [[ -n "$(pgrep wineserver)" ]]; then
        killall wineserver
    fi
    if [[ -n "$(pgrep wine64-preloader)" ]]; then
        killall wine64-preloader
    fi
done
echo -e "${GREEN}Steam for Windows 의 로그인을 완료했습니다.${NC}"
echo "Steam for Windows x86_64 실행 애플리케이션을 설치합니다..."
xattr -c "$(dirname "$0")/wrappers/Steam for Windows.app"
cp -R "$(dirname "$0")/wrappers/Steam for Windows.app" "/Applications/"
echo "스크립트를 정상적으로 종료합니다."
exit 0
