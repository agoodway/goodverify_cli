const std = @import("std");
const main_mod = @import("../main.zig");
const config = @import("../config.zig");

const File = std.fs.File;

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    if (main_mod.hasFlag(args, "--show")) {
        try showConfig(allocator);
        return;
    }

    const env_name = main_mod.getFlag(args, "--env") orelse {
        try File.stderr().writeAll("Error: --env is required\n\n");
        try File.stderr().writeAll(@import("../help.zig").configure_help);
        std.process.exit(1);
    };

    const base_url = main_mod.getFlag(args, "--url");
    const api_key = main_mod.getFlag(args, "--key");

    if (base_url == null and api_key == null) {
        try File.stderr().writeAll("Error: at least --url or --key is required\n\n");
        try File.stderr().writeAll(@import("../help.zig").configure_help);
        std.process.exit(1);
    }

    var cfg = try config.load(allocator);
    try config.setEnv(allocator, &cfg, env_name, base_url, api_key);
    try config.save(allocator, cfg);

    try main_mod.writeOut(allocator, "Configured environment: {s}\n", .{env_name});
}

fn showConfig(allocator: std.mem.Allocator) !void {
    const cfg = try config.load(allocator);

    if (cfg.environments == null) {
        try File.stdout().writeAll("No environments configured.\n");
        try File.stdout().writeAll("Run: goodverify configure --env <name> --key <api_key>\n");
        return;
    }

    try main_mod.writeOut(allocator, "Default: {s}\n\n", .{cfg.default_env orelse "(none)"});

    for (cfg.environments.?) |env| {
        try main_mod.writeOut(allocator, "  [{s}]\n", .{env.name});
        if (env.base_url) |url| {
            try main_mod.writeOut(allocator, "    url: {s}\n", .{url});
        }
        if (env.api_key) |key| {
            const masked = try config.maskKey(allocator, key);
            try main_mod.writeOut(allocator, "    key: {s}\n", .{masked});
        }
        try File.stdout().writeAll("\n");
    }
}
