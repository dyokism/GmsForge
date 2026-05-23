#!/system/bin/sh
# boot service: optimize gms at runtime

MODDIR=${0%/*}
LOG_FILE="$MODDIR/service.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [service] $1" >> "$LOG_FILE"
}

(
  # wait for boot completion
  TIMEOUT=300
  ELAPSED=0

  while [ "$(resetprop sys.boot_completed)" != "1" ] || [ ! -d /sdcard ]; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
      log "ERROR: Boot wait timed out after ${TIMEOUT}s. Proceeding anyway."
      break
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
  done

  log "Boot completed (waited ${ELAPSED}s)"

  # gms components
  GMS="com.google.android.gms"
  GC1="auth.managed.admin.DeviceAdminReceiver"
  GC2="mdm.receivers.MdmDeviceAdminReceiver"
  NLL="/dev/null"

  # disable device administrators
  log "Disabling GMS device admin components"
  for U in $(ls /data/user); do
    for C in $GC1 $GC2; do
      if pm disable --user "$U" "$GMS/$GMS.$C" > $NLL 2>&1; then
        log "Disabled: $GMS.$C (user $U)"
      else
        log "Warning: Could not disable $GMS.$C (user $U)"
      fi
    done
  done

  # add gms to battery optimization
  if dumpsys deviceidle whitelist -com.google.android.gms > $NLL 2>&1; then
    log "Removed GMS from deviceidle whitelist"
  else
    log "Warning: Failed to remove GMS from deviceidle whitelist"
  fi

  log "Service execution complete"
  exit 0
)
