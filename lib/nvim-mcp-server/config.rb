module NvimMcpServer
  class Config
    attr_accessor :logger, :log_level

    def self.setup
      new.tap do |instance|
        yield(instance) if block_given?
      end
    end

    def initialize
      @log_level = Logger::INFO
      @config_dir = get_config_dir

      configure_logger
    end

    private

    def configure_logger
      FileUtils.mkdir_p(File.join(@config_dir, "log"))
      log_file = File.join(@config_dir, "log", "nvim_mcp_server.log")

      @logger = Logger.new(log_file)
      @logger.level = @log_level

      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] #{severity}: #{msg}\n"
      end
    end

    def get_config_dir
      # Use XDG_CONFIG_HOME if set, otherwise use ~/.config
      xdg_config_home = ENV["XDG_CONFIG_HOME"]
      if xdg_config_home && !xdg_config_home.empty?
        File.join(xdg_config_home, "nvim-mcp")
      else
        File.join(Dir.home, ".config", "nvim-mcp")
      end
    end
  end
end
