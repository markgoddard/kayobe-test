#!/bin/bash -ex

# Clone the OpenStack kayobe repository and initialise a local installation.

set -o pipefail

STACKHPC_GITHUB=https://github.com/stackhpc

KC_REPO=${KC_REPO:-${STACKHPC_GITHUB}/kayobe-config}
KC_PATH=${KC_PATH:-kayobe-config}
KC_BRANCH=${KC_BRANCH:-master}

KAYOBE_REPO=${KAYOBE_REPO:-${STACKHPC_GITHUB}/kayobe}
KAYOBE_PATH=${KAYOBE_PATH:-kayobe}
KAYOBE_BRANCH=${KAYOBE_BRANCH:-master}

if [[ -e ${KC_PATH} ]]; then
    echo "Kayobe config checkout path $KC_PATH exists"
    exit 1
fi
if [[ -e ${KAYOBE_PATH} ]]; then
    echo "Kayobe checkout path $KAYOBE_PATH exists"
    exit 1
fi

if [[ ! -n ${KAYOBE_VAULT_PASSWORD} ]] ; then
    echo "Ansible Vault password environment variable $$KAYOBE_VAULT_PASSWORD not set - prompting"
    read -s -p "Enter Ansible Vault password:" KAYOBE_VAULT_PASSWORD
    export KAYOBE_VAULT_PASSWORD
fi

echo "Cloning alaska-kayobe-config"
git clone ${KC_REPO} ${KC_PATH} -b ${KC_BRANCH}

echo "Cloning kayobe"
git clone ${KAYOBE_REPO} ${KAYOBE_PATH} -b ${KAYOBE_BRANCH}

echo "Sourcing kayobe environment file"
source ${KC_PATH}/kayobe-env

echo "Creating a virtualenv for kayobe"
cd ${KAYOBE_PATH}
virtualenv kayobe-venv

echo "Installing kayobe in the virtualenv"
source kayobe-venv/bin/activate
pip install -U pip
pip install .

if ! which kayobe > /dev/null 2>&1 ; then
    echo "kayobe CLI not found on path"
    exit 1
fi

echo "Bootstrapping kayobe control host"
kayobe control host bootstrap

echo "Successfully cloned alaska kayobe environment"
