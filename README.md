[English](README.md) | [Bahasa Indonesia](README.id.md)

# GmsForge

**Force Google Play services to respect battery optimization.**

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Android](https://img.shields.io/badge/Android-6.0%2B-green.svg)
![Version](https://img.shields.io/badge/Version-1.1-orange.svg)
![Root](https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-red.svg)

## Overview

GmsForge is a Magisk/KernelSU/APatch module that optimizes Google Play services (`com.google.android.gms`) to prevent idle battery drain.

### How It Works

- **XML Patching**: Removes GMS from power-save system whitelists during installation.
- **Runtime Enforce**: Removes GMS from the active whitelist via `dumpsys` on every boot.
- **Device Admin Disable**: Disables GMS device administrator receivers on every boot.

---

## Requirements

| Requirement | Details |
|-------------|---------|
| Android | 6.0+ (API 23+) |
| Root | Magisk v20.4+, KernelSU, or APatch |

---

## Installation

1. Download the latest release ZIP from the repository.
2. Open Magisk, KernelSU, or APatch manager.
3. Install the ZIP via the **Modules** tab.
4. **Reboot** your device.

---

## Usage

Check optimization status anytime using the built-in diagnostic tool (requires root):

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

### Delayed Messaging Notifications
If chat notifications are delayed, exclude your messaging apps from battery optimization in your device's **Settings → Battery → Battery Optimization**.

### Find My Device
The module disables GMS device admin receivers, which can affect Find My Device. To re-enable them manually:
```sh
su
pm enable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
```
*(Note: This is reset upon reboot by the module's late boot service).*

---

## Developer & License

- **Developer**: [dyokism](https://github.com/dyokism)
- **License**: MIT
