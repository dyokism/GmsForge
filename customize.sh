#!/system/bin/sh
# shellcheck disable=SC3043,SC2181
# installation entrypoint

set -x

INSTALL_LOG="$MODPATH/install.log"
log() {
  echo "$(date '+%H:%M:%S') $1" >> "$INSTALL_LOG"
}
log "=== GmsForge installation ==="

# check root type
ui_print "- Checking root implementation"
if [ "$BOOTMODE" ] && [ "$KSU" ]; then
  ui_print "- Installing from KernelSU app"
  ui_print "  KernelSU version: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
  log "Root: KernelSU ($KSU_KERNEL_VER_CODE/$KSU_VER_CODE)"
  if [ "$(which magisk)" ]; then
    ui_print "  Multiple root implementation is NOT supported"
    abort "  Aborting!"
  fi
elif [ "$BOOTMODE" ] && [ "$APATCH" ]; then
  ui_print "- Installing from APatch app"
  ui_print "  APatch version: $APATCH_VER_CODE"
  log "Root: APatch ($APATCH_VER_CODE)"
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
  ui_print "- Installing from Magisk app"
  ui_print "  Magisk version: $MAGISK_VER_CODE"
  log "Root: Magisk ($MAGISK_VER_CODE)"
else
  ui_print "  Installation from recovery is NOT supported"
  ui_print "  Please install from Magisk / KernelSU / APatch app"
  abort "  Aborting!"
fi

# check android api
if [ "$API" -lt 23 ]; then
  abort "- Unsupported API version: $API (requires 23+)"
fi
ui_print "- Android API: $API"
log "API: $API"

# patch xml files
ui_print "- Patching XML files"
log "Starting XML patching"

GMS0="\"com.google.android.gms\""
STR1="allow-in-power-save package=$GMS0"
STR2="allow-in-data-usage-save package=$GMS0"
NULL="/dev/null"

# search system xml files with gms whitelist
ui_print "- Searching default XML files"
SYS_XML="$(
  SXML="$(find /system_ext/* /system/* /product/* \
    /vendor/* /india/* /my_bigball/* -type f -iname '*.xml' -print 2> $NULL)"
  for S in $SXML; do
    if grep -qE "$STR1|$STR2" "$ROOT$S" 2> $NULL; then
      echo "$S"
    fi
  done
)"

PATCH_SX() {
  local patched=0
  local backup_dir="$MODPATH/.backup/system_xml"

  for SX in $SYS_XML; do
    mkdir -p "$(dirname "$MODPATH$SX")"

    # backup original xml before patching
    mkdir -p "$backup_dir"
    local backup_name
    backup_name="$(echo "$SX" | tr '/' '@')"
    cp -af "$ROOT$SX" "$backup_dir/$backup_name" 2> $NULL
    log "Backup: $SX -> .backup/system_xml/$backup_name"

    cp -af "$ROOT$SX" "$MODPATH$SX"
    ui_print "  Patching: $SX"
    sed -i "/$STR1/d;/$STR2/d" "$MODPATH$SX"

    if [ $? -eq 0 ]; then
      log "Patched: $SX"
      patched=$((patched + 1))
    else
      ui_print "  ! Warning: Failed to patch $SX"
      log "FAILED: $SX"
    fi
  done

  # move patched files for magisk overlay
  for P in product vendor; do
    if [ -d "$MODPATH/$P" ]; then
      ui_print "- Moving files to module directory"
      mkdir -p "$MODPATH/system/$P"
      mv -f "$MODPATH/$P" "$MODPATH/system/"
    fi
  done

  ui_print "  Patched $patched system XML file(s)"
  log "System XML patched: $patched file(s)"
}

# search and patch conflicting modules
MOD_XML="$(
  MXML="$(find /data/adb/* -type f -iname '*.xml' -print 2> $NULL)"
  for M in $MXML; do
    if grep -qE "$STR1|$STR2" "$M" 2> $NULL; then
      echo "$M"
    fi
  done
)"

PATCH_MX() {
  local patched=0
  local backup_dir="$MODPATH/.backup/module_xml"

  # check if conflict patching is disabled
  if [ -f "/data/adb/gmsforge/disable_conflict_patch" ]; then
    ui_print "  Conflicting modules patch is disabled"
    log "Module XML patching skipped (disabled by user)"
    return 0
  fi

  ui_print "- Searching conflicting XML"
  for MX in $MOD_XML; do
    MOD="$(echo "$MX" | awk -F'/' '{print $5}')"

    # backup module xml before patching
    mkdir -p "$backup_dir"
    local backup_name
    backup_name="$(echo "$MX" | tr '/' '@')"
    cp -af "$MX" "$backup_dir/$backup_name" 2> $NULL
    log "Backup (module): $MX"

    ui_print "  $MOD: $MX"
    sed -i "/$STR1/d;/$STR2/d" "$MX"

    if [ $? -eq 0 ]; then
      log "Patched (module): $MX"
      patched=$((patched + 1))
    else
      log "FAILED (module): $MX"
    fi
  done

  if [ "$patched" -gt 0 ]; then
    ui_print "  Patched $patched conflicting module XML file(s)"
  else
    ui_print "  No conflicting modules found"
  fi
  log "Module XML patched: $patched file(s)"
}

PATCH_SX && PATCH_MX

# install addon cli tool
ADDON() {
  ui_print "- Installing diagnostic tool (gmsc)"
  mkdir -p "$MODPATH/system/bin"
  mv -f "$MODPATH/gmsc" "$MODPATH/system/bin/gmsc"
  log "Installed: gmsc -> system/bin/gmsc"
}

# clear gms optimization data
CLEAR_GMS() {
  ui_print "- Clearing GMS optimization data"
  local gms_dir="/data/data/com.google.android.gms"
  local cleared=0

  if [ -d "$gms_dir" ]; then
    # clear cache and app_dex
    for subdir in cache app_dex; do
      if [ -d "$gms_dir/$subdir" ]; then
        rm -rf "${gms_dir:?}/$subdir"
        cleared=$((cleared + 1))
        log "Cleared: $gms_dir/$subdir"
      fi
    done
  fi

  # clear idle and doze shared_prefs
  if [ -d "$gms_dir/shared_prefs" ]; then
    find "$gms_dir/shared_prefs" -type f -name '*idle*' -delete 2> $NULL
    find "$gms_dir/shared_prefs" -type f -name '*doze*' -delete 2> $NULL
    log "Cleared: GMS idle/doze shared_prefs"
    cleared=$((cleared + 1))
  fi

  if [ "$cleared" -gt 0 ]; then
    ui_print "  Cleared $cleared GMS data target(s)"
  else
    ui_print "  No GMS data to clear"
  fi
  log "GMS data cleared: $cleared target(s)"
}

# finalize installer
FINALIZE() {
  ui_print "- Finalizing installation"
  mkdir -p "/data/adb/gmsforge"

  # clean up unused files
  ui_print "  Cleaning obsolete files"
  find "$MODPATH"/* -maxdepth 0 \
    ! -name 'module.prop' \
    ! -name 'post-fs-data.sh' \
    ! -name 'service.sh' \
    ! -name 'uninstall.sh' \
    ! -name 'system' \
    ! -name '.backup' \
    ! -name 'install.log' \
    -exec rm -rf {} \;

  # set file permissions
  ui_print "  Setting permissions"
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  set_perm "$MODPATH/system/bin/gmsc" 0 2000 0755

  log "Installation complete"
  ui_print "- Installation complete!"
}

# run installation steps
ADDON && CLEAR_GMS && FINALIZE
