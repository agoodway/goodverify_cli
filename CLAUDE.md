# CLAUDE.md — goodverify

## What This Is

CLI client for goodverify.dev. Built in Zig with zero external dependencies. Single static binary (~1MB).

## Commands

zig build                  # Build debug binary
zig build test             # Run tests
zig build run -- <args>    # Build and run
just release               # Build optimized native binary
just dist                  # Cross-compile all 6 platform binaries

## Project Structure

src/
  main.zig              # CLI entry point, arg parsing, command routing
  help.zig              # All help text (agent-readable, one const per command)
  config.zig            # Per-environment config (~/.goodverify.json, Windows: %USERPROFILE%\.goodverify.json)
  generated.zig         # API types + HTTP client (from OpenAPI spec)
  table.zig             # Column-aligned table printer
  commands/              # Command implementations
    configure.zig       # Environment/API key setup

## Adding a New Command

When adding a new command, you MUST update THREE files:

1. **src/main.zig** — Add routing in `main()` and `dispatchHelp()`
2. **src/help.zig** — Add a help constant with usage, flags, arguments, behavior, exit codes, and examples. Also update root_help to list the new command.
3. **src/commands/<name>.zig** — Implementation

## API Client (generated.zig)

Types and client live in `src/generated.zig`. Seeded from `../app/openapi.json`.

Regenerate after API changes:
  ~/.local/bin/openapi2zig generate -i ../app/openapi.json -o src/generated.zig
  # Then manually fix nested types, function names, and Zig 0.15.2 API calls

The client uses named methods (e.g. `verifyEmail`, `verifyPhone`, `listBatches`) that map
1:1 to REST endpoints. Commands import via `const gen = @import("../generated.zig");`.

## Config

Config stored at `~/.goodverify.json` with per-environment settings (base_url, api_key).
On Windows, config is stored at `%USERPROFILE%\.goodverify.json`.
Default base URL: `https://goodverify.dev`
API keys: `sk_*` for read-write, `pk_*` for read-only.

## Zig 0.15.2 Gotchas

- No `std.io.getStdOut()` — Use `std.fs.File.stdout()`
- No `ArrayList.init(allocator)` — Use `var list: std.ArrayList(u8) = .{};` + pass allocator to methods
- No `std.json.stringify` — Use `std.json.fmt()` with `std.fmt.allocPrint("{f}", .{...})`
- Table rows in loops must be heap-allocated (not `&.{...}`)
- Use `std.heap.page_allocator` for CLI processes
