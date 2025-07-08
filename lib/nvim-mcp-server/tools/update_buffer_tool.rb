module NvimMcpServer
  class UpdateBufferTool < BaseTool
    tool_name "update_buffer"

    description "Updates a buffer with new content provided by the MCP client, saves it to disk, and reloads it. This tool connects to a running Neovim instance, replaces the entire buffer content with the provided content, writes it to disk, and then reloads the buffer. This is useful for applying external changes (like from an AI assistant) to files open in Neovim."

    arguments do
      required(:project_name).filled(:string).description("The name of the project directory. This is used to locate the Neovim socket at /tmp/nvim-{project_name}.sock.")
      required(:file_path).filled(:string).description("The absolute or relative file path of the buffer to update. This should match the path as shown in Neovim's buffer list.")
      required(:content).filled(:string).description("The new content to write to the buffer. This will replace the entire current content of the buffer.")
    end

    def call(project_name:, file_path:, content:)
      socket_path = "/tmp/nvim-#{project_name}.sock"
      log(:info, "Updating buffer #{file_path} for project #{project_name} using socket #{socket_path}")

      result = {
        status: "success",
        project_name: project_name,
        socket_path: socket_path,
        file_path: file_path,
        updated: false,
        saved: false,
        reloaded: false
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

        # Get all buffers to find the one with the specified file
        all_buffers = client.list_bufs
        target_buffer = nil

        all_buffers.each do |buffer|
          buffer_name = buffer.name

          # Skip unnamed buffers
          next if buffer_name.nil? || buffer_name.empty?

          # Check if this buffer matches the file path (exact match or ends with the path)
          if buffer_name == file_path || buffer_name.end_with?(file_path)
            target_buffer = buffer
            result[:actual_path] = buffer_name
            break
          end
        end

        if target_buffer.nil?
          result[:status] = "error"
          result[:message] = "Buffer not found for file: #{file_path}"
          return result
        end

        # Store original content info
        original_line_count = target_buffer.line_count
        result[:original_line_count] = original_line_count

        # Find a window displaying this buffer or use the current window
        windows = client.list_wins
        target_window = windows.find { |win| win.buffer.number == target_buffer.number }

        if target_window
          # If we found a window with this buffer, switch to it
          client.set_current_win(target_window)
        else
          # Otherwise, load the buffer in the current window
          client.command("buffer #{target_buffer.number}")
        end

        # Split content into lines
        new_lines = content.split("\n")
        result[:new_line_count] = new_lines.length

        # Replace the entire buffer content
        # First, delete all existing lines
        target_buffer.lines = new_lines
        result[:updated] = true

        # Save the buffer to disk
        client.command("write")
        result[:saved] = true
        log(:info, "Saved updated buffer: #{result[:actual_path]}")

        # Reload the buffer to ensure it's in sync
        client.command("edit")
        result[:reloaded] = true

        result[:message] = "Successfully updated, saved, and reloaded buffer"

        # Close the connection
        client.shutdown
      rescue => e
        log(:error, "Error updating buffer in Neovim using socket #{socket_path}: #{e.message}")

        # Handle connection and other errors gracefully
        result[:status] = "error"
        result[:message] = e.message
        result[:updated] = false
        result[:saved] = false
        result[:reloaded] = false
      end

      result
    end
  end
end
