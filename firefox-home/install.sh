#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/chrome" && pwd -P)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ -f "$config_home/mozilla/firefox/profiles.ini" ]]; then
  firefox_dir="$config_home/mozilla/firefox"
elif [[ -f "$HOME/.mozilla/firefox/profiles.ini" ]]; then
  firefox_dir="$HOME/.mozilla/firefox"
else
  printf 'Firefox profiles.ini was not found\n' >&2
  exit 1
fi

selection="$(awk '
  /^\[Profile[0-9]+\]\r?$/ { in_profile = 1; path = ""; relative = "1"; is_default = "0"; next }
  /^\[/ {
    if (in_profile && is_default == "1") { count++; result = relative "\t" path }
    in_profile = 0
  }
  in_profile && /^Path=/ { path = substr($0, 6); sub(/\r$/, "", path) }
  in_profile && /^IsRelative=/ { relative = substr($0, 12); sub(/\r$/, "", relative) }
  in_profile && /^Default=/ { is_default = substr($0, 9); sub(/\r$/, "", is_default) }
  END {
    if (in_profile && is_default == "1") { count++; result = relative "\t" path }
    if (count != 1 || result ~ /\t$/) exit 1
    print result
  }
' "$firefox_dir/profiles.ini")" || {
  printf 'Expected one default Firefox profile in profiles.ini\n' >&2
  exit 1
}

IFS=$'\t' read -r relative profile_path <<< "$selection"
if [[ "$relative" == 1 ]]; then
  profile_dir="$firefox_dir/$profile_path"
else
  profile_dir="$profile_path"
fi
if [[ ! -d "$profile_dir" ]]; then
  printf 'Firefox profile does not exist: %s\n' "$profile_dir" >&2
  exit 1
fi

target="$profile_dir/chrome"
if [[ -L "$target" && "$(readlink -f -- "$target")" == "$source_dir" ]]; then
  printf 'Already linked: %s\n' "$target"
  exit 0
fi

if [[ -e "$target" || -L "$target" ]]; then
  stamp="$(date +%Y%m%d-%H%M%S)"
  backup="$profile_dir/chrome.backup-$stamp"
  if [[ -e "$backup" || -L "$backup" ]]; then
    printf 'Backup path already exists: %s\n' "$backup" >&2
    exit 1
  fi
  mv -- "$target" "$backup"
  printf 'Backed up existing chrome: %s\n' "$backup"
fi

ln -s -- "$source_dir" "$target"
printf 'Linked %s -> %s\n' "$target" "$source_dir"
