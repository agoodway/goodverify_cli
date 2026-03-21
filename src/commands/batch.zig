const std = @import("std");
const main_mod = @import("../main.zig");
const config = @import("../config.zig");
const gen = @import("../generated.zig");
const table = @import("../table.zig");

const File = std.fs.File;

const default_base_url = "https://goodverify.dev";

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const subcmd = main_mod.getPositional(args) orelse {
        try File.stderr().writeAll("Error: specify a subcommand: list, get, results, or sample\n\n");
        try File.stderr().writeAll(@import("../help.zig").batch_help);
        std.process.exit(1);
    };

    if (std.mem.eql(u8, subcmd, "list")) {
        try listBatches(allocator, args);
    } else if (std.mem.eql(u8, subcmd, "get")) {
        try getBatch(allocator, args);
    } else if (std.mem.eql(u8, subcmd, "results")) {
        try getBatchResults(allocator, args);
    } else if (std.mem.eql(u8, subcmd, "sample")) {
        try getSample(allocator, args);
    } else {
        try main_mod.writeErr(allocator, "Unknown batch subcommand: {s}\n\n", .{subcmd});
        try File.stderr().writeAll(@import("../help.zig").batch_help);
        std.process.exit(1);
    }
}

fn getClient(allocator: std.mem.Allocator, args: []const []const u8) !gen.Client {
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

    return gen.Client.init(allocator, base_url, api_key);
}

fn listBatches(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const client = try getClient(allocator, args);
    const resp = try client.listBatches();
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

    const parsed = try std.json.parseFromSlice(gen.BatchListResponse, allocator, resp.body, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });

    if (parsed.value.data.len == 0) {
        try File.stdout().writeAll("No batch jobs found.\n");
        return;
    }

    const headers = &[_][]const u8{ "ID", "STATUS", "ROWS", "VERIFIED", "FAILED", "TYPE" };
    var tbl = table.Table.init(allocator, headers);

    for (parsed.value.data) |batch| {
        const row = try allocator.alloc([]const u8, 6);
        row[0] = batch.id orelse "-";
        row[1] = batch.status orelse "-";
        row[2] = if (batch.total_rows) |r| try std.fmt.allocPrint(allocator, "{d}", .{r}) else "-";
        row[3] = if (batch.verified_count) |v| try std.fmt.allocPrint(allocator, "{d}", .{v}) else "-";
        row[4] = if (batch.failed_count) |f| try std.fmt.allocPrint(allocator, "{d}", .{f}) else "-";
        row[5] = batch.source_type orelse "-";
        try tbl.addRow(row);
    }

    const output = try tbl.render();
    try File.stdout().writeAll(output);
}

fn getBatch(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const id = main_mod.getFlag(args, "--id") orelse {
        try File.stderr().writeAll("Error: --id is required\n");
        std.process.exit(1);
    };

    const client = try getClient(allocator, args);
    const resp = try client.getBatch(id);
    try handleResponse(allocator, resp, args);
}

fn getBatchResults(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const id = main_mod.getFlag(args, "--id") orelse {
        try File.stderr().writeAll("Error: --id is required\n");
        std.process.exit(1);
    };

    const client = try getClient(allocator, args);
    const resp = try client.getBatchResults(id);
    try handleResponse(allocator, resp, args);
}

fn getSample(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const client = try getClient(allocator, args);
    const resp = try client.getBatchSampleCsv();
    const status_int = @intFromEnum(resp.status);

    if (status_int < 200 or status_int >= 300) {
        try main_mod.writeErr(allocator, "Error: HTTP {d}\n", .{status_int});
        try File.stderr().writeAll(resp.body);
        try File.stderr().writeAll("\n");
        std.process.exit(1);
    }

    try File.stdout().writeAll(resp.body);
}

fn handleResponse(allocator: std.mem.Allocator, resp: gen.Client.RawResponse, args: []const []const u8) !void {
    const status_int = @intFromEnum(resp.status);
    if (status_int >= 200 and status_int < 300) {
        if (main_mod.hasFlag(args, "--json")) {
            try File.stdout().writeAll(resp.body);
            try File.stdout().writeAll("\n");
        } else {
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
    } else {
        try main_mod.writeErr(allocator, "Error: HTTP {d}\n", .{status_int});
        try File.stderr().writeAll(resp.body);
        try File.stderr().writeAll("\n");
        std.process.exit(1);
    }
}
