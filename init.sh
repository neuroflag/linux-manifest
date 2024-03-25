#!/usr/bin/env bash
set -eux
set -o pipefail

cd $(dirname ${BASH_SOURCE[0]})/../..

target=${1:-"prod"}

rsync --archive --verbose --exclude=.git ./neuroflag/ ./
rm -f ./.find-ignore
rm -f ./README.md

mkdir -p ./ubuntu_rootfs
ln -f -s $NEUROFLAG_MONOREPO/medical/hermione/rootfs/neuroflag-rootfs.img ./ubuntu_rootfs/neuroflag-rootfs.img
ln -f -s $NEUROFLAG_MONOREPO/medical/hermione/rootfs/develop-rootfs.img ./ubuntu_rootfs/develop-rootfs.img
ln -f -s ./neuroflag-rootfs.img ./ubuntu_rootfs/rootfs.img
if [[ $target == "dev" ]]; then
    ln -f -s ./develop-rootfs.img ./ubuntu_rootfs/rootfs.img
fi

./build.sh neuroflag-hermione-rk3588.mk
