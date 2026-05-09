///////////////////////////////////////////
// Generated from OpenAPI spec, then fixed for Zig 0.15.2.
// Regenerate types: openapi2zig generate -i ../app/openapi.json -o src/generated.zig
// Then manually fix nested types and client functions.
///////////////////////////////////////////

const std = @import("std");

// --- Models ---

pub const VerificationMetadata = struct {
    verified_at: ?[]const u8 = null,
};

pub const StandardizedAddress = struct {
    city: ?[]const u8 = null,
    country_code: ?[]const u8 = null,
    county: ?[]const u8 = null,
    formatted: ?[]const u8 = null,
    full_address: ?[]const u8 = null,
    state: ?[]const u8 = null,
    street: ?[]const u8 = null,
    street2: ?[]const u8 = null,
    zip: ?[]const u8 = null,
    zip4: ?[]const u8 = null,
};

pub const GeoLocation = struct {
    accuracy: ?[]const u8 = null,
    latitude: ?f64 = null,
    longitude: ?f64 = null,
};

pub const PropertyInfo = struct {
    is_vacant: ?bool = null,
    type: ?[]const u8 = null,
};

pub const PersonName = struct {
    first: ?[]const u8 = null,
    full: ?[]const u8 = null,
    last: ?[]const u8 = null,
    middle: ?[]const u8 = null,
};

pub const PersonAddress = struct {
    address_validity: ?[]const u8 = null,
    city: ?[]const u8 = null,
    county: ?[]const u8 = null,
    full_address: ?[]const u8 = null,
    is_mailing_address: ?bool = null,
    rank: ?i64 = null,
    state: ?[]const u8 = null,
    street: ?[]const u8 = null,
    zip: ?[]const u8 = null,
    zip_plus_4: ?[]const u8 = null,
};

pub const PersonEmail = struct {
    email: ?[]const u8 = null,
    rank: ?i64 = null,
    tested: ?bool = null,
    type: ?[]const u8 = null,
};

pub const PersonPhone = struct {
    carrier: ?[]const u8 = null,
    dnc: ?bool = null,
    is_connected: ?bool = null,
    number: ?[]const u8 = null,
    rank: ?i64 = null,
    reachable: ?bool = null,
    tcpa: ?bool = null,
    tested: ?bool = null,
    type: ?[]const u8 = null,
};

pub const Person = struct {
    addresses: ?[]const PersonAddress = null,
    date_of_birth: ?[]const u8 = null,
    emails: ?[]const PersonEmail = null,
    is_deceased: ?bool = null,
    is_litigator: ?bool = null,
    is_property_owner: ?bool = null,
    name: ?PersonName = null,
    phones: ?[]const PersonPhone = null,
};

pub const AddressVerifyResponse = struct {
    deliverability: ?[]const u8 = null,
    geo_location: ?GeoLocation = null,
    metadata: ?VerificationMetadata = null,
    original_address: ?[]const u8 = null,
    owners: ?[]const Person = null,
    property: ?PropertyInfo = null,
    standardized_address: ?StandardizedAddress = null,
};

pub const DomainInfo = struct {
    has_mx_records: ?bool = null,
    has_spf: ?bool = null,
    name: ?[]const u8 = null,
};

pub const EmailDeliverability = struct {
    reason: ?[]const u8 = null,
    status: ?[]const u8 = null,
};

pub const EmailFlags = struct {
    is_catch_all: ?bool = null,
    is_disposable: ?bool = null,
    is_free_provider: ?bool = null,
    is_role_account: ?bool = null,
};

pub const EmailVerifyResponse = struct {
    deliverability: ?EmailDeliverability = null,
    domain: ?DomainInfo = null,
    email: ?[]const u8 = null,
    flags: ?EmailFlags = null,
    metadata: ?VerificationMetadata = null,
};

pub const CarrierInfo = struct {
    name: ?[]const u8 = null,
    type: ?[]const u8 = null,
};

pub const PhoneCompliance = struct {
    dnc: ?bool = null,
    reachable: ?bool = null,
    tcpa: ?bool = null,
    tested: ?bool = null,
};

