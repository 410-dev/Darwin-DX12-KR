#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "Starting the setup stage for x86_64 general application emulation environment..."
echo "Checking system compatibility..."

# Verify Darwin kernel
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: Unable to run the script. (Kernel type mismatch)${NC}"
    echo -e "${RED}Please run on macOS.${NC}"
    exit 1
fi
echo -e "${GREEN}System kernel is Darwin.${NC}"

if [[ -z "$SKIP_VERSION_CHECK" ]]; then
    # Check Kernel Version
    if [[ "$OSTYPE" != "darwin23"* ]]; then
        echo -e "${RED}Error: The script cannot be executed. (Kernel version mismatch)${NC}"
        echo -e "${RED}Please run on macOS 14.0 Developer Beta 1 or later.${NC}"
        exit 1
    fi
    echo -e "${GREEN}The system kernel version is 23.x.${NC}"

    # Check Production Version  
    OSVER=$(sw_vers -productVersion)
    if [[ -z "$(echo "$OSVER" | grep "14.")" ]]; then
        echo -e "${RED}Error: The script cannot be executed. (Production version mismatch)${NC}"
        echo -e "${RED}Please run on macOS 14.0 Developer Beta 1 or later.${NC}"
        exit 1
    fi
    echo -e "${GREEN}The system production version is 14.x.${NC}"
else
    echo -e "${YELLOW}Skipping version check.${NC}"
fi

# Check architecture
if [[ "$(arch)" != "i386" ]]; then
    echo -e "${RED}Error: Unable to run the script. (Implementation environment architecture mismatch)${NC}"
    exit 1
fi
echo -e "${GREEN}Implementation environment architecture is i386.${NC}"
echo "System compatibility check has been completed."

echo "Checking Homebrew installation status..."
if [[ "$(which brew)" == "/opt/homebrew/bin/brew" ]]; then
    echo -e "${YELLOW}arm64 Homebrew is installed.${NC}"
fi
if [[ "$(which brew)" == "/usr/local/bin/brew" ]]; then
    echo -e "${YELLOW}x86_64 Homebrew is installed.${NC}"
    echo "Updating Brew..."
    brew update
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to update Brew.${NC}"
        echo -e "${RED}Please restart the terminal and try again.${NC}"
        exit 1
    fi
fi

if [[ "$(which brew)" != "/usr/local/bin/brew" ]]; then
    echo -e "x86_64 Homebrew is not installed."
    echo "Installing x86_64 Homebrew..."
    echo -e "${YELLOW}Warning: You may need to enter the administrator password during the Homebrew installation. Nothing will appear on the terminal when you type the password. Press return key to continue.${NC}"
    read -r
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    eval "$(/usr/local/bin/brew shellenv)"
    echo "Completed installation of Homebrew for x86_64."
fi

echo "Installing Apple Tap from Homebrew..."
/usr/local/bin/brew tap apple/apple http://github.com/apple/homebrew-apple
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Failed to install Apple Tap.${NC}"
    exit 1
fi

echo -e "${GREEN}Completed installation of Apple Tap.${NC}"

echo "Installing game-porting-toolkit from Homebrew..."
if [[ -z "$(/usr/local/bin/brew list | grep game-porting-toolkit)" ]]; then
    echo -e "${RED}########## Warning ##########${NC}"
    echo -e "${RED}This process is very long, and you must not shut down your computer or terminate the terminal during this process.${NC}"
    echo -e "${RED}Do not terminate the terminal and ensure that your computer does not shut down.${NC}"
    echo -e "${RED}Your computer may become very slow and CPU usage may rise to the maximum during this process. This is normal.${NC}"
    echo -e "${RED}When tested in an M1 Max environment, it took about an hour.${NC}"
    echo -e "${RED}##########################${NC}"
    echo -e "${YELLOW}Press return key to continue.${NC}"
    read -r
    /usr/local/bin/brew -v install apple/apple/game-porting-toolkit
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to install game-porting-toolkit.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Completed installation of game-porting-toolkit.${NC}"
else
    echo -e "${YELLOW}game-porting-toolkit is already installed. Skipping installation.${NC}"
fi

echo "Auxiliary tasks are completed."
echo "Successfully terminating the auxiliary script."
exit 0
