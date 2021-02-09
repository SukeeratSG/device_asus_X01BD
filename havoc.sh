#!/bin/bash

# User Defined Stuff

folder="/home/sukeerat/havoc"
rom_name="Havoc-OS-v4.7"*.zip
gapps_command="WITH_GAPPS"
with_gapps="yes"
build_type="userdebug"
device_codename="X01BD"
use_brunch="yes"
OUT_PATH="$folder/out/target/product/${device_codename}"
lunch="havoc"
user="sukeerat"

# Default you can change it 

ccache_location=${folder}/../ccache 

# Make Clean , options uncomment  to chose 

# make_clean="yes"
# make_clean="no"
make_clean="installclean"

# Rom being built

ROM=${OUT_PATH}/${rom_name}

# Telegram Stuff

priv_to_me="/home/dump/configs/priv.conf"
newpeeps="/home/dump/configs/"$user.conf

cd "$folder"

echo -e "\rBuild starting thank you for waiting"
BLINK="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console"

# Send message to TG

read -r -d '' msg <<EOT
<b>Build Started</b>
${lunch} for  ${device_codename} 
<b>Console log:-</b> <a href="${BLINK}">here</a>
Good Luck ! Hope it Boots ! Happy Building ! 
Visit goindi.org  for more 
EOT

sudo telegram-send --format html "${msg}" --config ${priv_to_me} --disable-web-page-preview
sudo telegram-send --format html "${msg}" --config ${newpeeps} --disable-web-page-preview

# Time to build

if [ -d ${ccache_location} ]
then
	echo "Ccache folder  exists."
else
	sudo chmod -R 777 ${ccache_location}
	echo "Made Ccache Folder "
fi
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_DIR=${ccache_location}
ccache -M 75G

source build/envsetup.sh
export HAVOC_BUILD_TYPE=Official
export HAVOC_MAINTAINER=SukeeratSG
export HAVOC_GROUP_URL="https://t.me/havoc_X01BD"

if [ "$with_gapps" = "yes" ];
then
export "$gapps_command"=true
export TARGET_GAPPS_ARCH=arm64
fi

if [ "$with_gapps" = "no" ];
then
export "$gapps_command"=false
fi

# Clean build

if [ "$make_clean" = "yes" ];
then
rm -rf out 
echo -e "Clean Build";
fi

if [ "$make_clean" = "installclean" ];
then
rm -rf ${OUT_PATH}
echo -e "Install Clean";
fi

rm -rf ${OUT_PATH}/*.zip
lunch ${lunch}_${device_codename}-${build_type}

if [ "$use_brunch" = "yes" ];
then
brunch ${device_codename} 
fi

if [ "$use_brunch" = "no" ];
then
make  ${lunch} -j$(nproc --all) 
fi

if [ "$use_brunch" = "bacon" ];
then
make bacon -j$(nproc --all) 
fi

if [ -f $ROM ]; then

mkdir -p /home/dump/sites/goindi/downloads/${user}/${device_codename}
cp $ROM /home/dump/sites/goindi/downloads/${user}/${device_codename}

filename="$(basename $ROM)"
LINK="https://download.goindi.org/${user}/${device_codename}/${filename}"
size="$(du -h ${ROM}|awk '{print $1}')"
mdsum="$(md5sum ${ROM}|awk '{print $1}')"
read -r -d '' priv <<EOT
Yay it's finished !
${lunch} for  ${device_codename} 
<b>Download:-</b> <a href="${LINK}">here</a>
<b>Size:-</b> <pre> ${size}</pre>
<b>Md5:-</b> <pre> ${mdsum}</pre>  
EOT

else

read -r -d '' priv <<EOT
<b>Error Generated</b>
<b>Check error:-</b> <a href="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console">here</a>
EOT
fi

sudo telegram-send --format html "$priv" --config ${priv_to_me} --disable-web-page-preview
sudo telegram-send --format html "$priv" --config ${newpeeps} --disable-web-page-preview
