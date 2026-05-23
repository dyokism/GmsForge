[English](README.md) | [Bahasa Indonesia](README.id.md)

# GMS Doze

**Paksa Google Play services untuk mengikuti optimasi baterai.**

![License](https://img.shields.io/badge/Lisensi-GPLv2-blue.svg)
![Android](https://img.shields.io/badge/Android-6.0%2B-green.svg)
![Version](https://img.shields.io/badge/Versi-1.0.0-orange.svg)
![Root](https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-red.svg)

## Ringkasan

GMS Doze adalah modul Magisk/KernelSU/APatch yang mengoptimalkan Google Play services (`com.google.android.gms`) untuk mencegah pengurasan baterai saat perangkat tidak digunakan (idle).

### Cara Kerja

- **Patching XML**: Menghapus GMS dari daftar putih hemat daya sistem saat instalasi.
- **Penegakan Runtime**: Menghapus GMS dari daftar putih aktif via `dumpsys` di setiap boot.
- **Nonaktifkan Device Admin**: Menonaktifkan receiver administrator perangkat GMS di setiap boot.

---

## Persyaratan

| Persyaratan | Detail |
|-------------|--------|
| Android | 6.0+ (API 23+) |
| Root | Magisk v20.4+, KernelSU, atau APatch |

---

## Instalasi

1. Unduh file ZIP rilis terbaru dari repositori.
2. Buka aplikasi Magisk, KernelSU, atau APatch manager.
3. Instal file ZIP melalui tab **Modules**.
4. **Reboot** perangkat Anda.

---

## Penggunaan

Periksa status optimasi kapan saja menggunakan alat diagnostik bawaan (membutuhkan akses root):

```sh
su
gmsc
```

Untuk bantuan dan perintah tambahan:
```sh
gmsc --help
```

---

## Pemecahan Masalah

### Notifikasi Pesan Terlambat
Jika notifikasi pesan chat terlambat masuk, kecualikan aplikasi pesan Anda dari optimasi baterai di **Pengaturan → Baterai → Optimasi Baterai** pada perangkat Anda.

### Find My Device
Modul ini menonaktifkan receiver device admin GMS yang dapat memengaruhi fitur Find My Device. Untuk mengaktifkannya kembali secara manual:
```sh
su
pm enable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
```
*(Catatan: Ini akan disetel ulang saat boot berikutnya oleh layanan boot modul).*

---

## Pengembang & Lisensi

- **Pengembang**: [dyokism](https://github.com/dyokism)
- **Lisensi**: GPL v2.0
