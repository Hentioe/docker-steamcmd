#!/usr/bin/env bash

steamcmd +force_install_dir \
    steamapps/common/PalServer +login anonymous +app_update 2394010 validate +quit

exec steamapps/common/PalServer/PalServer.sh
