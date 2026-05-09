// Comprehensive help text for all commands and subcommands.
// Designed to be machine-readable by AI coding agents — every flag,
// argument, and behavior is documented in plain text.
//
// IMPORTANT: When adding a new command, you must:
// 1. Add a help constant here (e.g. pub const my_cmd_help)
// 2. Update root_help to list the new command
// 3. Add dispatch in main.zig dispatchHelp()

pub const root_help =
    \\goodverify — CLI client for goodverify.dev
    \\
    \\Usage:
    \\  goodverify <command> [options]
    \\  goodverify help <command>
    \\
    \\Commands:
    \\  verify       Verify an email, phone, or address
    \\  batch        Manage batch verification jobs
    \\  usage        Show API usage and credit balance
    \\  health       Check API health status
    \\  configure    Set up API key and environment
    \\  help         Show help for any command
    \\
    \\Global Options:
    \\  --help, -h       Show help for the current command
    \\  --version, -v    Print version and exit
    \\
    \\Run 'goodverify help <command>' for details on a specific command.
    \\
;

pub const verify_help =
    \\goodverify verify — Verify an email, phone number, or address.
    \\
    \\Usage:
    \\  goodverify verify email --email <address>
    \\  goodverify verify phone --phone <number> [--country <code>]
    \\  goodverify verify address --address <full_address>
    \\  goodverify verify address --street <street> --city <city> --state <state> --zip <zip>
    \\
    \\Types:
    \\  email        Verify an email address (deliverability, domain, flags)
    \\  phone        Verify a phone number (carrier, type, compliance)
    \\  address      Verify a mailing address (standardization, deliverability, owners)
    \\
    \\Options:
    \\  --email <addr>       Email address to verify
    \\  --phone <number>     Phone number to verify
    \\  --country <code>     Country code (e.g. US, CA) — optional for phone/address
    \\  --address <addr>     Full address as a single string
    \\  --street <street>    Street address (use with --city, --state, --zip)
    \\  --street2 <unit>     Apartment/suite number
    \\  --city <city>        City name
    \\  --state <state>      State abbreviation
    \\  --zip <zip>          ZIP code
    \\  --env <name>         Use a specific configured environment
    \\  --key <key>          Override API key
    \\  --url <url>          Override base URL
    \\  --json               Output raw JSON response
    \\
    \\Behavior:
    \\  - Uses API key and base URL from configured environment (see: configure)
    \\  - Address can be verified as a single string (--address) or structured fields
    \\  - Structured address requires --street, --city, --state, --zip
    \\  - Output is pretty-printed JSON by default; use --json for raw response
    \\
    \\Exit Codes:
    \\  0    Verification completed (check response for result)
    \\  1    Missing required flags, no API key, or HTTP error
    \\
    \\Examples:
    \\  goodverify verify email --email user@example.com
    \\  goodverify verify phone --phone "+15551234567"
    \\  goodverify verify phone --phone "5551234567" --country US
    \\  goodverify verify address --address "123 Main St, Springfield, IL 62701"
    \\  goodverify verify address --street "123 Main St" --city Springfield --state IL --zip 62701
    \\  goodverify verify email --email user@example.com --json
    \\
;

