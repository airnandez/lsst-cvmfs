#!/bin/sh

# Configure this machine as a CernVM FS client to access LSST
# software repository served by CC-IN2P3.
# This script can be run multiple times.
# More information: https://github.com/airnandez/lsst-cvmfs

# We must run as 'root'
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Exit on error
set -e

# Run CernVM FS configuration
if [ ! -x /usr/bin/cvmfs_config ]; then
    echo "Could not find CernVM FS configuration tool"
    exit 1
fi
/usr/bin/cvmfs_config setup

# Configure CernVM FS
# WARNING: make sure we don't overwrite any existing configuration, different
# than ours
if [ -e /etc/cvmfs/default.local ]; then
    diff "/etc/cvmfs/default.local" "default.local" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "CernVM FS seems to be already configured in this machine in a potentially incompatible way"
        echo "see file /etc/cvmfs/default.local"
        exit 1
    fi
fi
cp default.local /etc/cvmfs/default.local
chmod 0644 /etc/cvmfs/default.local

# Configure the LSST repository and store its public key
cp lsst.in2p3.fr.conf /etc/cvmfs/config.d/lsst.in2p3.fr.conf
chmod 0644 /etc/cvmfs/config.d/lsst.in2p3.fr.conf
cp lsst.in2p3.fr.pub /etc/cvmfs/keys/lsst.in2p3.fr.pub
chmod 0444 /etc/cvmfs/keys/lsst.in2p3.fr.pub

# On Linux, check this configuration
thisOS=`uname`
if [ "$thisOS" == "Linux" ]; then
    result=`/usr/bin/cvmfs_config chksetup`
    if [ "$result" != "OK" ]; then
        echo "There was an error checking your CernVM FS configuration:"
        echo $result
        exit 1
    fi
fi

# Check that we can reach the CernVM FS server
source ./lsst.in2p3.fr.conf
curl -s --proxy ${CVMFS_HTTP_PROXY} --head ${CVMFS_SERVER_URL} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Cannot reach repository proxy server: $CVMFS_HTTP_PROXY"
    exit 1
fi


# On Linux, restart autofs
if [ "$thisOS" == "Linux" ]; then
    service autofs restart > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Could not restart autofs service"
        exit 1
    fi
fi

# Done
exit 0
