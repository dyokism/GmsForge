#!/system/bin/sh
# early boot: patch conflicting modules

MODDIR=${0%/*}
LOG_FILE="$MODDIR/postfs.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [post-fs] $1" >> "$LOG_FILE"
}

log "=== post-fs-data execution ==="

GMS0="\"com.google.android.gms\""
STR1="allow-unthrottled-location package=$GMS0"
STR2="allow-ignore-location-settings package=$GMS0"
STR3="allow-in-power-save package=$GMS0"
STR4="allow-in-data-usage-save package=$GMS0"
NULL="/dev/null"

# get own module id to exclude from scan
OWN_ID=""
if [ -f "$MODDIR/module.prop" ]; then
  OWN_ID="$(grep '^id=' "$MODDIR/module.prop" | cut -d'=' -f2)"
fi

PATCHED=0
find /data/adb/modules -type f -iname "*.xml" -print 2> $NULL |
while IFS= read -r XML; do
  # skip our own module files
  case "$XML" in
    *"/$OWN_ID/"*) continue ;;
  esac

  if grep -qE "$STR1|$STR2|$STR3|$STR4" "$XML" 2> $NULL; then
    sed -i "/$STR1/d;/$STR2/d;/$STR3/d;/$STR4/d" "$XML"
    log "Patched conflict: $XML"
    PATCHED=$((PATCHED + 1))
  fi
done

log "Conflict scan complete (patched: $PATCHED)"
