#!/bin/sh

cfgFilePath=$1
if [ -z "$cfgFilePath" ]; then
    echo "Config file path was not provided. Exiting..."
    exit 1
fi

if [ ! -f "$cfgFilePath" ]; then
    echo "Config file at '$cfgFilePath' does not exist. Exiting..."
    exit 1
fi

echo "Loading configuration from '$cfgFilePath'..."