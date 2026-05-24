## Change Log:
- 1.1 (Renamed to GmsForge)
  - Renamed module from GMS Doze to GmsForge
  - Fixed subshell pipe bug in post-fs-data.sh for accurate conflict patching counts
  - Updated uninstall.sh and customize.sh to reflect new module name GmsForge
  - Updated gmsc diagnostic tool path, branding, and version to 1.1

- 1.0.0 (First Release)
  - GMS Doze optimizations
  - Added explicit Magisk, KernelSU, and APatch root detection
  - XML backup system before patching (stored in module directory)
  - Targeted GMS data cleanup (prevents raw wildcard directory wipe)
  - Comprehensive logging system across all scripts
  - Responsive boot wait (5-second intervals with 5-minute timeout)
  - Standalone `gmsc` diagnostic tool with XML patch validation and help option
  - Clean uninstall with XML backup restoration