pub const PhoneCountry = struct {
    calling_code: ?[]const u8 = null,
    code: ?[]const u8 = null,
    name: ?[]const u8 = null,
};

pub const PhoneFormatted = struct {
    e164: ?[]const u8 = null,
    international: ?[]const u8 = null,
    national: ?[]const u8 = null,
};

pub const PhoneLocation = struct {
    city: ?[]const u8 = null,
    country: ?[]const u8 = null,
    state: ?[]const u8 = null,
};

pub const PhoneVerifyResponse = struct {
    carrier: ?CarrierInfo = null,
    compliance: ?PhoneCompliance = null,
    country: ?PhoneCountry = null,
    formatted: ?PhoneFormatted = null,
    location: ?PhoneLocation = null,
    metadata: ?VerificationMetadata = null,
    phone_number: ?[]const u8 = null,
    phone_type: ?[]const u8 = null,
    valid: ?bool = null,
};

pub const BatchJobResponse = struct {
    completed_at: ?[]const u8 = null,
    credit_cost: ?i64 = null,
    failed_count: ?i64 = null,
    id: ?[]const u8 = null,
    inserted_at: ?[]const u8 = null,
    processed_rows: ?i64 = null,
    refunded_credits: ?i64 = null,
    skipped_count: ?i64 = null,
    source_type: ?[]const u8 = null,
    status: ?[]const u8 = null,
    total_rows: ?i64 = null,
    verified_count: ?i64 = null,
};

pub const BatchCreateResponse = struct {
    credit_cost: ?i64 = null,
    id: ?[]const u8 = null,
    status: ?[]const u8 = null,
    total_rows: ?i64 = null,
};

pub const BatchResultResponse = struct {
    @"error": ?[]const u8 = null,
    id: ?[]const u8 = null,
    row_number: ?i64 = null,
    status: ?[]const u8 = null,
    verification_type: ?[]const u8 = null,
};

pub const BatchListResponse = struct {
    data: []const BatchJobResponse,
};

pub const BatchResultsListResponse = struct {
    data: []const BatchResultResponse,
};

pub const HealthResponse = struct {
    status: ?[]const u8 = null,
    timestamp: ?[]const u8 = null,
};

pub const UsageResponse = struct {
    plan: ?[]const u8 = null,
};

pub const ErrorFieldDetail = struct {
    code: ?[]const u8 = null,
    field: ?[]const u8 = null,
    message: ?[]const u8 = null,
};

pub const ErrorDetail = struct {
    code: ?[]const u8 = null,
    fields: ?[]const ErrorFieldDetail = null,
    message: ?[]const u8 = null,
};

pub const ErrorResponse = struct {
    @"error": ?ErrorDetail = null,
};

// --- API Client ---

