RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [[ "$*" == *--kr* ]]; then
    source langs/epicgogo/kr.env
else
    source langs/epicgogo/en.env
fi

echo "$INSTALL_STAGE"

/tmp/compatchk.sh "$@" --i386
if [[ $? -ne 0 ]]; then
    exit 1
fi


echo -e "${RED}$NOT_WRITTEN${NC}"
