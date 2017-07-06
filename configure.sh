#!/bin/bash

# Configure this machine as a CernVM FS client to access LSST
# software repository served by CC-IN2P3.
# This script can be run multiple times.
# More information: https://github.com/airnandez/lsst-cvmfs

# We must run as 'root'
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Run CernVM FS configuration
if [ ! -x /usr/bin/cvmfs_config ]; then
    echo "Could not find CernVM FS configuration tool"
    exit 1
fi
/usr/bin/cvmfs_config setup
if [ $? -ne 0 ]; then
    exit 1
fi

# Configure CernVM FS
# WARNING: make sure we don't overwrite any existing configuration, different
# than ours
localConfig="/etc/cvmfs/default.local"
if [ -e ${localConfig} ]; then
    repos=`grep CVMFS_REPOSITORIES ${localConfig} | sed s/CVMFS_REPOSITORIES=//g`
    if [ -n $repos ] && [ $repos != "lsst.in2p3.fr" ]; then
        echo "CernVM FS seems to be already configured in this machine in a potentially incompatible way"
        echo "see file /etc/cvmfs/default.local"
        exit 1
    fi
fi
cp default.local /etc/cvmfs/default.local && \
    chmod 0644 /etc/cvmfs/default.local

# Configure the LSST repository and store its public key
cp lsst.in2p3.fr.conf /etc/cvmfs/config.d/lsst.in2p3.fr.conf && \
    chmod 0644 /etc/cvmfs/config.d/lsst.in2p3.fr.conf

rm -f /etc/cvmfs/keys/lsst.in2p3.fr.pub
mkdir -p /etc/cvmfs/keys/in2p3.fr && \
    cp lsst.in2p3.fr.pub /etc/cvmfs/keys/in2p3.fr/lsst.in2p3.fr.pub && \
    chmod 0444 /etc/cvmfs/keys/in2p3.fr/lsst.in2p3.fr.pub

# Perform system-specific tasks
thisOS=`uname`
if [ "$thisOS" == "Linux" ]; then
    # Make /etc/cvmfs/domain.d to make 'cvmfs_config' happy
    mkdir -p /etc/cvmfs/domain.d

    # Use 'cvmfs_config' to check the configuration
    result=`/usr/bin/cvmfs_config chksetup`
    if [ "$result" != "OK" ]; then
        echo "There was an error checking your CernVM FS configuration:"
        echo $result
        exit 1
    fi

    # Restart autofs
    service autofs restart > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Could not restart autofs service"
        exit 1
    fi
elif [ "$thisOS" == "Darwin" ]; then
    # On MacOS X, create the mount directory
    mkdir -p /cvmfs/lsst.in2p3.fr
fi

# Done
exit 0
