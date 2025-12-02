#!/bin/bash
set -eux

MOUNT_POINT=/mnt/nfs
SERVER=nfs

mkdir -p $MOUNT_POINT

# Garante serviços auxiliares no cliente (se presentes)
command -v rpcbind >/dev/null 2>&1 && rpcbind || true
command -v rpc.statd >/dev/null 2>&1 && rpc.statd || true


mount -t nfs -o vers=4 $SERVER:/ /mnt/nfs


echo "Conteúdo montado em $MOUNT_POINT:"
ls -la $MOUNT_POINT || true
