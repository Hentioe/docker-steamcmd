#!/usr/bin/env bash

ROOT_DIR=steamapps/common/PalServer

steamcmd +force_install_dir $ROOT_DIR +login anonymous +app_update 2394010 validate +quit

SAVED_CONFIG_DIR=$ROOT_DIR/Pal/Saved/Config/LinuxServer
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

    cp $ROOT_DIR/DefaultPalWorldSettings.ini $SETTINGS_FILE
fi

if [ $# -gt 0 ]; then
    ARGS="$@"
fi

exec $ROOT_DIR/PalServer.sh "$ARGS"
