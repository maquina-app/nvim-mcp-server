# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2025-07-21

### Added

- **Network Access Support**: New `--bind-all` flag for HTTP mode to allow access from local network
  - Binds to `0.0.0.0` instead of `localhost` when enabled
  - Allows connections from local network IP ranges (192.168.x.x, 10.x.x.x, 172.16.x.x)
  - Accepts connections from `.local` domain names (e.g., `my-computer.local`)
  - Maintains security features with origin validation and IP filtering

### Improved

- **Security Configuration**: Enhanced allowed origins and IP configuration when using `--bind-all`
  - Automatically configures appropriate security settings for local network access
  - Preserves localhost-only mode by default for security
  - Clear documentation of security implications

### Changed

- HTTP server binding address is now configurable via `--bind-all` flag
- Updated help text to include new network access option
- Fixed typo in default response text (was showing "Rails MCP Server" instead of "Neovim MCP Server")

## [0.2.0] - 2025-07-08

### Added

- New `update_buffer` tool that allows MCP clients to update buffer content in Neovim
- Ability to save updated buffers to disk and reload them automatically
- Support for external tools (like AI assistants) to modify files open in Neovim

### Changed

- Updated tool registration to include both `GetProjectBuffersTool` and `UpdateBufferTool`

## [0.1.0] - 2025-05-17

### Added

- Initial release
- Basic MCP server implementation for Neovim
- Support for both STDIO and HTTP modes
- `get_project_buffers` tool to query open buffers in Neovim instances
- Integration with Claude Desktop
- Logging functionality with configurable log levels
- XDG Base Directory Specification compliance for configuration files
- Support for multiple Neovim instances via Unix sockets
- MCP Inspector compatibility for testing and debugging
