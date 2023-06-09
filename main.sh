#!/bin/bash

# Env Vars
PROGRESS_FILE=~/Library/d3d12_rosetta_installstages.txt
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SUPPORTED='\033[1;32m'
UNSUPPORTED='\033[1;31m'
UNKNOWN='\033[1;33m'
NC='\033[0m'

TOOLKIT_PATH="Downloads/Game_porting_toolkit_beta.dmg"
TOOLKIT_MOUNT_POINT="/tmp/d3d12_toolkit"
XCODE_CMDL_PATH="Downloads/Command_Line_Tools_for_Xcode_15_beta.dmg"
XCODE_CMDL_MOUNT_POINT="/tmp/d3d12_xcode"

echo "#######Script Release#######"
echo "Script Written: 2023-June-09 EDT"
echo "Script Updated: 2023-June-09 EDT"
echo "macOS Version: macOS 14.0 Developer Beta 1"
echo "############################"
echo ""
echo "This script is written based on the Game Porting Toolkit document of the Apple Gaming Wiki."
echo "https://www.applegamingwiki.com/wiki/Game_Porting_Toolkit"
echo ""
echo ""
echo "Starting the preparation stage for D3D12 emulation environment installation..."
echo "Checking system compatibility..."

# Check Darwin Kernel
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: The script cannot be executed. (Kernel type mismatch)${NC}"
    echo -e "${RED}Please run on macOS.${NC}"
    exit 1
fi
echo -e "${GREEN}The system kernel is Darwin.${NC}"

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

# Check Architecture
if [[ "$(arch)" != "arm64" ]]; then
    echo -e "${RED}Error: The script cannot be executed. (CPU architecture mismatch)${NC}"
    echo -e "${RED}Please run on a Mac with Apple Silicon chip.${NC}"
    exit 1
fi
echo -e "${GREEN}The system CPU architecture is arm64.${NC}"
echo "System compatibility check is completed."

echo "Checking access to the status file."
if [[ "$*" == *--reinstall* ]]; then
    echo "Reinstall option has been detected. Deleting the status file."
    rm -f "$PROGRESS_FILE"
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "The status file does not exist. Creating a new one."
    echo "done:rosetta" > "$PROGRESS_FILE" 2>/dev/null
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo -e "${RED}Error: Unable to access the status file.${NC}"
    echo -e "${RED}Status file path: $PROGRESS_FILE${NC}"
    echo -e "${RED}Delete the status file and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}Access to the status file is possible.${NC}"

echo "Starting the preparation stage for D3D12 emulation environment resource..."
# Start Rosetta2 Installation
ROSETTA=$(/usr/bin/pgrep -q oahd && echo Yes || echo No)
if [[ "$ROSETTA" == "No" ]] && [[ "$*" != *--skip-rosetta* ]]; then
    echo "Rosetta 2 is not installed."
    echo "Starting Rosetta 2 installation step..."
    softwareupdate --install-rosetta --agree-to-license
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to install Rosetta 2.${NC}"
        echo "To skip the Rosetta 2 installation, run this script as follows."
        echo "./main-kr.sh --skip-rosetta"
        exit 1
    fi
    echo -e "Recording the progress step to the file system..."
    echo "done:rosetta" > "$PROGRESS_FILE"
    echo -e "${GREEN}Rosetta 2 installation is complete.${NC}"
    echo -e "${GREEN}The DX12 installation preparation step is complete.${NC}"
    echo "Please restart the script."
    exit 0
fi

VALUE=$(cat "$PROGRESS_FILE")

# File Download Check
if [[ "$VALUE" == "done:rosetta" ]]; then
    echo ""
    echo "Please download the necessary files from the following link."
    echo "https://developer.apple.com/download/all/"
    echo "You can log in using a general Apple account."
    echo "Files to download:"
    echo " - Command Line Tools for Xcode 15 beta"
    echo " - Game porting toolkit beta"
    echo ""
    echo "Please save the files in the Downloads folder without changing the file names."
    echo "Once the download is complete, press the Enter key to proceed with the installation."
    read -r
    if [[ -f ~/"$XCODE_CMDL_PATH" ]]; then
        echo -e "${GREEN}Xcode Command Line Tools have been verified.${NC}"
    else
        echo -e "${RED}Cannot find Xcode Command Line Tools.${NC}"
        echo "Please download it from https://developer.apple.com/download/all/ and rerun this script."
        exit 1
    fi
    if [[ -f ~/"$TOOLKIT_PATH" ]]; then
        echo -e "${GREEN}Game Porting Toolkit has been verified.${NC}"
    else
        echo -e "${RED}Cannot find Game Porting Toolkit.${NC}"
        echo "Please download it from https://developer.apple.com/download/all/ and rerun this script."
        exit 1
    fi
    echo "Recording the progress step to the file system..."
    echo "done:download-files" > "$PROGRESS_FILE"
fi

