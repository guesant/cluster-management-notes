kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${RESTORED_VOLUME_NAME}-pv
spec:
  capacity:
    storage: "$(kubectl --namespace longhorn-system get volumes.longhorn.io "${RESTORED_VOLUME_NAME}" -o jsonpath='{.spec.size}')"
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: longhorn-static
  csi:
    driver: driver.longhorn.io
    volumeHandle: ${RESTORED_VOLUME_NAME}
    fsType: ext4
EOF
