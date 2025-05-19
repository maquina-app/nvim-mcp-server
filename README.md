# Neovim MCP Server

A Ruby implementation of a Model Context Protocol (MCP) server for Neovim. This server allows LLMs (Large Language Models) to interact with Neovim through the Model Context Protocol, providing capabilities to query buffers and perform operations within the editor.

## What is MCP?

The Model Context Protocol (MCP) is a standardized way for AI models to interact with their environment. It defines a structured method for models to request and use tools, access resources, and maintain context during interactions.

This Neovim MCP Server implements the MCP specification to give AI models access to Neovim for buffer analysis, file exploration, and editing assistance.

## Features

- Connect to running Neovim instances
- Query buffers across multiple Neovim sessions
- Follow the Model Context Protocol standard
- Seamless integration with LLM clients

## Installation

Install the gem:

```bash
gem install nvim-mcp-server
```

After installation, the `nvim-mcp-server` executable will be available in your PATH.

## Configuration

The Neovim MCP Server follows the XDG Base Directory Specification for configuration files:

- On macOS: `$XDG_CONFIG_HOME/nvim-mcp` or `~/.config/nvim-mcp` if XDG_CONFIG_HOME is not set
- On Linux: `$XDG_CONFIG_HOME/nvim-mcp` or `~/.config/nvim-mcp` if XDG_CONFIG_HOME is not set
- On Windows: `%APPDATA%\nvim-mcp`

The server will automatically create these directories and a log file the first time it runs.

## Usage

### Starting the server

The Neovim MCP Server can run in two modes:

1. **STDIO mode (default)**: Communicates over standard input/output for direct integration with clients like Claude Desktop.
2. **HTTP mode**: Runs as an HTTP server with JSON-RPC and Server-Sent Events (SSE) endpoints.

```bash
# Start in default STDIO mode
nvim-mcp-server

# Start in HTTP mode on the default port (6030)
nvim-mcp-server --mode http

# Start in HTTP mode on a custom port
nvim-mcp-server --mode http -p 8080
```

When running in HTTP mode, the server provides two endpoints:

- JSON-RPC endpoint: `http://localhost:<port>/mcp/messages`
- SSE endpoint: `http://localhost:<port>/mcp/sse`

### Logging Options

The server logs to a file in your config directory by default. You can customize logging with these options:

```bash
# Set the log level (debug, info, error)
nvim-mcp-server --log-level debug
```

## Claude Desktop Integration

The Neovim MCP Server can be used with Claude Desktop by manually configuring the integration.

### Direct Configuration

1. Create the appropriate config directory for your platform:
   - macOS: `$XDG_CONFIG_HOME/nvim-mcp` or `~/.config/nvim-mcp` if XDG_CONFIG_HOME is not set
   - Linux: `$XDG_CONFIG_HOME/nvim-mcp` or `~/.config/nvim-mcp` if XDG_CONFIG_HOME is not set
   - Windows: `%APPDATA%\nvim-mcp`

2. Find or create the Claude Desktop configuration file:
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Linux: `~/.config/Claude/claude_desktop_config.json`
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`

3. Add or update the MCP server configuration:

```json
{
  "mcpServers": {
    "nvimMcpServer": {
      "command": "ruby",
      "args": ["/full/path/to/nvim-mcp-server/exe/nvim-mcp-server"] 
    }
  }
}
```

4. Restart Claude Desktop to apply the changes.

### Ruby Version Manager Users

Claude Desktop launches the MCP server using your system's default Ruby environment, bypassing version manager initialization (e.g., rbenv, RVM). The MCP server needs to use the same Ruby version where it was installed, as MCP server startup failures can occur when using an incompatible Ruby version.

If you are using a Ruby version manager such as rbenv, you can create a symbolic link to your Ruby shim to ensure the correct version is used:

```bash
sudo ln -s /home/your_user/.rbenv/shims/ruby /usr/local/bin/ruby
```

Replace "/home/your_user/.rbenv/shims/ruby" with your actual path for the Ruby shim.

### Using an MCP Proxy (Advanced)

Claude Desktop and many other LLM clients only support STDIO mode communication, but you might want to use the HTTP/SSE capabilities of the server. An MCP proxy can bridge this gap:

1. Start the Neovim MCP Server in HTTP mode:

```bash
nvim-mcp-server --mode http
```

2. Install and run an MCP proxy. There are several implementations available in different languages. An MCP proxy allows a client that only supports STDIO communication to communicate via HTTP SSE. Here's an example using a JavaScript-based MCP proxy:

```bash
# Install the Node.js based MCP proxy
npm install -g mcp-remote

