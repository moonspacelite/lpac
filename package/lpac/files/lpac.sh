#!/bin/sh
# lpac wrapper script
# Membaca konfigurasi dari /etc/config/lpac dan set environment variables
# sebelum memanggil binary lpac di /usr/lib/lpac

LPAC_BIN="/usr/lib/lpac"
CONFIG_FILE="/etc/config/lpac"

# Baca UCI config jika ada
if [ -f "$CONFIG_FILE" ]; then
    APDU_DRIVER=$(uci -q get lpac.main.apdu_driver 2>/dev/null)
    HTTP_DRIVER=$(uci -q get lpac.main.http_driver 2>/dev/null)
    DEVICE=$(uci -q get lpac.main.device 2>/dev/null)
fi

# Set default driver
[ -z "$APDU_DRIVER" ] && APDU_DRIVER="at"
[ -z "$HTTP_DRIVER" ] && HTTP_DRIVER="curl"

# Set environment untuk driver
export LPAC_APDU="$APDU_DRIVER"
export LPAC_HTTP="$HTTP_DRIVER"

# Set device jika ada
if [ -n "$DEVICE" ]; then
    case "$APDU_DRIVER" in
        at)   export AT_DEVICE="$DEVICE" ;;
        mbim) export MBIM_DEVICE="$DEVICE" ;;
    esac
fi

# Jalankan lpac dengan argumen yang diberikan
exec "$LPAC_BIN" "$@"
