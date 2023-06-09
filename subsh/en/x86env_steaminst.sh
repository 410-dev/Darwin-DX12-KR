RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "Beginning the x86_64 Steam installation process..."
echo "Checking system compatibility..."

# Verify Darwin kernel
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: Unable to run the script. (Kernel type mismatch)${NC}"
    echo -e "${RED}Please run on macOS.${NC}"
    exit 1
fi
echo -e "${GREEN}System kernel is Darwin.${NC}"

# Verify kernel version
if [[ "$OSTYPE" != "darwin23"* ]]; then
    echo -e "${RED}Error: Unable to run the script. (Kernel version mismatch)${NC}"
    echo -e "${RED}Please run on macOS 14.0 Developer Beta 1 or later.${NC}"
    exit 1
fi
echo -e "${GREEN}System kernel version is 23.x.${NC}"

# Verify Production version  
OSVER=$(sw_vers -productVersion)
if [[ -z "$(echo "$OSVER" | grep "14.")" ]]; then
    echo -e "${RED}Error: Unable to run the script. (Production version mismatch)${NC}"
    echo -e "${RED}Please run on macOS 14.0 Developer Beta 1 or later.${NC}"
    exit 1
fi
echo -e "${GREEN}System production version is 14.x.${NC}"

# Check architecture
if [[ "$(arch)" != "i386" ]]; then
    echo -e "${RED}Error: Unable to run the script. (Implementation environment architecture mismatch)${NC}"
    exit 1
fi
echo -e "${GREEN}Implementation environment architecture is i386.${NC}"

echo "System compatibility check has been completed."

echo "Starting the installation process for Steam for Windows x86_64..."
echo "Downloading Steam for Windows x86_64..."
curl -L -o /tmp/steamsetup.exe "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" --progress-bar
FILE="$(file /tmp/steamsetup.exe)"
if [[ -z "$(echo "$FILE" | grep "PE32 executable (GUI) Intel 80386")" ]]; then
    echo -e "${RED}Error: Unable to run the script. (SteamSetup.exe execution not possible)${NC}"
    echo -e "${RED}File type: ${FILE}${NC}"
    exit 1
fi
echo -e "${GREEN}Downloaded SteamSetup.exe.${NC}"
echo "Installing Steam for Windows x86_64..."
echo -e "${YELLOW}Warning: Uncheck Run Steam upon installation completion.${NC}"
echo "Press return to continue."
read
eval "$(/usr/local/bin/brew shellenv)"
gameportingtoolkit ~/WindowsPrefix /tmp/steamsetup.exe
echo "The installation process for Steam for Windows x86_64 has ended."
echo "Was the Steam installation screen properly displayed, and the installation process completed normally? (Korean characters being garbled is considered normal.) (y/n)"
read yn
if [[ "$yn" != "y" ]]; then
    echo -e "${RED}Error: Unable to proceed with the script. (SteamSetup.exe installation failed [User reported])${NC}"
    exit 1
fi
echo -e "${GREEN}Installed Steam for Windows x86_64.${NC}"

echo "Running Steam for Windows x86_64 for login..."
echo -e "${YELLOW}In this process, the login screen may not launch properly.${NC}"
echo -e "${YELLOW}If that happens, please fully exit the Steam for Windows x86_64 login screen. The criterion for full exit is the disappearance of the running Steam icon from the macOS Dock.${NC}"
echo "Press return to continue."
while true; do
    MTL_HUD_ENABLED=1 WINEESYNC=1 WINEPREFIX=~/WindowsPrefix /usr/local/Cellar/game-porting-toolkit/1.0/bin/wine64 'C:\Program Files (x86)\Steam\steam.exe' >/dev/null 2>/dev/null 3>/dev/null
    echo -e "${YELLOW}Steam for Windows x86_64 login screen has exited.${NC}"
    echo "Has the login been successfully completed?"
    read -p "If the login has been completed, please enter [Y]. (To retry, enter [N]) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please enter Y or N.";;
    esac
    echo "All Wine and Wine servers are shutting down..."
    if [[ -n "$(pgrep wineserver)" ]]; then
        killall wineserver
    fi
    if [[ -n "$(pgrep wine64-preloader)" ]]; then
        killall wine64-preloader
    fi
done
echo -e "${GREEN}Completed login for Steam for Windows.${NC}"
echo "Installing Steam for Windows x86_64 execution application..."
xattr -c "$(dirname "$0")/wrappers/Steam for Windows.app"
cp -R "$(dirname "$0")/wrappers/Steam for Windows.app" "/Applications/"
echo "Script has completed successfully."
exit 0
