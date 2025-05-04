#!/bin/bash

# === CONFIG ===
WATCH_DIR="/var/www/html/"
TRIGGER_SCRIPT="/var/www/autobuild.sh"

echo "Watching directory: $WATCH_DIR"
echo "Changes will trigger: $TRIGGER_SCRIPT"

# === Start watching ===
inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" --format '%w%f' | while read file; do
    echo "Detected change: $file"
    echo "Running trigger script..."
    bash "$TRIGGER_SCRIPT"
done
