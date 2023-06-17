RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "Starting the x86_64 Battle.net installation process..."
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

# Parameter check
if [[ -z "$1" ]]; then
    echo -e "${RED}Error: Unable to meet the script execution condition. (Parameter mismatch)${NC}"
    exit 1
elif [[ ! -d "$1/lib" ]]; then
    echo -e "${RED}Error: Unable to meet the script execution condition. (Invalid parameter)${NC}"
    exit 1
fi

echo "System compatibility check has been completed."

echo "Currently, this feature has not been tested. We do not take responsibility for any problems that may occur from using this feature."
echo "If you wish to use this feature, please type 'run'."
echo "If you do not wish to use this feature, simply press the return key."
read EXITCONFIRM
if [[ "$EXITCONFIRM" != "run" ]]; then
    echo "Operation has been cancelled."
    exit 0
fi

echo -e "${RED}This feature has not been written yet.${NC}"
