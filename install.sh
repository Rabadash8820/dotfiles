#!/bin/sh

for script in scripts/*.sh; do
    bash "$script" || break
done