# Run the proxy, pointing to your running Neovim MCP Server
npx mcp-remote http://localhost:6030/mcp/sse
```

3. Configure Claude Desktop (or other LLM client) to use the proxy instead of connecting directly to the server:

```json
{
  "mcpServers": {
    "nvimMcpServer": {
      "command": "npx",
      "args": ["mcp-remote", "http://localhost:6030/mcp/sse"]
    }
  }
}
```

This setup allows STDIO-only clients to communicate with the Neovim MCP Server through the proxy, benefiting from the HTTP/SSE capabilities while maintaining client compatibility.

## Neovim Configuration

For the MCP server to work properly, your Neovim instances need to be started with a named socket:

```bash
nvim --listen /tmp/nvim-project_name.sock
```

You can automate this by adding the following to your Neovim configuration:

```lua
-- In your init.lua
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
vim.fn.serverstart('/tmp/nvim-' .. project_name .. '.sock')
```

## How the Server Works

The Neovim MCP Server implements the Model Context Protocol using either:

- **STDIO mode**: Reads JSON-RPC 2.0 requests from standard input and returns responses to standard output.
- **HTTP mode**: Provides HTTP endpoints for JSON-RPC 2.0 requests and Server-Sent Events.

The server communicates with Neovim instances through Unix sockets located at `/tmp/nvim-{project_name}.sock`. This allows the server to interact with multiple Neovim instances running different projects.

## Available Tools

The server provides the following tools for interacting with Neovim:

### 1. `get_project_buffers`

**Description:** Retrieves a list of files currently open in Neovim that belong to a specific project. This tool connects to a running Neovim instance using its socket file at /tmp/nvim-{project_name}.sock and queries for all open buffers. It then filters the buffers to include only files that have the project name as part of their path. This is useful for determining what files a user is currently editing in a particular project, identifying areas of active development, or tracking work context across multiple files. The tool handles connection failures gracefully and returns complete absolute file paths.

**Parameters:**

- `project_name`: (String, required) The name of the project directory to filter buffers by. This should match a directory name in the file paths of the buffers you want to retrieve. For example, if your project is at '/home/user/projects/my-app', you would use 'my-app' as the project_name. The tool will also use this name to locate the Neovim socket at /tmp/nvim-{project_name}.sock.

#### Examples

```
Can you show me which files I have open in my "my-project" Neovim instance?
```

```
I'd like to know what files I'm currently working on in the "blog" project.
```

```
List all the buffers for the "nvim-mcp-server" project.
```

## Testing and Debugging

The easiest way to test and debug the Neovim MCP Server is by using the MCP Inspector, a developer tool designed specifically for testing and debugging MCP servers.

To use MCP Inspector with Neovim MCP Server:

```bash
# Install and run MCP Inspector with your Neovim MCP Server
npm -g install @modelcontextprotocol/inspector

npx @modelcontextprotocol/inspector /path/to/nvim-mcp-server
```

This will:

1. Start your Neovim MCP Server in HTTP mode
2. Launch the MCP Inspector UI in your browser (default port: 6274)

In the MCP Inspector UI, you can:

- See all available tools
- Execute tool calls interactively
- View request and response details
- Debug issues in real-time

## License

This Neovim MCP server is released under the MIT License, a permissive open-source license that allows for free use, modification, distribution, and private use.

Copyright (c) 2025 Mario Alberto Chávez Cárdenas

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/maquina-app/nvim-mcp-server>.
