#!/bin/bash -ex

# Clone the OpenStack P3 config repository and initialise a local installation.

set -o pipefail

SDP_GITHUB=https://github.com/SKA-ScienceDataProcessor

P3C_REPO=${P3C_REPO:-${SDP_GITHUB}/p3-config}
P3C_PATH=${P3C_PATH:-p3-config}
P3C_BRANCH=${P3C_BRANCH:-master}

if [[ -e ${P3C_PATH} ]]; then
    echo "P3 config checkout path $P3C_PATH exists"
    exit 1
fi

echo "Cloning p3-config"
git clone ${P3C_REPO} ${P3C_PATH} -b ${P3C_BRANCH}

echo "Creating a virtualenv for p3-config"
cd ${P3C_PATH}
virtualenv p3-config-venv

echo "Installing p3-config in the virtualenv"
source p3-config-venv/bin/activate
pip install -U pip
pip install -r requirements.txt

if ! which ansible > /dev/null 2>&1 ; then
    echo "Ansible CLI not found on path"
    exit 1
fi

echo "Installing roles from Ansible Galaxy"
ansible-galaxy install \
  -p ansible/roles \
  -r ansible/requirements.yml

echo "Successfully cloned p3-config environment"
