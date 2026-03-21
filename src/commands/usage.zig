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

    const api_key = main_mod.getFlag(args, "--key") orelse
        if (env) |e| (e.api_key orelse {
        try File.stderr().writeAll("Error: no API key configured. Run: goodverify configure --env <name> --key <key>\n");
        std.process.exit(1);
    }) else {
        try File.stderr().writeAll("Error: no API key configured. Run: goodverify configure --env <name> --key <key>\n");
        std.process.exit(1);
    };

    const client = gen.Client.init(allocator, base_url, api_key);
    const resp = try client.getUsage();
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

    // Pretty-print the JSON response
    const parsed = std.json.parseFromSlice(std.json.Value, allocator, resp.body, .{
        .allocate = .alloc_always,
    }) catch {
        try File.stdout().writeAll(resp.body);
        try File.stdout().writeAll("\n");
        return;
    };
    const formatted = try std.fmt.allocPrint(allocator, "{f}", .{std.json.fmt(parsed.value, .{ .whitespace = .indent_2 })});
    defer allocator.free(formatted);
    try File.stdout().writeAll(formatted);
    try File.stdout().writeAll("\n");
}
