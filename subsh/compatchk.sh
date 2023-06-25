#!/bin/bash
# If argument contains "--skip-version-check" then skip version check by adding environment variable
if [[ "$*" == *--skip-version-check* ]]; then
    export SKIP_VERSION_CHECK="1"
fi

# Darwin 커널 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}$ERROR_SCRIPT_NOT_EXECUTABLE_KERN_TYPE_MISMATCH${NC}"
    echo -e "${RED}$ERROR_RUN_AT_MACOS{NC}"
    exit 1
fi
echo -e "${GREEN}$SYSTEM_KERNEL_IS_DARWIN${NC}"

if [[ -z "$SKIP_VERSION_CHECK" ]]; then
    # 커널 버전 확인
    if [[ "$OSTYPE" != "darwin23"* ]]; then
        echo -e "${RED}$ERROR_SCRIPT_NOT_EXECUTABLE_KERN_VER_MISMATCH${NC}"
        echo -e "${RED}$ERROR_RUN_AT_SONOMA${NC}"
        exit 1
    fi
    echo -e "${GREEN}$KERNEL_VERSION_23${NC}"

    # Production 버전 확인  
    OSVER=$(sw_vers -productVersion)
    if [[ -z "$(echo "$OSVER" | grep "14.")" ]]; then
        echo -e "${RED}$ERROR_SCRIPT_NOT_EXECUTABLE_PROD_VER_MISMATCH${NC}"
        echo -e "${RED}$ERROR_RUN_AT_SONOMA${NC}"
        exit 1
    fi
    echo -e "${GREEN}$PRODUCTION_VERSION_CORRECT${NC}"
else
    echo -e "${YELLOW}$VERSION_CHECK_SKIP${NC}"
fi

# 아키텍쳐 확인
if [[ "$*" == *--arm64* ]]; then
    if [[ "$(arch)" != "arm64" ]]; then
        echo -e "${RED}$ERROR_SCRIPT_NOT_EXECUTABLE_CPU_ARCH_MISMATCH${NC}"
        echo -e "${RED}$ERROR_RUN_AT_APPLESILICON${NC}"
        exit 1
    fi
    echo -e "${GREEN}$SYSTEM_ARCH_IS_ARM64${NC}"
    echo "$SYS_COMPAT_CHECK_SUCCESS"
    exit 0
elif [[ "$*" == *--i386* ]]; then
    if [[ "$(arch)" != "i386" ]]; then
        echo -e "${RED}$ERROR_SCRIPT_NOT_EXECUTABLE_CPU_ARCH_MISMATCH${NC}"
        echo -e "${RED}$ERROR_RUN_AT_INTEL${NC}"
        exit 1
    fi
    echo -e "${GREEN}$SYSTEM_ARCH_IS_X86_64${NC}"
    echo "$SYS_COMPAT_CHECK_SUCCESS"
    exit 0
fi