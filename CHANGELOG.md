# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
