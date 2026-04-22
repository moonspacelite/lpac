# lpac v2.3.0 untuk OpenWrt 24.10 — Linksys EA6350v3

Build cross-compile lpac v2.3.0 (estkme-group) untuk target:
- **Device:** Linksys EA6350v3
- **Arch:** `arm_cortex-a7_neon-vfpv4` (ipq40xx/generic)
- **OpenWrt:** 24.10.x
- **Backend aktif:** AT (ttyACM) + MBIM

---

## Struktur repo

```
.
├── .github/workflows/build.yml   ← GitHub Actions workflow
└── package/lpac/
    ├── Makefile                  ← OpenWrt package Makefile
    ├── Config.in                 ← Konfigurasi backend
    └── files/
        ├── lpac.sh               ← Wrapper script
        └── lpac.uci              ← UCI config default
```

---

## Cara pakai

### 1. Buat repo di GitHub

```bash
gh repo create lpac-openwrt-ea6350 --private --source=. --push
# atau push manual ke repo baru
```

### 2. Jalankan workflow

Pergi ke **Actions → Build lpac → Run workflow**, atau push ke `main`.

Build butuh ±10–15 menit (download SDK ~300MB + compile).

### 3. Download artifact

Setelah build selesai, download artifact `lpac-2.3.0-ipq40xx-ipk` dari tab Actions.
Isinya: `lpac_2.3.0-1_arm_cortex-a7_neon-vfpv4.ipk`

### 4. Install ke router

```bash
# Upload ke router via scp (dari Termux / PC)
scp lpac_2.3.0-1_arm_cortex-a7_neon-vfpv4.ipk root@192.168.1.1:/tmp/

# SSH ke router
ssh root@192.168.1.1

# Install (hapus versi lama dulu jika ada)
opkg remove lpac
opkg install /tmp/lpac_2.3.0-1_arm_cortex-a7_neon-vfpv4.ipk

# Jika butuh libmbim (untuk MBIM backend):
opkg install libmbim
```

---

## Konfigurasi APDU backend

Edit `/etc/config/lpac`:

```uci
config lpac 'main'
    option apdu_driver 'at'    # Ganti ke 'mbim' jika pakai MBIM
    option http_driver 'curl'
    option device '/dev/ttyACM1'
```

Atau via environment variable (tanpa config):

```bash
# Mode AT
LPAC_APDU=at AT_DEVICE=/dev/ttyACM1 lpac chip info

# Mode MBIM
LPAC_APDU=mbim MBIM_DEVICE=/dev/cdc-wdm0 lpac chip info
```

### Cari device yang benar (Fibocom L850-GL)

```bash
# Lihat semua ttyACM
ls /dev/ttyACM*

# L850-GL biasanya punya 3 port: ACM0, ACM1, ACM2
# Port AT biasanya ACM1 atau ACM2
# Test:
AT_DEVICE=/dev/ttyACM1 lpac chip info
AT_DEVICE=/dev/ttyACM2 lpac chip info
```

---

## ⚠️ Known Issue: libcurl + mbedTLS

OpenWrt 24.10 menyertakan `libcurl` yang di-compile dengan **mbedTLS**,
bukan OpenSSL. mbedTLS di OpenWrt **tidak support**:
- Sertifikat GSMA Root CA (signed dengan `ecdsa-with-SHA256`)
- TLSv1.3 dengan `TLS_AES_256_GCM_SHA384`

**Gejala:**
```
Error reading ca cert file gsmaroot.crt - mbedTLS: (-0x2080)
SSL - Client received an extended server hello containing an unsupported extension
```

**Solusi (pilih salah satu):**

**A. Install libcurl-openssl dari feed (jika tersedia):**
```bash
opkg install libcurl-openssl
```

**B. Rebuild libcurl dengan OpenSSL menggunakan SDK:**
Tambahkan ke workflow `.config`:
```
CONFIG_PACKAGE_curl=y
CONFIG_CURL_SSL=y
# pastikan OpenSSL dipilih, bukan mbedTLS
```

**C. Gunakan MBIM backend** (tidak butuh TLS dari lpac sisi modem,
karena APDU dikirim via MBIM protocol, HTTP tetap via curl).

> Catatan: Masalah ini hanya muncul saat **download profile eSIM**.
> Operasi lain (list, enable, disable profile) tidak terpengaruh.

---

## Test setelah install

```bash
# Cek versi
lpac --version   # atau
/usr/lib/lpac --version

# Cek info chip eSIM (AT mode)
lpac chip info

# List profile
lpac profile list

# List driver yang tersedia
lpac driver apdu list
lpac driver http list
```

---

## Hash PKG_SOURCE

Jika build gagal karena `PKG_HASH:=skip`, update dengan:
```bash
wget https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v2.3.0 -O lpac-2.3.0.tar.gz
sha256sum lpac-2.3.0.tar.gz
```
Lalu ganti `PKG_HASH:=skip` di `package/lpac/Makefile` dengan nilai sha256 tersebut.