# Mount Xcode Command Line Image
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:download-files" ]]; then
    echo "Creating the image file mount point..."
    mkdir -p "$XCODE_CMDL_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Cannot create the image file mount point.${NC}"
        exit 1
    fi
    echo "Mounting the image file..."
    hdiutil attach ~/"$XCODE_CMDL_PATH" -mountpoint "$XCODE_CMDL_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Cannot mount Xcode Command Line Tools.${NC}"
        exit 1
    fi
    echo -e "${GREEN}The Xcode Command Line image mounting step is complete.${NC}"
    echo "Recording the progress step to the file system..."
    echo "done:mount-xcode" > "$PROGRESS_FILE"
fi

# Install Xcode Command Line
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:mount-xcode" ]]; then
    echo "Starting the installation of Xcode Command Line Tools..."
    echo "This operation requires an administrator password. The password is not displayed when you enter it."
    sudo installer -pkg "$XCODE_CMDL_MOUNT_POINT"/"Command Line Tools.pkg" -target /
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to install Xcode Command Line Tools.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Xcode Command Line Tools installation is complete.${NC}"
    echo "Unmounting Xcode Command Line Tools..."
    hdiutil detach "$XCODE_CMDL_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Failed to unmount Xcode Command Line Tools.${NC}"
    fi
    echo "Recording the progress step to the file system..."
    echo "done:unmount-xcode" > "$PROGRESS_FILE"
fi

# Run auxiliary script
# The auxiliary script is run in the x86_64 environment
# x86 version Homebrew installation process
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:unmount-xcode" ]]; then
    echo "Preparing to run the auxiliary script..."
    echo "Copying resources..."
    cp -r "$(dirname "$0")"/subsh"$TOOLKIT_MOUNT_POINT"/x86env_install.sh /tmp/
    echo "Executing the auxiliary script in x86_64 environment shell..."
    arch -x86_64 /tmp/x86env_install.sh
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to run the x86_64 auxiliary script.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Completed running the x86_64 auxiliary script.${NC}"
    echo "Recording the progress stage in the filesystem..."
    echo "done:subshell-x86env" > "$PROGRESS_FILE"
fi

# Wine Prefix setup
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:subshell-x86env" ]]; then
    echo "Setting up Wine Prefix..."
    echo -e "${YELLOW}Please follow the Wine Prefix setup guide.${NC}"
    echo "Please select the Windows 10 version in the Wine Prefix creation window."
    echo "You can choose the version through the dropdown menu in the lower right corner of the creation window, Windows Version. (Default: Windows 7, change to Windows 10)"
    echo "After that, click the Apply button and then press the OK button to close the window."
    echo "Press the return key to continue. (All Wine and Wine servers will be terminated when proceeding!)"
    read
    echo "Ending the Wine64 preloader..."
    if [[ $(pgrep -x wine64-preloader) ]]; then
        killall wine64-preloader
    fi
    echo "Ending the Wine64 server..."
    if [[ $(pgrep -x wineserver) ]]; then
        killall wineserver
    fi
    echo "The Wine Prefix creation window will open shortly..."
    arch -x86_64 /bin/bash -c 'eval "$(/usr/local/bin/brew shellenv)"; WINEPREFIX=~/WindowsPrefix `brew --prefix game-porting-toolkit`/bin/wine64 winecfg'
    echo -e "${GREEN}Wine Prefix setup stage is completed.${NC}"
    echo "Recording the progress stage in the filesystem..."   
    echo "done:wine-prefix" > "$PROGRESS_FILE"
fi

# Game Port Toolkit image mount
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:wine-prefix" ]]; then
    echo "Starting the Game Port Toolkit image mount stage..."
    echo "Creating the image file mount point..."
    mkdir -p "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Unable to create the image file mount point.${NC}"
        exit 1
    fi
    echo "Mounting the image file..."
    hdiutil attach ~/"$TOOLKIT_PATH" -mountpoint "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Unable to mount the Game Porting Toolkit.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Completed the Game Porting Toolkit image mount stage.${NC}"
    echo "Recording the progress stage in the filesystem..."
    echo "done:mount-gameport" >

 "$PROGRESS_FILE"
fi

# Execute Ditto
# Run in x86 version
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:mount-gameport" ]]; then
    echo "Starting the Ditto operation stage..."
    echo "Copying the Ditto auxiliary script..."
    cp -r "$(dirname "$0")"/subsh/en/x86env_ditto.sh /tmp/
    echo "Running the Ditto auxiliary script in the x86_64 environment shell..."
    arch -x86_64 /tmp/x86env_ditto.sh "$TOOLKIT_MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to run the x86_64 Ditto auxiliary script.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Completed running the x86_64 Ditto auxiliary script.${NC}"
    echo "Recording the progress stage in the filesystem..."
    echo "done:ditto" > "$PROGRESS_FILE"
fi

# Copy Toolkit commands
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:ditto" ]]; then
    echo "Starting the Toolkit command copy stage..."
    echo "Copying the Toolkit commands..."
    cp -vr "$TOOLKIT_MOUNT_POINT"/gameportingtoolkit* /usr/local/bin/
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to copy the Toolkit commands.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Completed the Toolkit command copy stage.${NC}"
    echo "Recording the progress stage in the filesystem..."
    echo "done:copy-toolkit" > "$PROGRESS_FILE"
