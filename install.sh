#!/usr/bin/env bash
set -euo pipefail

# Assembles both theme packages and copies them into Mailspring's packages dir.
# Usage: ./install.sh [packages-dir]

src="$(cd "$(dirname "$0")" && pwd)"
dest="${1:-}"

if [[ -z "$dest" ]]; then
  for d in \
    "$HOME/snap/mailspring/common/packages" \
    "$HOME/.var/app/com.getmailspring.Mailspring/config/Mailspring/packages" \
    "$HOME/Library/Application Support/Mailspring/packages" \
    "$HOME/.config/Mailspring/packages"; do
    if [[ -d "$(dirname "$d")" ]]; then
      dest="$d"
      break
    fi
  done
fi

if [[ -z "$dest" ]]; then
  echo "Mailspring config dir not found. Pass the packages dir as an argument." >&2
  exit 1
fi

mkdir -p "$dest"
for variant in light dark; do
  out="$dest/nagi-$variant"
  rm -rf "$out"
  # Copy, don't symlink: the snap can't read files under hidden home dirs.
  cp -R "$src/$variant" "$out"
  cp "$src"/shared/*.less "$out/styles/"
done

echo "Installed nagi-light and nagi-dark to $dest"
