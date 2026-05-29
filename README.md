[English](README.md) | [Bahasa Indonesia](README.id.md)

# GmsForge

**Optimize Google Play services to prevent idle battery drain.**

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Android](https://img.shields.io/badge/Android-6.0%2B-green.svg)
![Version](https://img.shields.io/badge/Version-1.3-orange.svg)
![Root](https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-red.svg)

## Overview

GmsForge is a root module that optimizes Google Play services (`com.google.android.gms`) to prevent background battery drain. It removes background exemptions for Google Play services, saving battery life while keeping notifications and essential sync features working.

---

## Why Use GmsForge?

- **Idle Battery Optimization**: Removes Google Play services from background exemptions to stop idle battery drain.
- **Boot-Level Security**: Disables unnecessary background administrator activities and sync loops on every startup.
- **Built-In Diagnostics**: Includes a simple command-line utility to monitor module status and optimization states.

---

## Requirements

| Requirement | Details |
|-------------|---------|
| Android | 6.0+ (API 23+) |
| Diagnostic | Built-in `gmsc` command-line utility (requires root) |
| Root | Magisk v20.4+, KernelSU, or APatch |

---

## Installation

1. Install the module ZIP via your root manager's **Modules** tab (Magisk, KernelSU, or APatch).
2. **Reboot** your device to apply the battery optimizations globally.

---

## Usage

You can audit the optimization status anytime using the built-in diagnostic tool (requires root shell):
```sh
su
gmsc
```
For help and additional commands:
```sh
gmsc --help
```

---

## Troubleshooting

### Delayed Push Notifications
If real-time chat notifications from messaging apps (e.g., WhatsApp, Telegram) are delayed, exclude those specific apps from battery optimization in your device's **Settings → Battery → Battery Optimization**.

### Find My Device Impact
This module disables GMS device administrator receivers, which can affect the background remote locate functionality of Google's Find My Device. To manually re-enable it:
```sh
su
pm enable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
```
*(Note: This manual change will be reset upon the next reboot by the module's late boot service to protect battery life).*

---

## How It Works

```mermaid
flowchart TD
    FlashZip([Start: Flash Module ZIP]) --> CheckRoot{Check Root App?}
    CheckRoot -- Unsupported --> AbortRoot[Abort: Recovery Not Supported]
    CheckRoot -- Supported --> CheckAPI{Check Android API Level?}
    
    CheckAPI -- API < 23 --> AbortAPI[Abort: Requires Android 6.0+]
    CheckAPI -- API >= 23 --> SearchXML[Search GMS Whitelists in System XMLs]
    
    SearchXML --> PatchSX[Backup & Patch System XMLs: Remove Power, Data, & Location Exemptions]
    PatchSX --> SearchMod[Search Conflicting Modules XMLs]
    SearchMod --> PatchMX[Backup & Patch Conflicting XMLs]
    PatchMX --> InstallAddon[Install gmsc Diagnostic Utility]
    InstallAddon --> ClearCache[Clear GMS App Cache & Shared Prefs]
    ClearCache --> SetPerms[Set Standard Permissions & Complete]
    
    SetPerms --> BootStart[Device Reboots & Early Boot Post-FS]
    BootStart --> BootScan[Scan & Patch Other Active Modules XMLs]
    BootScan --> WaitBoot[Wait for sys.boot_completed=1 in service.sh]
    
    WaitBoot --> DisableAdmin[Disable GMS Device Admin Receivers for All Users]
    DisableAdmin --> ClearWhitelist[Remove GMS from active dumpsys deviceidle whitelist]
    ClearWhitelist --> LogComplete[Log Service Completion]
    LogComplete --> Finished([Finished: GMS Optimizations Applied Successfully])

    %% Custom Styles and Colors (Ultra-Muted Slate Theme)
    classDef startEnd fill:#1b2c24,stroke:#34d399,stroke-width:1.5px,color:#e6f4ea;
    classDef fail fill:#2c1b1b,stroke:#f87171,stroke-width:1.5px,color:#fce8e6;
    classDef decision fill:#2d2216,stroke:#fbbf24,stroke-width:1.5px,color:#fef3c7;
    classDef process fill:#1e293b,stroke:#475569,stroke-width:1px,color:#f1f5f9;
    
    class FlashZip,Finished startEnd;
    class AbortRoot,AbortAPI fail;
    class CheckRoot,CheckAPI decision;
    class SearchXML,PatchSX,SearchMod,PatchMX,InstallAddon,ClearCache,SetPerms,BootStart,BootScan,WaitBoot,DisableAdmin,ClearWhitelist,LogComplete process;
```

---

## Developer & License

- **Developer**: [dyokism](https://github.com/dyokism)
- **License**: MIT
