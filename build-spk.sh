#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")"&&pwd)"; OUT="${1:-$ROOT/dist}"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$OUT" "$ROOT/src/bin/helper"; j(){ jq -r "$1 // empty" "$ROOT/package.json"; }
md5_of(){ if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | awk '{print $1}'; else md5 -q "$1"; fi; }
b64_of(){ if base64 --help 2>&1 | grep -q -- '-w,'; then base64 -w 0 < "$1"; else base64 < "$1" | tr -d '\n'; fi; }
if tar --version 2>/dev/null | grep -qi 'gnu tar'; then TAR_OWNER=(--owner=root --group=root); else TAR_OWNER=(--uid 0 --gid 0 --uname root --gname root); fi
if [ "$(uname -s)" = "Linux" ]; then
  gcc -O2 -static -Wall -Wextra -o "$ROOT/src/bin/helper/changepanelsize-helper.x86_64" "$ROOT/synology/helper/changepanelsize-helper.c"
else
  gcc -O2 -Wall -Wextra -o "$ROOT/src/bin/helper/changepanelsize-helper.x86_64" "$ROOT/synology/helper/changepanelsize-helper.c"
fi
mkdir -p "$T/target"; cp -R "$ROOT/src/." "$T/target/"; chmod 0755 "$T/target/ui/api.cgi" "$T/target/bin/"*.sh
mkdir -p "$T/spk"; cp -R "$ROOT/synology/scripts" "$T/spk/scripts"; cp -R "$ROOT/synology/conf" "$T/spk/conf"; cp "$ROOT/synology/"PACKAGE_ICON* "$T/spk/" 2>/dev/null||true; cp "$ROOT/LICENSE" "$T/spk/LICENSE"
tar "${TAR_OWNER[@]}" -czf "$T/spk/package.tgz" -C "$T/target" .; md5=$(md5_of "$T/spk/package.tgz")
{ echo "package=\"$(j .name)\""; echo "version=\"$(j .version)\""; echo "description=\"$(j .description)\""; echo "maintainer=\"$(j .synology.maintainer)\""; echo "maintainer_url=\"$(j .synology.maintainer_url)\""; echo "distributor=\"$(j .synology.distributor)\""; echo "distributor_url=\"$(j .synology.distributor_url)\""; echo "support_url=\"$(j .synology.support_url)\""; echo "helpurl=\"$(j .synology.help_url)\""; echo "os_min_ver=\"$(j .synology.os_min_ver)\""; echo "os_max_ver=\"$(j .synology.os_max_ver)\""; echo "arch=\"$(j .synology.arch)\""; echo "displayname=\"$(j .synology.displayname)\""; echo "thirdparty=\"$(j .synology.thirdparty)\""; echo "beta=\"$( [ "$(j .synology.beta)" = yes ] && echo true || echo false )\""; echo "dsmuidir=\"$(j .dsmuidir)\""; echo "dsmappname=\"$(j .dsmappname)\""; echo "install_dep_packages=\"$(j .install_dep_packages)\""; echo "ctl_stop=\"$(j .ctl_stop)\""; echo "ctl_uninstall=\"$(j .ctl_uninstall)\""; echo "support_conf_folder=\"$(j .support_conf_folder)\""; echo "extractsize=\"$(du -sk "$T/target" | awk '{print $1}')\""; echo "create_time=\"$(date +%Y%m%d-%H:%M:%S)\""; echo "checksum=\"$md5\""; for icon in 'PACKAGE_ICON.PNG:package_icon' 'PACKAGE_ICON_256.PNG:package_icon_256'; do file="$ROOT/synology/${icon%%:*}"; [ -f "$file" ] && echo "${icon##*:}=\"$(b64_of "$file")\""; done; } > "$T/spk/INFO"
tar "${TAR_OWNER[@]}" -cf "$OUT/$(j .name)-$(j .synology.arch)-$(j .version).spk" -C "$T/spk" INFO LICENSE PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG conf scripts package.tgz
