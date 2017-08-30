#!/bin/bash -ex

# Run the P3 config tool.

set -o pipefail

P3C_PATH=${P3C_PATH:-p3-config}

if [[ ! -e ${P3C_PATH} ]]; then
    echo "P3 config checkout path $P3C_PATH does not exist"
    exit 1
fi

if [[ -z ${OS_AUTH_URL} ]]; then
    echo "OpenStack authentication parameters not provided"
    exit 1
fi

cd ${P3C_PATH}

echo "Running p3-config for P3 project"
./tools/p3-config -p ansible/p3-project.yml

echo "Running p3-config for everything"
./tools/p3-config

echo "Successfully ran p3-config"
