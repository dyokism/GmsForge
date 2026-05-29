[English](README.md) | [Bahasa Indonesia](README.id.md)

# GmsForge

**Optimalkan Google Play services untuk mencegah pengurasan baterai terus menerus.**

![Lisensi](https://img.shields.io/badge/Lisensi-MIT-blue.svg)
![Android](https://img.shields.io/badge/Android-6.0%2B-green.svg)
![Versi](https://img.shields.io/badge/Versi-1.3-orange.svg)
![Root](https://img.shields.io/badge/Root-Magisk%20%7C%20KernelSU%20%7C%20APatch-red.svg)

## Deskripsi Umum

GmsForge adalah modul root yang mengoptimalkan Google Play services (`com.google.android.gms`) untuk mencegah pengurasan baterai di latar belakang. Modul ini mencabut hak pengecualian latar belakang pada Google Play services, sehingga menghemat daya baterai tanpa mengganggu notifikasi dan sinkronisasi penting.

---

## Mengapa Memilih GmsForge?

- **Optimasi Baterai**: Menghapus Google Play services dari pengecualian latar belakang untuk menghentikan pengurasan baterai saat perangkat siaga.
- **Keamanan Boot-Level**: Menonaktifkan aktivitas administrator dan siklus sinkronisasi yang tidak diperlukan di latar belakang pada setiap booting.
- **Utilitas Diagnostik**: Menyertakan utilitas baris perintah sederhana untuk memantau status modul dan tingkat optimasi.

---

## Persyaratan Sistem

| Persyaratan | Detail |
|-------------|--------|
| Android | 6.0+ (API 23+) |
| Alat Diagnostik | Utilitas command-line bawaan `gmsc` (membutuhkan akses root) |
| Root | Magisk v20.4+, KernelSU, atau APatch |

---

## Instalasi

1. Pasang berkas ZIP modul melalui tab **Modules** di manajer root Anda (Magisk, KernelSU, atau APatch).
2. **Reboot** (Mulai ulang) perangkat Anda untuk menerapkan pengoptimalan baterai secara global.

---

## Penggunaan

Anda dapat mengaudit status pengoptimalan kapan saja menggunakan alat diagnostik bawaan (memerlukan root shell):
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
Jika notifikasi pesan langsung dari aplikasi percakapan (seperti WhatsApp, Telegram) terlambat masuk, kecualikan aplikasi tersebut dari optimasi baterai di **Pengaturan → Baterai → Optimasi Baterai** pada perangkat Anda.

### Dampak Fitur Find My Device
Modul ini menonaktifkan receiver administrator perangkat GMS, yang dapat memengaruhi fungsi pelacakan jarak jauh latar belakang milik Google Find My Device. Untuk mengaktifkannya kembali secara manual:
```sh
su
pm enable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
```
*(Catatan: Perubahan manual ini akan disetel ulang secara otomatis pada boot berikutnya oleh layanan boot modul untuk melindungi konsumsi daya).*

---

## Cara Kerja

```mermaid
flowchart TD
    FlashZip([Mulai: Flash ZIP Modul]) --> CheckRoot{Cek Tipe Root?}
    CheckRoot -- Tidak Didukung --> AbortRoot[Abort: Recovery Tidak Didukung]
    CheckRoot -- Didukung --> CheckAPI{Cek Level API Android?}
    
    CheckAPI -- API < 23 --> AbortAPI[Abort: Butuh Android 6.0+]
    CheckAPI -- API >= 23 --> SearchXML[Cari Whitelist GMS di XML Sistem]
    
    SearchXML --> PatchSX[Backup & Tambal XML Sistem: Hapus Pengecualian Daya, Data, & Lokasi]
    PatchSX --> SearchMod[Cari XML di Modul Lain yang Konflik]
    SearchMod --> PatchMX[Backup & Tambal XML Modul yang Konflik]
    PatchMX --> InstallAddon[Instal Utilitas Diagnostik gmsc]
    InstallAddon --> ClearCache[Bersihkan Cache Aplikasi GMS & Shared Prefs]
    ClearCache --> SetPerms[Atur Izin File & Selesai]
    
    SetPerms --> BootStart[Perangkat Reboot & Boot Awal Post-FS]
    BootStart --> BootScan[Pindai & Tambal XML Modul Aktif Lainnya]
    BootScan --> WaitBoot[Tunggu sys.boot_completed=1 di service.sh]
    
    WaitBoot --> DisableAdmin[Nonaktifkan Device Admin GMS untuk Semua User]
    DisableAdmin --> ClearWhitelist[Hapus GMS dari Daftar Putih dumpsys deviceidle Aktif]
    ClearWhitelist --> LogComplete[Catat Log Penyelesaian Layanan]
    LogComplete --> Finished([Selesai: Optimalisasi Baterai GMS Berhasil Diterapkan])

    %% Kustomisasi Tampilan dan Warna (Tema Gelap Ultra-Redup)
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

## Pengembang & Lisensi

- **Pengembang**: [dyokism](https://github.com/dyokism)
- **Lisensi**: MIT
