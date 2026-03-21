# goodverify

CLI client for [goodverify.dev](https://goodverify.dev) — verify emails, phones, and addresses from the command line.

Built in Zig with zero external dependencies. Single static binary (~1MB).

## Install

**macOS / Linux:**

```sh
curl -fsSL https://github.com/goodwaygroup/goodverify/releases/download/latest/install.sh | sh
```

**Windows (PowerShell):**

```powershell
irm https://github.com/goodwaygroup/goodverify/releases/download/latest/install.ps1 | iex
```

**From source:**

```sh
zig build -Doptimize=ReleaseSafe
cp zig-out/bin/goodverify /usr/local/bin/
```

## Quick Start

```sh
# Configure your API key
goodverify configure --env production --url https://goodverify.dev --key sk_your_api_key

# Verify an email
goodverify verify email --email user@example.com

# Verify a phone number
goodverify verify phone --phone "+15551234567"

# Verify an address
goodverify verify address --address "123 Main St, Springfield, IL 62701"
```

## Configuration

Config is stored at `~/.goodverify.json` (Windows: `%USERPROFILE%\.goodverify.json`).

```sh
# Set up an environment
goodverify configure --env production --url https://goodverify.dev --key sk_live_abc123

# Add a dev environment
goodverify configure --env dev --url http://localhost:4000 --key sk_test_xyz

# Show all environments (keys are masked)
goodverify configure --show
```

The first configured environment becomes the default. Use `--env <name>` on any command to switch environments.

## Commands

### verify

Verify an email, phone number, or mailing address.

```sh
# Email verification
goodverify verify email --email user@example.com

# Phone verification
goodverify verify phone --phone "+15551234567"
goodverify verify phone --phone "5551234567" --country US

# Address verification (single string)
goodverify verify address --address "123 Main St, Springfield, IL 62701"

# Address verification (structured fields)
goodverify verify address --street "123 Main St" --city Springfield --state IL --zip 62701

# Raw JSON output
goodverify verify email --email user@example.com --json
```

### batch

Manage batch verification jobs.

```sh
# List all batch jobs
goodverify batch list

# Get batch job details
goodverify batch get --id abc123

# Download batch results
goodverify batch results --id abc123

# Download sample CSV template
goodverify batch sample > template.csv
```

### usage

Show API usage and credit balance.

```sh
goodverify usage
goodverify usage --json
```

### health

Check API health status. Does not require authentication.

```sh
goodverify health
goodverify health --url http://localhost:4000
```

## Global Options

All commands support these options:

| Flag | Description |
|------|-------------|
| `--env <name>` | Use a specific configured environment |
| `--key <key>` | Override API key for this request |
| `--url <url>` | Override base URL for this request |
| `--json` | Output raw JSON response |
| `--help`, `-h` | Show help for the current command |
| `--version`, `-v` | Print version and exit |

## API Keys

- `sk_*` keys are **read-write** (required for batch operations)
- `pk_*` keys are **read-only** (sufficient for single verifications)

Get your API key at [goodverify.dev](https://goodverify.dev).

## Build from Source

Requires [Zig](https://ziglang.org/) 0.15.2 or later.

```sh
zig build              # Debug build
zig build test         # Run tests
zig build run -- --help   # Build and run
just release           # Optimized native binary
just dist              # Cross-compile for all 6 platforms
```
