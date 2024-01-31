#!/usr/bin/env bash

steamcmd +force_install_dir \
    steamapps/common/PalServer +login anonymous +app_update 2394010 validate +quit

SAVED_CONFIG_DIR=steamapps/common/PalServer/Pal/Saved/Config/LinuxServer
SETTINGS_FILE=$SAVED_CONFIG_DIR/PalWorldSettings.ini

if [[ ! -f $SETTINGS_FILE ]]; then
    mkdir -p $SAVED_CONFIG_DIR
    touch $SETTINGS_FILE
fi

# 读取用户配置的内容（清理空白字符）。
SETTINGS_CONTENT=$(cat $SETTINGS_FILE | tr -d '\n')

if [[ "$SETTINGS_CONTENT" =~ ^[[:space:]]*$ ]]; then
    # 配置文件不存在或内容为空，复制默认配置。
    echo "Copying default config file..."

    cp steamapps/common/PalServer/DefaultPalWorldSettings.ini $SETTINGS_FILE
fi

exec steamapps/common/PalServer/PalServer.sh
