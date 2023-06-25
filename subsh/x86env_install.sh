#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [[ "$*" == *--kr* ]]; then
    source langs/install/kr.env
else
    source langs/install/en.env
fi

echo "$GENERAL_EMU_PREP"

/tmp/compatchk.sh "$@" --i386
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "$BREW_CHECK"
if [[ "$(which brew)" == "/opt/homebrew/bin/brew" ]]; then
    echo -e "${YELLOW}$BREW_ARM64_EXISTS${NC}"
fi
if [[ "$(which brew)" == "/usr/local/bin/brew" ]]; then
    echo -e "${YELLOW}$BREW_X86_64_EXISTS${NC}"
    echo "$BREW_TASK_UPDATE"
    brew update
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$BREW_TASK_UPDATE_FAILED${NC}"
        exit 1
    fi
fi

if [[ "$(which brew)" != "/usr/local/bin/brew" ]]; then
    echo -e "$BREW_NOT_INSTALLED_YET"
    echo "$BREW_TASK_INSTALL"
    echo -e "${YELLOW}$BREW_TASK_REQUIRE_SUDO${NC}"
    read -r
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    eval "$(/usr/local/bin/brew shellenv)"
    echo "$BREW_INSTALL_SUCCESS"
fi

echo "$APPLE_TAP_INSTALL"
/usr/local/bin/brew tap apple/apple http://github.com/apple/homebrew-apple
if [[ $? -ne 0 ]]; then
    echo -e "${RED}$APPLE_TAP_INSTALL_FAILED${NC}"
    exit 1
fi

echo -e "${GREEN}$APPLE_TAP_INSTALL_SUCCESS${NC}"

echo "$GAME_PORTING_TOOLKIT_INSTALL"
if [[ -z "$(/usr/local/bin/brew list | grep game-porting-toolkit)" ]]; then
    echo -e "${RED}$LONG_TIME_WARNING${NC}"
    echo -e "${YELLOW}$LONG_TIME_WARNING_CONTINUE${NC}"
    read -r
    /usr/local/bin/brew -v install apple/apple/game-porting-toolkit
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}$GAME_PORTING_TOOLKIT_INSTALL_FAILED${NC}"
        exit 1
    fi

    echo -e "${GREEN}$GAME_PORTING_TOOLKIT_INSTALL_SUCCESS${NC}"
else
    echo -e "${YELLOW}$GAME_PORTING_TOOLKIT_INSTALLED${NC}"
fi

echo "$SUBSCRIPT_DONE_NOW_EXITING"
exit 0
