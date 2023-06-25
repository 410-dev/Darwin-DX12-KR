RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

source langs/steaminst/en.env
if [[ "$*" == *--kr* ]]; then
    source langs/steaminst/kr.env
fi

echo "$STEAM_INSATLL_STAGE"

/tmp/compatchk.sh "$@" --i386
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "$WINSTEAM_INSTALL_STAGE"
echo "$WINSTEAM_DOWNLOAD"
curl -L -o /tmp/steamsetup.exe "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" --progress-bar
FILE="$(file /tmp/steamsetup.exe)"
if [[ -z "$(echo "$FILE" | grep "PE32 executable (GUI) Intel 80386")" ]]; then
    echo -e "${RED}$WINSTEAM_NOT_EXECUTABLE${NC}"
    echo -e "${RED}$WINSTEAM_FILE_TYPE${FILE}${NC}"
    exit 1
fi
echo -e "${GREEN}$WINSTEAM_DOWNLOAD_SUCCESS${NC}"
echo "$WINSTEAM_INSTALL"
echo -e "${YELLOW}$WINSTEAM_INSTALL_WARNING${NC}"
echo "$WINSTEAM_INSTALL_CONTINUE"
read
eval "$(/usr/local/bin/brew shellenv)"
gameportingtoolkit ~/WindowsPrefix /tmp/steamsetup.exe
echo "$WINSTEAM_INSTALL_PROCESS_DONE"
echo "$WINSTEAM_INSTALL_SUCCESS_QUESTION"
read yn
if [[ "$yn" != "y" ]]; then
    echo -e "${RED}$WINSTEAM_INSTALL_SUCCESS_ERROR${NC}"
    exit 1
fi
echo -e "${GREEN}$WINSTEAM_INSTALL_SUCCESS${NC}"

echo "$WINSTEAM_LOGIN_WINDOW_OPEN"
echo -e "${YELLOW}$WINSTEAM_LOGIN_WINDOW_WARNING${NC}"
echo "$WINSTEAM_LOGIN_WINDOW_CONTINUE"
while true; do
    MTL_HUD_ENABLED=1 WINEESYNC=1 WINEPREFIX=~/WindowsPrefix /usr/local/Cellar/game-porting-toolkit/1.0/bin/wine64 'C:\Program Files (x86)\Steam\steam.exe' >/dev/null 2>/dev/null 3>/dev/null
    echo -e "${YELLOW}$WINSTEAM_LOGIN_WINDOW_CLOSED${NC}"
    echo "$WINSTEAM_LOGIN_WINDOW_SUCCESS_QUESTION"
    read -p "$WINSTEAM_LOGIN_WINDOW_SUCCESS_PROMPT" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "$YORNONLY";;
    esac
    echo "$ALL_WINE_SERVER_PRELOADERS_KILL"
    if [[ -n "$(pgrep wineserver)" ]]; then
        killall wineserver
    fi
    if [[ -n "$(pgrep wine64-preloader)" ]]; then
        killall wine64-preloader
    fi
done
echo -e "${GREEN}$STEAM_LOGIN_DONE${NC}"
echo "$STEAM_APP_INSTALL"
xattr -c "$(dirname "$0")/wrappers/Steam for Windows.app"
cp -R "$(dirname "$0")/wrappers/Steam for Windows.app" "/Applications/"
echo "$SCRIPT_EXIT"
exit 0
