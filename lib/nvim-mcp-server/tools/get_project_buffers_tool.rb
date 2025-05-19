module NvimMcpServer
  class GetProjectBuffersTool < BaseTool
    tool_name "get_project_buffers"

    description "Retrieves a list of files currently open in Neovim that belong to a specific project. This tool connects to a running Neovim instance using its socket file at /tmp/nvim-{project_name}.sock and queries for all open buffers. It then filters the buffers to include only files that have the project name as part of their path. This is useful for determining what files a user is currently editing in a particular project, identifying areas of active development, or tracking work context across multiple files. The tool handles connection failures gracefully and returns complete absolute file paths."

    arguments do
      required(:project_name).filled(:string).description("The name of the project directory to filter buffers by. This should match a directory name in the file paths of the buffers you want to retrieve. For example, if your project is at '/home/user/projects/my-app', you would use 'my-app' as the project_name. The tool will also use this name to locate the Neovim socket at /tmp/nvim-{project_name}.sock.")
    end

    def call(project_name:)
      socket_path = "/tmp/nvim-#{project_name}.sock"
      log(:info, "Getting buffers for project #{project_name} using socket #{socket_path}")

      result = {
        status: "success",
        project_name: project_name,
        socket_path: socket_path,
        files: []
      }

      begin
        # Check if socket exists
        unless File.exist?(socket_path)
          result[:status] = "error"
          result[:message] = "Neovim socket not found: #{socket_path}"
          return result
        end

        # Connect to Neovim
        client = Neovim.attach_unix(socket_path)

        # Get all buffers
        all_buffers = client.list_bufs
        project_files = []

        all_buffers.each do |buffer|
          # Get buffer name (file path)
          buffer_name = buffer.name

          # Skip unnamed buffers
          next if buffer_name.nil? || buffer_name.empty?

          # Split the path into components
          path_parts = buffer_name.split(File::SEPARATOR)

          # Check if project_name appears in any part of the path
          if path_parts.include?(project_name)
            # Add the complete path to the results
            project_files << buffer_name
          end
        rescue => e
          # Log error but continue processing other buffers
          log(:error, "Error processing buffer: #{e.message}")
          next
        end

        # Sort the files for consistent output
        result[:files] = project_files.sort

        # Close the connection
        client.shutdown
      rescue => e
        log(:error, "Error connecting to Neovim using socket #{socket_path}: #{e.message}")

        # Handle connection and other errors gracefully
        result[:status] = "error"
        result[:message] = e.message
        result[:files] = []
      end

      result
    end
  end
end
