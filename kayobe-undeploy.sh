#!/bin/bash -ex

# Undeploy a control plane using OpenStack kayobe.

set -o pipefail

KC_PATH=${KC_PATH:-kayobe-config}
KAYOBE_PATH=${KAYOBE_PATH:-kayobe}

function init_kayobe {
    if [[ ! -n ${KAYOBE_VAULT_PASSWORD} ]] ; then
        echo "Ansible Vault password environment variable $$KAYOBE_VAULT_PASSWORD not set - prompting"
        read -s -p "Enter Ansible Vault password:" KAYOBE_VAULT_PASSWORD
        export KAYOBE_VAULT_PASSWORD
    fi

    if [[ ! -e ${KAYOBE_PATH} ]] ; then
        echo "Kayobe checkout does not exist at ${KAYOBE_PATH}"
        exit 1
    fi

    if [[ ! -e ${KC_PATH} ]] ; then
        echo "Kayobe config checkout does not exist at ${KC_PATH}"
        exit 1
    fi

    echo "Sourcing kayobe environment file"
    source ${KC_PATH}/kayobe-env

    echo "Activating the kayobe virtualenv"
    cd ${KAYOBE_PATH}
    source kayobe-venv/bin/activate

    if ! which kayobe > /dev/null 2>&1 ; then
        echo "Kayobe CLI not found on path"
        exit 1
    fi
}

function undeploy_control_plane {
    echo "Deprovisioning kayobe overcloud hosts"
    time kayobe overcloud deprovision
}

function main {
    init_kayobe
    undeploy_control_plane
}

main
