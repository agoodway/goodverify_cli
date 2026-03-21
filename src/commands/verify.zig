const std = @import("std");
const main_mod = @import("../main.zig");
const config = @import("../config.zig");
const gen = @import("../generated.zig");

const File = std.fs.File;

const default_base_url = "https://goodverify.dev";

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const subcmd = main_mod.getPositional(args) orelse {
        try File.stderr().writeAll("Error: specify a type: email, phone, or address\n\n");
        try File.stderr().writeAll(@import("../help.zig").verify_help);
        std.process.exit(1);
    };

    if (std.mem.eql(u8, subcmd, "email")) {
        try verifyEmail(allocator, args);
    } else if (std.mem.eql(u8, subcmd, "phone")) {
        try verifyPhone(allocator, args);
    } else if (std.mem.eql(u8, subcmd, "address")) {
        try verifyAddress(allocator, args);
    } else {
        try main_mod.writeErr(allocator, "Unknown verify type: {s}\n\n", .{subcmd});
        try File.stderr().writeAll(@import("../help.zig").verify_help);
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

fn verifyEmail(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const email = main_mod.getFlag(args, "--email") orelse {
        try File.stderr().writeAll("Error: --email is required\n");
        std.process.exit(1);
    };

    const client = try getClient(allocator, args);
    const body = try std.fmt.allocPrint(allocator, "{{\"email\":\"{s}\"}}", .{email});
    defer allocator.free(body);

    const resp = try client.verifyEmail(body);
    try handleResponse(allocator, resp, args);
}

fn verifyPhone(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const phone = main_mod.getFlag(args, "--phone") orelse {
        try File.stderr().writeAll("Error: --phone is required\n");
        std.process.exit(1);
    };

    const client = try getClient(allocator, args);

    const country = main_mod.getFlag(args, "--country");
    const body = if (country) |c|
        try std.fmt.allocPrint(allocator, "{{\"phone_number\":\"{s}\",\"country_code\":\"{s}\"}}", .{ phone, c })
    else
        try std.fmt.allocPrint(allocator, "{{\"phone_number\":\"{s}\"}}", .{phone});
    defer allocator.free(body);

    const resp = try client.verifyPhone(body);
    try handleResponse(allocator, resp, args);
}

fn verifyAddress(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const address = main_mod.getFlag(args, "--address");
    const street = main_mod.getFlag(args, "--street");

    if (address == null and street == null) {
        try File.stderr().writeAll("Error: --address or --street is required\n");
        std.process.exit(1);
    }

    const client = try getClient(allocator, args);

    if (address) |addr| {
        const country = main_mod.getFlag(args, "--country");
        const body = if (country) |c|
            try std.fmt.allocPrint(allocator, "{{\"address\":\"{s}\",\"country_code\":\"{s}\"}}", .{ addr, c })
        else
            try std.fmt.allocPrint(allocator, "{{\"address\":\"{s}\"}}", .{addr});
        defer allocator.free(body);

        const resp = try client.verifyAddress(body);
        try handleResponse(allocator, resp, args);
    } else {
        const city = main_mod.getFlag(args, "--city") orelse {
            try File.stderr().writeAll("Error: --city is required with --street\n");
            std.process.exit(1);
        };
        const state = main_mod.getFlag(args, "--state") orelse {
            try File.stderr().writeAll("Error: --state is required with --street\n");
            std.process.exit(1);
        };
        const zip = main_mod.getFlag(args, "--zip") orelse {
            try File.stderr().writeAll("Error: --zip is required with --street\n");
            std.process.exit(1);
        };
        const street2 = main_mod.getFlag(args, "--street2");
        const country = main_mod.getFlag(args, "--country");

        var buf: std.ArrayList(u8) = .{};
        try buf.appendSlice(allocator, "{\"street\":\"");
        try buf.appendSlice(allocator, street.?);
        try buf.appendSlice(allocator, "\"");
        if (street2) |s2| {
            try buf.appendSlice(allocator, ",\"street2\":\"");
            try buf.appendSlice(allocator, s2);
            try buf.appendSlice(allocator, "\"");
        }
        try buf.appendSlice(allocator, ",\"city\":\"");
        try buf.appendSlice(allocator, city);
        try buf.appendSlice(allocator, "\",\"state\":\"");
        try buf.appendSlice(allocator, state);
        try buf.appendSlice(allocator, "\",\"zip\":\"");
        try buf.appendSlice(allocator, zip);
        try buf.appendSlice(allocator, "\"");
        if (country) |c| {
            try buf.appendSlice(allocator, ",\"country_code\":\"");
            try buf.appendSlice(allocator, c);
            try buf.appendSlice(allocator, "\"");
        }
        try buf.appendSlice(allocator, "}");
        const body = try buf.toOwnedSlice(allocator);
        defer allocator.free(body);

        const resp = try client.verifyAddressFields(body);
        try handleResponse(allocator, resp, args);
    }
}

fn handleResponse(allocator: std.mem.Allocator, resp: gen.Client.RawResponse, args: []const []const u8) !void {
    const status_int = @intFromEnum(resp.status);
    if (status_int >= 200 and status_int < 300) {
        if (main_mod.hasFlag(args, "--json")) {
            try File.stdout().writeAll(resp.body);
            try File.stdout().writeAll("\n");
        } else {
            try prettyPrint(allocator, resp.body);
        }
    } else {
        try main_mod.writeErr(allocator, "Error: HTTP {d}\n", .{status_int});
        try File.stderr().writeAll(resp.body);
        try File.stderr().writeAll("\n");
        std.process.exit(1);
    }
}

fn prettyPrint(allocator: std.mem.Allocator, body: []const u8) !void {
    const parsed = std.json.parseFromSlice(std.json.Value, allocator, body, .{
        .allocate = .alloc_always,
    }) catch {
        try File.stdout().writeAll(body);
        try File.stdout().writeAll("\n");
        return;
    };
    const formatted = try std.fmt.allocPrint(allocator, "{f}", .{std.json.fmt(parsed.value, .{ .whitespace = .indent_2 })});
    defer allocator.free(formatted);
    try File.stdout().writeAll(formatted);
    try File.stdout().writeAll("\n");
}
