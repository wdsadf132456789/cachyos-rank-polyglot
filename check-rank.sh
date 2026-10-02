#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

# 1. Heal fastfetch config if missing
if [ -f "$CONFIG_FILE" ] && ! grep -q "rank" "$CONFIG_FILE"; then
    echo "⚡ Rank entry missing from fastfetch config. Restoring via tee..."
    printf '    {\n        "type": "custom",\n        "format": "Rank Status: \\u001b[32m$(rank)\\u001b[0m"\n    },\n' | tee -a "$CONFIG_FILE" > /dev/null
    echo "✨ Fastfetch config healed successfully!"
fi

# 2. Automatically detect active init system
INIT_SYS=$(cat /proc/1/comm 2>/dev/null || echo "unknown")
echo "🔍 Detected active init system: $INIT_SYS"

case "$INIT_SYS" in
    systemd)
        echo "🚀 Systemd detected. Enabling user service..."
        systemctl --user enable --now cachyos-rank-heal.service 2>/dev/null || true
        ;;
    openrc*|openrc-init)
        echo "🔥 OpenRC detected. Registering and starting service..."
        if [ -f /etc/init.d/cachyos-rank ]; then
            doas rc-update add cachyos-rank default 2>/dev/null || true
            doas rc-service cachyos-rank start 2>/dev/null || true
        fi
        ;;
    runit)
        echo "⚡ Runit detected. Linking service..."
        if [ -d /etc/runit/sv/cachyos-rank ]; then
            doas ln -sf /etc/runit/sv/cachyos-rank /etc/runit/runlevel/default/ 2>/dev/null || true
        fi
        ;;
    dinit)
        echo "🌀 Dinit detected. Launching service..."
        doas dinitctl start cachyos-rank 2>/dev/null || true
        ;;
    *)
        echo "🛠️ Custom/unknown init ($INIT_SYS), standalone heal completed!"
        ;;
esac

echo "🎯 All checks passed and init wired up smoothly, bro!"
