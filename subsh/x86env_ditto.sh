#!/bin/bash

source langs/en.env
if [[ "$*" == *--kr* ]]; then
    source langs/kr.env
fi

echo "$DITTO_STAGE_START"

/tmp/compatchk.sh "$@" --i386
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Parameter 확인
if [[ -z "$1" ]]; then
    echo -e "${RED}$ERROR_PARAMETER_MISMATCH${NC}"
    exit 1
elif [[ ! -d "$1/lib" ]]; then
    echo -e "${RED}$ERROR_VOID_PARAMETER${NC}"
    exit 1
fi

eval "$(/usr/local/bin/brew shellenv)"
ditto "$1/lib/" `/usr/local/bin/brew --prefix game-porting-toolkit`/lib/
if [[ $? -ne 0 ]]; then
    echo -e "${RED}$DITTO_LIBCOPY_FAILED${NC}"
    exit 1
fi
echo -e "${GREEN}$DITTO_LIBCOPY_DONE${NC}"
exit 0
