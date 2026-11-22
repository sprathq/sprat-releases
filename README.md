# Sprat releases

Binaries for [Sprat](https://sprat.dev), the product manager for every Claude Code agent on
your machine. This repository holds release builds only; the source is not published.

## Install

No Elixir or Erlang needed: every build bundles its own runtime.

```sh
curl -fsSL https://sprat.dev/install.sh | sh
```

or with Homebrew:

```sh
brew install sprathq/tap/sprat
```

Or download a tarball from [Releases](https://github.com/sprathq/sprat-releases/releases),
check it against its `.sha256`, unpack it anywhere and run `bin/sprat`.

| Target | File |
|---|---|
| macOS, Apple silicon | `sprat-<version>-macos-arm64.tar.gz` |
| macOS, Intel | `sprat-<version>-macos-x86_64.tar.gz` |
| Linux x86_64 (glibc 2.35+, OpenSSL 3) | `sprat-<version>-linux-x86_64.tar.gz` |
| Linux arm64 (glibc 2.35+, OpenSSL 3) | `sprat-<version>-linux-arm64.tar.gz` |

Sprat supervises [Claude Code](https://claude.com/claude-code) sessions, so you need Claude
Code installed and signed in.

## Uninstall

```sh
launchctl unload -w ~/Library/LaunchAgents/dev.sprat.serve.plist 2>/dev/null; rm -f ~/Library/LaunchAgents/dev.sprat.serve.plist
rm -rf ~/.local/lib/sprat ~/.local/bin/sprat        # installer (your data stays)
brew uninstall sprat                                  # Homebrew
```

Licence: free to use, closed source. See [LICENSE](LICENSE).
