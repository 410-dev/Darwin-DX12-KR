echo "Starting the x86_64 Ditto step..."
echo "Checking system compatibility..."

# Check Darwin kernel
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: The script cannot be run. (Kernel type mismatch)${NC}"
    echo -e "${RED}Please run on macOS.${NC}"
    exit 1
fi
echo -e "${GREEN}The system kernel is Darwin.${NC}"

# Check kernel version
if [[ "$OSTYPE" != "darwin23"* ]]; then
    echo -e "${RED}Error: The script cannot be run. (Kernel version mismatch)${NC}"
    echo -e "${RED}Please run on macOS 14.0 Developer Beta 1 or later.${NC}"
    exit 1
fi
echo -e "${GREEN}The system kernel version is 23.x.${NC}"

# Check Production version
OSVER=$(sw_vers -productVersion)
if [[ -z "$(echo "$OSVER" | grep "14.")" ]]; then
    echo -e "${RED}Error: The script cannot be run. (Production version mismatch)${NC}"
    echo -e "${RED}Please run on macOS 14.0 Developer Beta 1 or later.${NC}"
    exit 1
fi
echo -e "${GREEN}The system production version is 14.x.${NC}"

# Check architecture
if [[ "$(arch)" != "i386" ]]; then
    echo -e "${RED}Error: The script cannot be run. (Runtime environment architecture mismatch)${NC}"
    exit 1
fi
echo -e "${GREEN}The runtime environment architecture is i386.${NC}"

# Check parameter
if [[ -z "$1" ]]; then
    echo -e "${RED}Error: The script execution condition is not met. (Parameter mismatch)${NC}"
    exit 1
elif [[ ! -d "$1/lib" ]]; then
    echo -e "${RED}Error: The script execution condition is not met. (Parameter invalid)${NC}"
    exit 1
fi

echo "System compatibility check is complete."
eval "$(/usr/local/bin/brew shellenv)"
ditto "$1/lib/" `/usr/local/bin/brew --prefix game-porting-toolkit`/lib/
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Library copy failed.${NC}"
    exit 1
fi
echo -e "${GREEN}Library copy is complete.${NC}"
exit 0
