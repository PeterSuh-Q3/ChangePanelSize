#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")"&&pwd)"; OUT="${1:-$ROOT/dist}"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$OUT" "$ROOT/src/bin/helper"; j(){ jq -r "$1 // empty" "$ROOT/package.json"; }
gcc -O2 ${CC_STATIC:-} -Wall -Wextra -o "$ROOT/src/bin/helper/changepanelsize-helper.x86_64" "$ROOT/synology/helper/changepanelsize-helper.c"
mkdir -p "$T/target"; cp -R "$ROOT/src/." "$T/target/"; chmod 0755 "$T/target/ui/api.cgi" "$T/target/bin/"*.sh
mkdir -p "$T/spk"; cp -R "$ROOT/synology/scripts" "$T/spk/scripts"; cp -R "$ROOT/synology/conf" "$T/spk/conf"; cp "$ROOT/synology/"PACKAGE_ICON* "$T/spk/" 2>/dev/null||true
tar --owner=root --group=root -czf "$T/spk/package.tgz" -C "$T/target" .; md5=$(md5sum "$T/spk/package.tgz"|awk '{print $1}')
{ echo "package=\"$(j .package)\"";echo "version=\"$(j .version)\"";echo "arch=\"$(j .synology.arch)\"";echo "dsmuidir=\"$(j .dsmuidir)\"";echo "dsmappname=\"$(j .dsmappname)\"";echo "ctl_stop=\"$(j .ctl_stop)\"";echo "checksum=\"$md5\""; } > "$T/spk/INFO"
tar --owner=root --group=root -cf "$OUT/$(j .name)-$(j .synology.arch)-$(j .version).spk" -C "$T/spk" .
