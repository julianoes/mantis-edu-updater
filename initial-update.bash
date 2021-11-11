#!/usr/bin/env bash

# This is a script to perform the initial update from the Yuneec Mantis G
# software to the ATL Mantis EDU software with open source PX4.

set -e

bold=$(tput bold)
red=$(tput setaf 1)
normal=$(tput sgr0)

camera_firmware="https://drive.google.com/uc?export=download&id=1MxNJmJJX8CE6YpvjpuPKLdjI5K4nA1je"
autopilot_bootloader_firmware="https://drive.google.com/uc?export=download&id=1ebmhxayUd8dRrD_VFhIaT4EmRlf2t-sv"
autopilot_firmware="https://drive.google.com/uc?export=download&id=1auNI-IYRTIFb3FuyWvo15Llcu0ZIiR4d"
gimbal_firmware="https://drive.google.com/uc?export=download&id=1zEcc1tPLEnZLpcls3IojIg64RfGYCcZp"


download_files () {
    read -p "Connect to the internet, and press enter to continue"

    echo "Downloading camera firmware."
    curl -L $camera_firmware --output /tmp/firmware.bin
    echo "Downloading autopilot firmware with bootloader."
    curl -L $autopilot_bootloader_firmware --output /tmp/autopilot-bootloader.px4
    echo "Downloading autopilot firmware."
    curl -L $autopilot_firmware --output /tmp/autopilot-normal.px4
    echo "Downloading Gimbal firmware."
    curl -L $gimbal_firmware --output /tmp/gimbal.yuneec
}

run_update () {
    echo ""
    echo "${bold}Power on the Mantis and connect to the Mantis Wifi${normal}"
    echo "${bold}Note: that it can take around 2 minutes until the wifi appears${normal}"
    echo ""
    echo "${bold}${red}Attention: make sure an SD card is inserted${normal}"
    read -p "Press enter to continue"
    
    echo ""
    echo "Uploading camera firmware, this will take several minutes..."
    curl -F "image=@/tmp/firmware.bin" -H "Expect:" -H "File-Size: $(stat -c%s /tmp/firmware.bin)" http://192.168.42.1/cgi-bin/upload
    echo "Done. The camera will now restart and apply the camera update..."
    read -p "Wait for the wifi again and connect to it, then press enter"

    echo ""
    echo "Uploading the autopilot bootloader..."
    mv /tmp/autopilot-bootloader.px4 /tmp/autopilot.px4
    curl -F "image=@/tmp/autopilot.px4" -H "Expect:" -H "File-Size: $(stat -c%s /tmp/autopilot.px4)" http://192.168.42.1/cgi-bin/upload
    mv /tmp/autopilot.px4 /tmp/autopilot-bootloader.px4

    echo "Updating the autopilot bootloader..."
    read -p "${bold}Wait for the PX4 startup beep, another beep, and then a positive beep${normal}..., afterwards press enter"

    echo ""
    echo "Uploading the autopilot firmware..."
    mv /tmp/autopilot-normal.px4 /tmp/autopilot.px4
    curl -F "image=@/tmp/autopilot.px4" -H "Expect:" -H "File-Size: $(stat -c%s /tmp/autopilot.px4)" http://192.168.42.1/cgi-bin/upload
    mv /tmp/autopilot.px4 /tmp/autopilot-normal.px4

    read -p "${bold}Wait for the PX4 startup beep${normal}..., afterwards press enter"

    echo ""
    echo "Uploading the gimbal firmware..."
    curl -F "image=@/tmp/gimbal.yuneec" -H "Expect:" -H "File-Size: $(stat -c%s /tmp/gimbal.yuneec)" http://192.168.42.1/cgi-bin/upload

    echo "Updating the gimbal..."
    read -r -p "${bold}Wait for gimbal to reboot and stabilize again...${normal} then press enter" response
    echo "All done, exiting."
}

echo ""
echo "${bold}Welcome to the Mantis updater...${normal}"
echo ""
echo "${bold}${red}Warning: after updating the Mantis, it is not possible to revert back to the Yuneec software."
echo "This means the Yuneec iOS and Android app will not work anymore!${normal}"
echo ""

read -r -p "Do you want to continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        download_files
        run_update
        ;;
    *)
        echo "Exiting."
        ;;
esac
