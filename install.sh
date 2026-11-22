#!/bin/sh
# Sprat installer — https://sprat.dev
#
#   curl -fsSL https://sprat.dev/install.sh | sh
#
# Installs a self-contained build (Erlang runtime included; no Elixir or
# Erlang needed) into ~/.local/lib/sprat and links ~/.local/bin/sprat.
# (Not ~/.local/share/sprat: on Linux that is where Sprat keeps its data.)
# Nothing needs root. Re-run it to upgrade.
#
#   SPRAT_VERSION=0.4.0   install a specific version instead of the latest
#   SPRAT_HOME=...        install dir (default ~/.local/lib/sprat)
#   SPRAT_BIN_DIR=...     where the `sprat` link goes (default ~/.local/bin)
set -eu

REPO="sprathq/sprat-releases"
SPRAT_HOME="${SPRAT_HOME:-$HOME/.local/lib/sprat}"
SPRAT_BIN_DIR="${SPRAT_BIN_DIR:-$HOME/.local/bin}"

say() { printf '%s\n' "$*"; }
fail() { printf 'sprat install: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "needs \`$1\`"; }

need curl
need tar
need uname

os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Darwin) os=macos ;;
  Linux) os=linux ;;
  *) fail "unsupported OS: $os (macOS and Linux are supported)" ;;
esac
case "$arch" in
  arm64 | aarch64) arch=arm64 ;;
  x86_64 | amd64) arch=x86_64 ;;
  *) fail "unsupported CPU: $arch (arm64 and x86_64 are supported)" ;;
esac
target="$os-$arch"

if [ -n "${SPRAT_VERSION:-}" ]; then
  version="${SPRAT_VERSION#v}"
else
  # The latest release's tag, from GitHub's redirect (no API token, no rate limit).
  location="$(curl -fsSI "https://github.com/$REPO/releases/latest" | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}')"
  version="${location##*/v}"
  [ -n "$version" ] && [ "$version" != "$location" ] || fail "could not find the latest release"
fi

name="sprat-$version-$target"
url="https://github.com/$REPO/releases/download/v$version/$name.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

say "Installing Sprat $version ($target)…"
curl -fL --progress-bar "$url" -o "$tmp/$name.tar.gz" || fail "download failed: $url"
curl -fsSL "$url.sha256" -o "$tmp/$name.tar.gz.sha256" || fail "checksum download failed"

expected="$(awk '{print $1}' "$tmp/$name.tar.gz.sha256")"
if command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 "$tmp/$name.tar.gz" | awk '{print $1}')"
else
  actual="$(sha256sum "$tmp/$name.tar.gz" | awk '{print $1}')"
fi
[ "$expected" = "$actual" ] || fail "checksum mismatch for $name.tar.gz"

mkdir -p "$SPRAT_HOME/versions" "$SPRAT_BIN_DIR"
rm -rf "$SPRAT_HOME/versions/$version"
tar -xzf "$tmp/$name.tar.gz" -C "$tmp"
mv "$tmp/$name" "$SPRAT_HOME/versions/$version"
ln -sfn "$SPRAT_HOME/versions/$version" "$SPRAT_HOME/current"
ln -sf "$SPRAT_HOME/current/bin/sprat" "$SPRAT_BIN_DIR/sprat"

say ""
say "Sprat $version is installed: $SPRAT_BIN_DIR/sprat"

case ":$PATH:" in
  *":$SPRAT_BIN_DIR:"*) ;;
  *)
    say ""
    say "Add it to your PATH (then open a new terminal):"
    case "$(basename "${SHELL:-sh}")" in
      fish) say "  fish_add_path $SPRAT_BIN_DIR" ;;
      bash) say "  echo 'export PATH=\"$SPRAT_BIN_DIR:\$PATH\"' >> ~/.bashrc" ;;
      *) say "  echo 'export PATH=\"$SPRAT_BIN_DIR:\$PATH\"' >> ~/.zshrc" ;;
    esac
    ;;
esac

if ! command -v claude >/dev/null 2>&1; then
  say ""
  say "Sprat supervises Claude Code sessions. Install Claude Code first: https://claude.com/claude-code"
fi

say ""
say "Next:"
say "  sprat                   open the board"
say "  sprat serve             run Sprat in the background (sprat install-agent starts it at login on macOS)"
say "  sprat status            one line per project"
