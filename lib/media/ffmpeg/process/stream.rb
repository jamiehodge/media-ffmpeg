module Media
  module FFMPEG
    class Process
      class Stream

        attr_reader :buffer, :io

        def initialize(io)
          @io     = io
          @buffer = ""
        end

        alias to_io io
        alias to_s buffer

        def read(length = 4096)
          io.read_nonblock(length).tap {|data| buffer << data}
        rescue IO::WaitReadable, EOFError, Errno::ECONNRESET
          buffer
        end
      end
    end
  end
end
