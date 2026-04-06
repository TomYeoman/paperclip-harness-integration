# jet-datadog

Interact with Datadog's observability platform using the [pup CLI](https://github.com/datadog-labs/pup).

## Installation

### macOS/Linux (Homebrew)

```bash
brew tap datadog-labs/pack
brew install datadog-labs/pack/pup
```

> **Windows**: `pup` is not supported on Windows. Use WSL2 with a Linux distribution to run pup.

### Build from Source (macOS/Linux)

Requires [Rust toolchain](https://rustup.rs/) installed.

```bash
git clone https://github.com/datadog-labs/pup.git && cd pup
cargo build --release
cp target/release/pup /usr/local/bin/pup
```

### Verify

```bash
pup --version
```

### Authenticate

```bash
DD_SITE="datadoghq.eu" pup auth login
```