fi

# Unmount Toolkit image
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:copy-toolkit" ]]; then
    echo "Starting the Toolkit image unmount stage..."
    echo "Unmounting the Toolkit image..."
    hdiutil detach "$TOOLKIT_MOUNT_POINT" -quiet
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Failed to unmount the Toolkit image.${NC}"
    fi
    echo -e "${GREEN}Completed the Toolkit image unmount stage.${NC}"
    echo "Recording the progress stage in the filesystem..."
    echo "done:unmount-gameport" > "$PROGRESS_FILE"
fi

# Delete Toolkit image
# Automatically delete with the --cleanup option
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:unmount-gameport" ]]; then
    echo "Would you like to delete the Toolkit image? (y/n)"
    if [[ "$*" == *--cleanup* ]]; then
        echo "Automatic cleanup option is enabled."
        DELETE="y"
    else
        read DELETE
    fi
    if [[ "$DELETE" == "y" ]]; then
        echo "Deleting the Toolkit image..."
        rm -rf ~/"$TOOLKIT_PATH"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}Failed to delete the Toolkit image.${NC}"
        fi
        echo -e "${GREEN}Completed the Toolkit image deletion stage.${NC}"
    else
        echo -e "${YELLOW}Skipping the Toolkit image deletion stage.${NC}"
    fi
    echo "Recording the progress stage in the filesystem..."
    echo "done:delete-gameport" > "$PROGRESS_FILE"
fi

# Delete Xcode Command Line image
# Automatically delete with the --cleanup option
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:delete-gameport" ]]; then
    echo "Would you like to delete the Xcode Command Line image? (y/n)"
    if [[ "$*" == *--cleanup* ]]; then
        echo "Automatic cleanup option is enabled."
        DELETE="y"
    else
        read DELETE
    fi
    if [[ "$DELETE" == "y" ]]; then
        echo "Deleting the Xcode Command Line image..."
        rm -rf ~/"$XCODE_PATH"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}Failed to delete the Xcode Command Line image.${NC}"
        fi
        echo -e "${GREEN}Completed the Xcode Command Line image deletion stage.${NC}"
    else
        echo -e "${YELLOW}Skipping the Xcode Command Line image deletion stage.${NC}"
    fi
    echo "Recording the progress stage in the filesystem..."
    echo "done:delete-xcode" > "$PROGRESS_FILE"
fi

# Base structure installation completed
VALUE=$(cat "$PROGRESS_FILE")
if [[ "$VALUE" == "done:delete-xcode" ]]; then
    echo -e "${GREEN}Completed the base structure installation stage.${NC}"
    echo "Starting the game service installation stage..."
    echo "Please select from the following options."
    echo -e "1. ${SUPPORTED}Steam${NC}"
    echo -e "2. ${UNKNOWN}Battle.net [Incomplete]${NC}"
    echo -e "3. ${UNKNOWN}Epic Games / GOG.com [Incomplete]${NC}"
    echo "1, 2, 3 >>> "
    read GAME_INSTALLER
    if [[ "$GAME_INSTALLER" == "1" ]]; then
        echo "Starting the Steam installation subshell..."
        echo "Copying the Steam installation script..."
        cp -r "$(dirname "$0")"/subsh/en/x86env_steaminst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "Running the Steam installation script in the x86_64 environment shell..."
        arch -x86_64 /tmp/x86env_steaminst.sh
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to run the x86_64 Steam installation script.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Completed running the x86_64 Steam installation script.${NC}"
        echo "This stage is not recorded in the filesystem."
    elif [[ "$GAME_INSTALLER" == "2" ]]; then
        echo "Starting the Battle.net installation subshell..."
        echo "Copying the Battle.net installation script..."
        cp -r "$(dirname "$0")"/subsh/en/x86env_battlenetinst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "Running the Battle.net installation script in the x86_64 environment shell..."
        arch -x86_64 /tmp/x86env_battlenetinst.sh
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to run the x86_64 Battle.net installation script.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Completed running the x86_64 Battle.net installation script.${NC}"
        echo "This stage is not recorded in the filesystem."
    elif [[ "$GAME_INSTALLER" == "3" ]]; then
        echo "Starting the Epic Games / GOG.com installation subshell..."
        echo "Copying the Epic Games / GOG.com installation script..."
        cp -r "$(dirname "$0")"/subsh/en/x86env_epicgoginst.sh /tmp/
        cp -r "$(dirname "$0")"/subsh/wrappers /tmp/
        echo "Running the Epic Games / GOG.com installation script in the x86_64 environment shell..."
        arch -x86_64 /tmp/x86env_epicgoginst.sh
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to run the x86_64 Epic Games / GOG.com installation script.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Completed running the x86_64 Epic Games / GOG.com installation script.${NC}"
        echo "This stage is not recorded in the filesystem."
    else
        echo -e "${RED}Invalid selection.${NC}"
        exit 1
    fi
    echo "Completed the game service installation stage."
fi

echo "All stages are completed. Exiting the script."
exit 0