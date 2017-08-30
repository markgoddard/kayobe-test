===========
Kayobe Test
===========

Tools for testing the OpenStack `kayobe <https://github.com/stackhpc/kayobe>`_
project.

* License: Apache 2.0

Configuration
=============

Set the following environment variables as required:

* ``KC_REPO``: URL of kayobe-config repo. Default https://github.com/stackhpc/kayobe-config.
* ``KC_BRANCH``: Branch of kayobe-config to clone. Default master.
* ``KC_PATH``: Path at which to clone kayobe-config repo. Default kayobe-config.
* ``KAYOBE_REPO``: URL of kayobe repo. Default https://github.com/stackhpc/kayobe.
* ``KAYOBE_BRANCH``: Branch of kayobe to clone. Default master.
* ``KAYOBE_PATH``: Path at which to clone kayobe repo. Default kayobe.
* ``P3C_REPO``: URL of p3-config repo. Default https://github.com/SKA-ScienceDataProcessor/p3-config.
* ``P3C_BRANCH``: Branch of p3-config to clone. Default master.
* ``P3C_PATH``: Path at which to clone p3-config repo. Default p3-config.
* ``NUM_COMPUTE_NODES``: Number of compute nodes expected to be discovered. Default 2.
* ``DISCOVERY_TIMEOUT``: Time to wait for compute nodes to be discoverd. Default 600.

Usage
=====

Clone kayobe and kayobe-config::

    ./kayobe-clone.sh

Deploy a control plane and discover compute nodes::

    ./kayobe-deploy.sh

Clone P3 config::

    ./p3-config-clone.sh

Apply P3 config::

    ./p3-config-run.sh

Undeploy a control plane::

    ./kayobe-undeploy.sh
