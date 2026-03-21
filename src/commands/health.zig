const std = @import("std");
const main_mod = @import("../main.zig");
const config = @import("../config.zig");
const gen = @import("../generated.zig");

const File = std.fs.File;

const default_base_url = "https://goodverify.dev";

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const cfg = try config.load(allocator);
    const env_name = main_mod.getFlag(args, "--env");
    const env = config.getEnv(cfg, env_name);

    const base_url = main_mod.getFlag(args, "--url") orelse
        if (env) |e| (e.base_url orelse default_base_url) else default_base_url;

    // Health endpoint doesn't require auth, but use it if available
    const api_key = main_mod.getFlag(args, "--key") orelse
        if (env) |e| (e.api_key orelse "none") else "none";

    const client = gen.Client.init(allocator, base_url, api_key);
    const resp = try client.getHealth();
    const status_int = @intFromEnum(resp.status);

    if (status_int < 200 or status_int >= 300) {
        try main_mod.writeErr(allocator, "Error: HTTP {d}\n", .{status_int});
        try File.stderr().writeAll(resp.body);
        try File.stderr().writeAll("\n");
        std.process.exit(1);
    }

    if (main_mod.hasFlag(args, "--json")) {
        try File.stdout().writeAll(resp.body);
        try File.stdout().writeAll("\n");
        return;
    }

    const parsed = std.json.parseFromSlice(gen.HealthResponse, allocator, resp.body, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    }) catch {
        try File.stdout().writeAll(resp.body);
        try File.stdout().writeAll("\n");
        return;
    };

    try main_mod.writeOut(allocator, "Status: {s}\n", .{parsed.value.status orelse "unknown"});
    if (parsed.value.timestamp) |ts| {
        try main_mod.writeOut(allocator, "Time:   {s}\n", .{ts});
    }
}
