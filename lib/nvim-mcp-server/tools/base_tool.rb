module NvimMcpServer
  class BaseTool < FastMcp::Tool
    extend Forwardable

    def_delegators :NvimMcpServer, :log
  end
end
