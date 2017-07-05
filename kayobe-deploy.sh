#!/bin/bash -ex

# Deploy a control plane and discover bare metal compute nodes using OpenStack
# kayobe.

set -o pipefail

KC_PATH=${KC_PATH:-kayobe-config}
KAYOBE_PATH=${KAYOBE_PATH:-kayobe}

NUM_COMPUTE_NODES=${NUM_COMPUTE_NODES:-2}
DISCOVERY_TIMEOUT=${DISCOVERY_TIMEOUT:-600}

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

function deploy_control_plane {
    echo "Provisioning kayobe overcloud hosts"
    time kayobe overcloud provision

    echo "Configuring overcloud host services"
    time kayobe overcloud host configure --wipe-disks

    echo "Pulling overcloud container images"
    time kayobe overcloud container image pull

    echo "Deploying containerised overcloud services"
    time kayobe overcloud service deploy

    source ${KOLLA_CONFIG_PATH:-/etc/kolla}/public-openrc.sh

    echo "Performing overcloud post-deployment configuration"
    time kayobe overcloud post configure
}

function discover_compute_nodes {
    source ${KOLLA_CONFIG_PATH:-/etc/kolla}/public-openrc.sh

    echo "Configuring control and provisioning network for compute node discovery"
    time kayobe physical network configure --group ctl-switches --enable-discovery

    echo "Triggering bare metal compute node discovery"
    time kayobe playbook run ansible/dell-compute-node-discovery.yml

    # Wait for compute nodes to be discovered.
    local discovery_start=$(date +%s)
    local discovery_end=$((discovery_start + DISCOVERY_TIMEOUT))
    echo "Waiting for bare metal compute nodes to be discovered"
    while true ; do
        local discovered_nodes=$(openstack baremetal node list -f value | wc -l)
        if [[ $discovered_nodes -ge ${NUM_COMPUTE_NODES} ]] ; then
            echo "Discovered all ($NUM_COMPUTE_NODES) bare metal compute nodes"
            break
        fi
        if [[ $(date +%s) -gt $discovery_end ]]; then
            echo "Timed out waiting for discovery of bare metal compute nodes"
            exit 1
        fi
        echo "Discovered $discovered_nodes of $NUM_COMPUTE_NODES bare metal compute nodes - sleeping"
        sleep 10
    done

    echo "Providing compute nodes"
    time kayobe playbook run ansible/compute-node-provide.yml
}

function main {
    init_kayobe
    deploy_control_plane
    discover_compute_nodes
}

main