pub const batch_help =
    \\goodverify batch — Manage batch verification jobs.
    \\
    \\Usage:
    \\  goodverify batch create --json-body '<json>'
    \\  goodverify batch create --file <request.json>
    \\  goodverify batch create --csv <data.csv>
    \\  goodverify batch list
    \\  goodverify batch get --id <batch_id>
    \\  goodverify batch results --id <batch_id>
    \\  goodverify batch sample
    \\
    \\Subcommands:
    \\  create       Create a batch verification job from JSON or CSV
    \\  list         List all batch jobs
    \\  get          Get details of a specific batch job
    \\  results      Download results of a completed batch job
    \\  sample       Download sample CSV template
    \\
    \\Options:
    \\  --json-body <json>   JSON body for POST /api/v1/batch
    \\  --file <path>        Read JSON body from a file
    \\  --csv <path>         Upload a CSV file as multipart/form-data
    \\  --id <batch_id>      Batch job ID (required for get and results)
    \\  --env <name>         Use a specific configured environment
    \\  --key <key>          Override API key
    \\  --url <url>          Override base URL
    \\  --json               Output raw JSON response
    \\
    \\Behavior:
    \\  - 'create' submits a JSON or CSV batch request and returns the accepted job
    \\  - JSON body must contain a 'verifications' array
    \\  - CSV uploads use the same format returned by 'batch sample'
    \\  - 'list' shows a table of all batch jobs with status, row counts, and type
    \\  - 'get' returns full details of a batch job as JSON
    \\  - 'results' returns verification results for each row in the batch
    \\  - 'sample' outputs a CSV template you can fill in and submit
    \\
    \\Exit Codes:
    \\  0    Success
    \\  1    Missing required flags, no API key, or HTTP error
    \\
    \\Examples:
    \\  goodverify batch create --file batch.json
    \\  goodverify batch create --csv contacts.csv
    \\  goodverify batch create --json-body '{"verifications":[{"type":"email","email":"user@example.com"}]}'
    \\  goodverify batch list
    \\  goodverify batch list --json
    \\  goodverify batch get --id abc123
    \\  goodverify batch results --id abc123
    \\  goodverify batch sample > template.csv
    \\
;

pub const usage_help =
    \\goodverify usage — Show API usage and credit balance.
    \\
    \\Usage:
    \\  goodverify usage
    \\
    \\Options:
    \\  --env <name>         Use a specific configured environment
    \\  --key <key>          Override API key
    \\  --url <url>          Override base URL
    \\  --json               Output raw JSON response
    \\
    \\Behavior:
    \\  - Shows current plan, credit balance, usage stats, and rate limits
    \\  - Requires an authenticated API key
    \\
    \\Exit Codes:
    \\  0    Success
    \\  1    No API key configured or HTTP error
    \\
    \\Examples:
    \\  goodverify usage
    \\  goodverify usage --env production
    \\  goodverify usage --json
    \\
;

pub const health_help =
    \\goodverify health — Check API health status.
    \\
    \\Usage:
    \\  goodverify health
    \\
    \\Options:
    \\  --env <name>         Use a specific configured environment
    \\  --url <url>          Override base URL
    \\  --json               Output raw JSON response
    \\
    \\Behavior:
    \\  - Checks if the GoodVerify API is responding
    \\  - Does not require authentication
    \\  - Returns status and server timestamp
    \\
    \\Exit Codes:
    \\  0    API is healthy
    \\  1    API is unreachable or returned an error
    \\
    \\Examples:
    \\  goodverify health
    \\  goodverify health --url http://localhost:4000
    \\  goodverify health --json
    \\
;

pub const configure_help =
    \\goodverify configure — Set up API key and environment configuration.
    \\
    \\Usage:
    \\  goodverify configure --env <name> --url <base_url> --key <api_key>
    \\  goodverify configure --env <name> --key <api_key>
    \\  goodverify configure --show
    \\
    \\Options:
    \\  --env <name>     Environment name (e.g. dev, staging, production)
    \\  --url <url>      Base URL for the API (default: https://goodverify.dev)
    \\  --key <key>      API key (sk_* for read-write, pk_* for read-only)
    \\  --show           Show current configuration (keys are masked)
    \\
    \\Behavior:
    \\  - Stores config at ~/.goodverify.json on macOS/Linux and %USERPROFILE%\\.goodverify.json on Windows
    \\  - First configured environment becomes the default
    \\  - Re-running with same --env updates existing values
    \\  - --show prints all environments with masked API keys
    \\
    \\Exit Codes:
    \\  0    Success
    \\  1    Missing required flags or configuration error
    \\
    \\Examples:
    \\  goodverify configure --env production --key sk_live_abc123
    \\  goodverify configure --env dev --url http://localhost:4000 --key sk_test_xyz
    \\  goodverify configure --show
    \\
;
