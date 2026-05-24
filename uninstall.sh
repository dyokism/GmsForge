#!/system/bin/sh
# uninstall: restore original state

MODDIR=${0%/*}
NLL="/dev/null"

# gms components
GMS="com.google.android.gms"
GC1="auth.managed.admin.DeviceAdminReceiver"
GC2="mdm.receivers.MdmDeviceAdminReceiver"

# reenable device administrators
for U in $(ls /data/user); do
  for C in $GC1 $GC2; do
    pm enable --user "$U" "$GMS/$GMS.$C" > $NLL 2>&1
  done
done

# restore gms to deviceidle whitelist
dumpsys deviceidle whitelist +com.google.android.gms > $NLL 2>&1

# restore xml backups if available
BACKUP_DIR="$MODDIR/.backup"
if [ -d "$BACKUP_DIR/module_xml" ]; then
  for BACKUP in "$BACKUP_DIR/module_xml"/*; do
    [ -f "$BACKUP" ] || continue
    # reconstruct original path from backup name
    ORIG_PATH="$(basename "$BACKUP" | sed 's/^_/\//;s/_/\//g')"
    if [ -f "$ORIG_PATH" ]; then
      cp -af "$BACKUP" "$ORIG_PATH" 2> $NLL
    fi
  done
fi

# remove module data
rm -rf /data/adb/gmsforge

exit 0
