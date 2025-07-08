require "logger"
require "neovim"
require "forwardable"
require_relative "nvim-mcp-server/version"
require_relative "nvim-mcp-server/config"
require_relative "nvim-mcp-server/tools/base_tool"
require_relative "nvim-mcp-server/tools/get_project_buffers_tool"
require_relative "nvim-mcp-server/tools/update_buffer_tool"

module NvimMcpServer
  @levels = {debug: Logger::DEBUG, info: Logger::INFO, error: Logger::ERROR}
  @config = Config.setup

  class << self
    extend Forwardable

    attr_reader :config

    def_delegators :@config, :log_level, :log_level=
    def_delegators :@config, :logger, :logger=

    def log(level, message)
      log_level = @levels[level] || Logger::INFO

      @config.logger.add(log_level, message)
    end
  end
  class Error < StandardError; end
end