pub const Client = struct {
    allocator: std.mem.Allocator,
    base_url: []const u8,
    api_key: []const u8,

    pub fn init(allocator: std.mem.Allocator, base_url: []const u8, api_key: []const u8) Client {
        return .{ .allocator = allocator, .base_url = base_url, .api_key = api_key };
    }

    pub const RawResponse = struct {
        status: std.http.Status,
        body: []const u8,
    };

    /// POST /api/v1/verify/email
    pub fn verifyEmail(self: *const Client, body: []const u8) !RawResponse {
        return self.request(.POST, "/api/v1/verify/email", body);
    }

    /// POST /api/v1/verify/phone
    pub fn verifyPhone(self: *const Client, body: []const u8) !RawResponse {
        return self.request(.POST, "/api/v1/verify/phone", body);
    }

    /// POST /api/v1/verify/address
    pub fn verifyAddress(self: *const Client, body: []const u8) !RawResponse {
        return self.request(.POST, "/api/v1/verify/address", body);
    }

    /// POST /api/v1/verify/address/fields
    pub fn verifyAddressFields(self: *const Client, body: []const u8) !RawResponse {
        return self.request(.POST, "/api/v1/verify/address/fields", body);
    }

    /// GET /api/v1/batch
    pub fn listBatches(self: *const Client) !RawResponse {
        return self.request(.GET, "/api/v1/batch", null);
    }

    /// POST /api/v1/batch
    pub fn createBatch(self: *const Client, body: []const u8) !RawResponse {
        return self.request(.POST, "/api/v1/batch", body);
    }

    /// POST /api/v1/batch with multipart CSV upload
    pub fn createBatchCsv(self: *const Client, filename: []const u8, file_content: []const u8) !RawResponse {
        const boundary = "goodverify-cli-boundary";
        const content_type = try std.fmt.allocPrint(self.allocator, "multipart/form-data; boundary={s}", .{boundary});
        defer self.allocator.free(content_type);

        var body: std.ArrayList(u8) = .{};
        defer body.deinit(self.allocator);

        try body.appendSlice(self.allocator, "--" ++ boundary ++ "\r\n");
        try body.appendSlice(self.allocator, "Content-Disposition: form-data; name=\"file\"; filename=\"");
        try body.appendSlice(self.allocator, filename);
        try body.appendSlice(self.allocator, "\"\r\n");
        try body.appendSlice(self.allocator, "Content-Type: text/csv\r\n\r\n");
        try body.appendSlice(self.allocator, file_content);
        try body.appendSlice(self.allocator, "\r\n--" ++ boundary ++ "--\r\n");

        const payload = try body.toOwnedSlice(self.allocator);
        defer self.allocator.free(payload);

        return self.requestWithContentType(.POST, "/api/v1/batch", payload, content_type);
    }

    /// GET /api/v1/batch/{id}
    pub fn getBatch(self: *const Client, id: []const u8) !RawResponse {
        const path = try std.fmt.allocPrint(self.allocator, "/api/v1/batch/{s}", .{id});
        defer self.allocator.free(path);
        return self.request(.GET, path, null);
    }

    /// GET /api/v1/batch/{id}/results
    pub fn getBatchResults(self: *const Client, id: []const u8) !RawResponse {
        const path = try std.fmt.allocPrint(self.allocator, "/api/v1/batch/{s}/results", .{id});
        defer self.allocator.free(path);
        return self.request(.GET, path, null);
    }

    /// GET /api/v1/batch/sample.csv
    pub fn getBatchSampleCsv(self: *const Client) !RawResponse {
        return self.request(.GET, "/api/v1/batch/sample.csv", null);
    }

    /// GET /api/v1/health
    pub fn getHealth(self: *const Client) !RawResponse {
        return self.request(.GET, "/api/v1/health", null);
    }

    /// GET /api/v1/usage
    pub fn getUsage(self: *const Client) !RawResponse {
        return self.request(.GET, "/api/v1/usage", null);
    }

    fn request(self: *const Client, method: std.http.Method, path: []const u8, body: ?[]const u8) !RawResponse {
        return self.requestWithContentType(method, path, body, "application/json");
    }

    fn requestWithContentType(
        self: *const Client,
        method: std.http.Method,
        path: []const u8,
        body: ?[]const u8,
        content_type: []const u8,
    ) !RawResponse {
        const url = try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ self.base_url, path });
        defer self.allocator.free(url);

        const auth_header = try std.fmt.allocPrint(self.allocator, "Bearer {s}", .{self.api_key});
        defer self.allocator.free(auth_header);

        var http_client: std.http.Client = .{ .allocator = self.allocator };
        defer http_client.deinit();

        var aw: std.Io.Writer.Allocating = .init(self.allocator);
        defer aw.deinit();

        const result = try http_client.fetch(.{
            .location = .{ .url = url },
            .method = method,
            .payload = body,
            .response_writer = &aw.writer,
            .extra_headers = &.{
                .{ .name = "Authorization", .value = auth_header },
                .{ .name = "Content-Type", .value = content_type },
            },
            .headers = .{ .accept_encoding = .omit },
        });

        var al = aw.toArrayList();
        const response_body = try al.toOwnedSlice(self.allocator);
        return .{ .status = result.status, .body = response_body };
    }
};
