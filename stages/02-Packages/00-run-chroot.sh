#!/bin/bash

# # This runs in context if the image (CHROOT)
# # Do not use log here, it will end up in the image
# # This stage will install and remove packages which are required to get OpenHD to work
# # If anything fails here the script is failing!

set -e


echo "debug"
ls -l --block-size=M /opt/additionalFiles/


# X20 specific code
function install_x20_packages {
    rm -Rf /etc/apt/sources.list.d/*
    rm -Rf /etc/apt/sources.list
    BASE_PACKAGES="openhd-x20"
    PLATFORM_PACKAGES_REMOVE="*boost* locales guile-2.2-libs network-manager"
    PLATFORM_PACKAGES=""
}

# Raspbian-specific code
function fix_stupid_libcamera_rpi {
    sudo apt remove -y libcamera0
    wget https://github.com/ArduCAM/Arducam-Pivariety-V4L2-Driver/releases/download/libcamera-v0.0.5/libcamera0_0_git20230724+ad9428b4-1_armhf.deb
    dpkg -i libcamera0_0_git20230724+ad9428b4-1_armhf.deb
    sudo apt install -y python3-picamera2
    rm -Rf *.deb
}

function install_raspbian_packages {
    sudo apt update && apt remove -y dkms
    BASE_PACKAGES="openhd qopenhd apt-transport-https apt-utils open-hd-web-ui"
    PLATFORM_PACKAGES_HOLD="raspberrypi-kernel libraspberrypi-dev libraspberrypi-bin libraspberrypi0 libraspberrypi-doc raspberrypi-bootloader"
    PLATFORM_PACKAGES_REMOVE="locales gdb librsvg2-2 guile-2.2-libs firmware-libertas gcc-10 nfs-common libcamera* raspberrypi-kernel"
    PLATFORM_PACKAGES="firmware-atheros openhd-userland libseek-thermal libcamera-openhd openhd-qt openssh-server"
}
# Ubuntu-Rockship-specific code
function install_radxa-ubuntu_packages {
    BASE_PACKAGES="openhd apt-transport-https apt-utils open-hd-web-ui"
    PLATFORM_PACKAGES="rsync qopenhd procps gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-tools gstreamer1.0-rockchip1 gstreamer1.0-gl mali-g610-firmware malirun rockchip-multimedia-config librist4 librist-dev rist-tools libv4l-0 libv4l2rds0 libv4lconvert0 libv4l-dev libv4l-rkmpp qv4l2 v4l-utils librockchip-mpp1 librockchip-mpp-dev librockchip-vpu0 rockchip-mpp-demos librga2 librga-dev libegl-mesa0 libegl1-mesa-dev libgbm-dev libgl1-mesa-dev libgles2-mesa-dev libglx-mesa0 mesa-common-dev mesa-vulkan-drivers mesa-utils libwidevinecdm"
}

function install_radxa-debian_packages {
    BASE_PACKAGES="openhd apt-transport-https apt-utils open-hd-web-ui"
    PLATFORM_PACKAGES_HOLD="r8125-dkms 8852bu-dkms 8852be-dkms task-rockchip radxa-system-config-rockchip linux-image-rock-5a linux-image-5.10.110-6-rockchip linux-image-5.10.110-11-rockchip"
    PLATFORM_PACKAGES_REMOVE="dkms sddm plymouth plasma-desktop kde*"
    PLATFORM_PACKAGES="rockchip-iq-openhd linux-headers-5.10.110-99-rockchip-g9c3b92612 linux-image-5.10.110-99-rockchip-g9c3b92612 rsync procps mpv camera-engine-rkaiq"
}
function install_radxa-debian_packages_rk3566 {
    mkdir -p /usr/local/share/openhd_platform/rock/rk3566
    BASE_PACKAGES="linux-image-5.10.160-radxa-rk356x linux-headers-5.10.160-radxa-rk356x linux-libc-dev-5.10.160-radxa-rk356x openhd qopenhd-rk3566 apt-transport-https apt-utils open-hd-web-ui"
    PLATFORM_PACKAGES_HOLD="u-boot-radxa-zero3 radxa-system-config-common radxa-system-config-kernel-cmdline-ttyfiq0 radxa-firmware radxa-system-config-bullseye 8852be-dkms task-rockchip radxa-system-config-rockchip linux-image-radxa-cm3-rpi-cm4-io linux-headers-radxa-cm3-rpi-cm4-io linux-image-5.10.160-12-rk356x linux-headers-5.10.160-12-rk356x"
    PLATFORM_PACKAGES="dialog pv gst-latest net-tools isc-dhcp-client network-manager glances rockchip-iq-openhd librga2=2.2.0-1 procps camera-engine-rkaiq"
    PLATFORM_PACKAGES_REMOVE="dnsmasq codium firefox* dkms sddm plymouth plasma-desktop kde* lightdm *xfce* chromium"
}
function install_packages-core3566 {
    BASE_PACKAGES="openhd qopenhd-rk3566 apt-transport-https apt-utils open-hd-web-ui"
    PLATFORM_PACKAGES="dialog pv gst-latest net-tools isc-dhcp-client network-manager glances rockchip-iq-openhd librga2=2.2.0-1 linux-image-5.10.160-core3566-rk356x linux-headers-5.10.160-core3566-rk356x linux-libc-dev-5.10.160-core3566-rk356x procps camera-engine-rkaiq"
    PLATFORM_PACKAGES_REMOVE="firefox* dkms sddm plymouth plasma-desktop kde*"
}


# Ubuntu-x86-specific code
function install_ubuntu_x86_packages {
        if [[ "${DISTRO}" == "jammy" ]]; then
        PLATFORM_PACKAGES_HOLD="dkms initramfs-tools grub-pc linux-image-5.15.0-57-generic grub-efi-amd64-signed linux-generic linux-headers-generic linux-image-generic linux-generic-hwe-22.04 linux-image-generic-hwe-22.04 linux-headers-generic-hwe-22.04"
        else
        PLATFORM_PACKAGES_HOLD="grub-efi-amd64-bin grub-efi-amd64-signed linux-generic linux-headers-generic linux-image-generic linux-libc-dev"
        fi
    BASE_PACKAGES="openhd apt-transport-https apt-utils open-hd-web-ui"
    PLATFORM_PACKAGES="rtl8852bu-x86 rtl88x2bu-x86 rtl8812au-x86 gnome-disk-utility openssh-server gnome-terminal qopenhd python3-pip htop libavcodec-dev libavformat-dev libelf-dev libboost-filesystem-dev libspdlog-dev build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libssl-dev libpng-dev libjpeg-dev libglib2.0-dev libgles2-mesa-dev libgbm-dev libdrm-dev libwayland-dev pulseaudio libpulse-dev flex bison gperf libre2-dev libnss3-dev libdrm-dev libxml2-dev libxslt1-dev libminizip-dev libjsoncpp-dev liblcms2-dev libevent-dev libprotobuf-dev protobuf-compiler libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-x11-dev libgtk2.0-dev libgtk-3-dev libfuse2 mono-complete mono-runtime libmono-system-windows-forms4.0-cil libmono-system-core4.0-cil libmono-system-management4.0-cil libmono-system-xml-linq4.0-cil libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-dev gstreamer1.0-pulseaudio gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-qt5 openhdimagewriter"
    PLATFORM_PACKAGES_REMOVE=""
}

function clone_github_repos {
    cd /opt
    git clone --recursive --depth 1 https://github.com/OpenHD/OpenHD
    git clone --recursive --depth 1 https://github.com/OpenHD/QOpenHD
    git clone https://github.com/OpenHD/veye_raspberrypi.git
    chmod -R 777 /opt
}

function install_openhd {

    if [[ "${OS}" == "debian-X20" ]]; then
        install_x20_packages
    elif [[ "${OS}" == "raspbian" ]]; then
        #fix_stupid_libcamera_rpi
        install_raspbian_packages
    elif [[ "${OS}" == "radxa-ubuntu-rock5b" ]] || [[ "${OS}" == "radxa-ubuntu-rock5a" ]] ; then
        sudo add-apt-repository -r "deb https://ppa.launchpadcontent.net/jjriek/rockchip/ubuntu jammy main"
        install_radxa-ubuntu_packages
    elif [[ "${OS}" == "radxa-debian-rock5a" ]] || [[ "${OS}" == "radxa-debian-rock5b" ]]  ; then
        install_radxa-debian_packages
    elif [[ "${OS}" == "radxa-debian-rock-cm3" ]] ; then
        install_radxa-debian_packages_rk3566
    elif [[ "${OS}" == "radxa-debian-rock-cm3-core3566" ]] ; then
        install_packages-core3566
    elif [[ "${OS}" == "ubuntu-x86" ]] ; then
        install_ubuntu_x86_packages
    elif [[ "${OS}" == "ubuntu" ]] ; then
        fix_jetson_apt
        install_jetson_packages
    fi

     # Add OpenHD Repository platform-specific packages
        apt install -y curl
        curl -1sLf 'https://dl.cloudsmith.io/public/openhd/release/setup.deb.sh'| sudo -E bash
        #curl -1sLf 'https://dl.cloudsmith.io/public/openhd/dev-release/setup.deb.sh'| sudo -E bash
        apt update

    # Remove platform-specific packages
        echo "Removing platform-specific packages..."
        for package in ${PLATFORM_PACKAGES_REMOVE}; do
        echo "Removing ${package}..."
        apt purge -y ${package}
        if [ $? -ne 0 ]; then
            echo "Failed to remove ${package}!"
            exit 1
        fi
        done

    #cleanup before installing packages
    apt autoremove -y

    # Hold platform-specific packages
    echo "Holding back platform-specific packages..."
    for package in ${PLATFORM_PACKAGES_HOLD}; do
        echo "Holding ${package}..."
        apt-mark hold ${package} || true
        if [ $? -ne 0 ]; then
            echo "Failed to hold ${package}!"
        fi
    done
    #Cleapup
    apt autoremove -y
    apt upgrade -y --allow-downgrades

    # Install platform-specific packages
    echo "Installing platform-specific packages..."
    for package in ${BASE_PACKAGES} ${PLATFORM_PACKAGES}; do
        echo "Installing ${package}..."
        apt install -y -o Dpkg::Options::="--force-overwrite" --no-install-recommends --allow-downgrades ${package}
        if [ $? -ne 0 ]; then
            echo "Failed to install ${package}!"
            exit 1
        fi
    done

    #dirty hack for the 2.5 release to get rock5a working
    if [[ "${OS}" == "radxa-debian-rock5a" ]]; then
        apt install -y qopenhd-rk3588a
    fi

    if [[ "${OS}" == "radxa-debian-rock5b" ]]; then
        apt install -y qopenhd-rk3588
    fi

    # Clean up packages and cache
    echo "Cleaning up packages and cache..."
    apt autoremove -y
    apt clean
    rm -rf /var/lib/apt/lists/*
    rm -rf /var/cache/apt/archives/*
    rm -rf /usr/share/doc/*
    rm -rf /usr/share/man/*

}

cd /opt/additionalFiles/
ls -a
if [ ! -e emmc ]; then
    install_openhd
    rm -Rf /opt/additionalFiles/
else
    apt update
    #dirty hack to remove sddm without everything failing .. thanks radxa
    mkdir -p /usr/share/sddm/themes/breeze/
    touch /usr/share/sddm/themes/breeze/Main.qml
    apt remove -y radxa-sddm-theme
    mkdir -p /etc/pulse/
    touch default.pa
    apt remove -y rockchip-pulseaudio-config
    #now removing everything else
    PLATFORM_PACKAGES_REMOVE="dnsmasq libllvm* firmware-misc-nonfree libmali-bifrost-g52-g2p0-x11-gbm adwaita-icon-theme firmware-brcm80211 network-manager desktop-base libcairo2 libvulkan1 xdg-desktop-portal libgtk-3-common firmware-iwlwifi fonts-noto-cjk linux-image-5.10.160-20-rk356x rockchip-pulseaudio-config rockchip* x11-common  gstreamer* libavcodec58 libavformat58 libavfilter7 libcups2 libgstreamer* libopencv* libqt5* codium firefox* dkms plymouth plasma-desktop kde* lightdm *xfce* chromium"
    
        # Remove platform-specific packages
        echo "Removing platform-specific packages..."
        for package in ${PLATFORM_PACKAGES_REMOVE}; do
        echo "Removing ${package}..."
        apt purge -y ${package}
        if [ $? -ne 0 ]; then
            echo "Failed to remove ${package}!"
            exit 1
        fi
        done

    curl -1sLf 'https://dl.cloudsmith.io/public/openhd/dev-release/setup.deb.sh'| sudo -E bash
    apt install linux-image-5.10.160-radxa-rk356x pv
    apt autoremove -y --allow-remove-essential
    sudo apt-get clean -y
    cd /opt/additionalFiles/
    cp /opt/additionalFiles/*.sh /usr/local/bin/
    mkdir -p /boot/openhd/
    touch /boot/openhd/rock-rk3566.txt
    touch /boot/openhd/resize.txt
    df -h
    gunzip -v emmc.img.gz
    ls -l --block-size=M 

fi

#
# Write the openhd package version back to the base of the image and
# in the work dir so the builder can use it in the image name
export OPENHD_VERSION=$(dpkg -s openhd | grep "^Version" | awk '{ print $2 }')

echo ${OPENHD_VERSION} > /openhd_version.txt
echo ${OPENHD_VERSION} > /boot/openhd_version.txt