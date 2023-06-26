RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

source langs/battlenet/en.env
if [[ "$*" == *--kr* ]]; then
    source langs/battlenet/kr.env
fi

echo "$INSTALL_STAGE"

/tmp/compatchk.sh "$@" --i386
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "$BATTLENET_DOWNLOAD"
curl -L "https://us.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" -o /tmp/battlenet.exe --progress-bar
if [[ $? -ne 0 ]]; then
    echo -e "${RED}$BATTLENET_DOWNLOAD_FAILED${NC}"
    exit 1
fi
fileType=$(file /tmp/battlenet.exe)
if [[ -z "$(echo "$fileType" | grep "PE32 executable (GUI) Intel 80386")" ]]; then
    echo -e "${RED}$BATTLENET_NOT_EXECUTABLE${NC}"
    echo -e "${RED}$FILE_TYPE${FILE}${NC}"
    exit 1
fi

echo -e "${GREEN}$BATTLENET_DOWNLOAD_SUCCESS${NC}"

echo "$ALL_WINE_SERVER_PRELOADERS_KILL"
if [[ -n "$(pgrep wineserver)" ]]; then
    killall wineserver
fi
if [[ -n "$(pgrep wine64-preloader)" ]]; then
    killall wine64-preloader
fi

echo "$UPDATING_WINEPREFIX_REGISTRY"
eval "$(/usr/local/bin/brew shellenv)"
WINEPREFIX=~/WindowsPrefix `brew --prefix game-porting-toolkit`/bin/wine64 reg add 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentBuild /t REG_SZ /d 19042 /f
WINEPREFIX=~/WindowsPrefix `brew --prefix game-porting-toolkit`/bin/wine64 reg add 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentBuildNumber /t REG_SZ /d 19042 /f
WINEPREFIX=~/WindowsPrefix `brew --prefix game-porting-toolkit`/bin/wineserver -k
echo -e "${GREEN}$UPDATING_WINEPREFIX_REGISTRY_SUCCESS${NC}"

echo "$BATTLENET_INSTALLER_START"
gameportingtoolkit ~/WindowsPrefix ~/Downloads/Battle.net-Setup.exe
echo "$BATTLENET_INSTALLER_END"

echo -e "${YELLOW}$BATTLENET_ISSUE_WARNING${NC}"
# echo "$JAVA_LAUNCHER_INSTALL_QUESTION"
# read yn
# if [[ "$yn" == "y" ]] || [[ "$yn" == "Y" ]]; then
#     echo "$JAVA_LAUNCHER_INSTALLING"
#     cp -r /tmp/wrappers/"Battle.net Utilities.app" ~/Applications/
#     xattr -cr ~/Applications/"Battle.net Utilities.app"
#     echo -e "${GREEN}$JAVA_LAUNCHER_INSTALL_SUCCESS${NC}"
# else
#     echo "$JAVA_LAUNCHER_INSTALL_SKIPPED"
# fi

echo "$WRAPPER_INSTALL"
cp -r /tmp/wrappers/"Battle.net for Windows.app" ~/Applications/
xattr -cr ~/Applications/"Battle.net for Windows.app"
echo -e "${GREEN}$WRAPPER_INSTALL_SUCCESS${NC}"

echo "$SCRIPT_EXIT"
