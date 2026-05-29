#!/system/bin/sh
# uninstall: restore original state

MODDIR=${0%/*}
NLL="/dev/null"

# setup uninstall logging
LOG_FILE="/tmp/gmsforge_uninstall.log"
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [uninstall] $1" >> "$LOG_FILE"
}
log "=== GmsForge uninstall started ==="

# gms components
GMS="com.google.android.gms"
GC1="auth.managed.admin.DeviceAdminReceiver"
GC2="mdm.receivers.MdmDeviceAdminReceiver"

# reenable device administrators
log "Re-enabling device administrators"
for user_dir in /data/user/*; do
  [ -d "$user_dir" ] || continue
  U="${user_dir##*/}"
  for C in $GC1 $GC2; do
    if pm enable --user "$U" "$GMS/$GMS.$C" > $NLL 2>&1; then
      log "Enabled: $GMS.$C (user $U)"
    else
      log "Warning: Failed to enable $GMS.$C (user $U)"
    fi
  done
done

# restore gms to deviceidle whitelist
log "Restoring GMS to deviceidle whitelist"
if dumpsys deviceidle whitelist +com.google.android.gms > $NLL 2>&1; then
  log "Restored GMS to battery whitelist"
else
  log "Warning: Failed to restore GMS to battery whitelist"
fi

# restore xml backups if available
BACKUP_DIR="$MODDIR/.backup"
if [ -d "$BACKUP_DIR/module_xml" ]; then
  log "Restoring XML backups"
  for BACKUP in "$BACKUP_DIR/module_xml"/*; do
    [ -f "$BACKUP" ] || continue
    # reconstruct original path from backup name
    ORIG_PATH="$(basename "$BACKUP" | tr '@' '/')"
    if [ -f "$ORIG_PATH" ]; then
      if cp -af "$BACKUP" "$ORIG_PATH" 2> $NLL; then
        log "Restored: $ORIG_PATH"
      else
        log "Warning: Failed to restore $ORIG_PATH"
      fi
    fi
  done
fi

# remove module data
log "Removing module persistent folder"
rm -rf /data/adb/gmsforge

log "Uninstall complete"
exit 0
