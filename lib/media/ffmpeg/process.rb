require "open3"

require_relative "process/progress"
require_relative "process/result"
require_relative "process/stream"

module Media
  module FFMPEG
    class Process

      attr_reader :command, :resulter, :streamer, :tracker

      def initialize(command, options = {})
        @command  = Array(command)
        @resulter = options.fetch(:resulter) { Result }
        @streamer = options.fetch(:streamer) { Stream }
        @tracker  = options.fetch(:tracker)  { Progress }
      end

      def call
        stdin, stdout, stderr, wait_thread = Open3.popen3(*command)

        stdin.close
        stderr = streamer.new(stderr)

        progress = tracker.new

        while wait_thread.alive?
          read, _ = IO.select([stderr])
          read.each {|io| progress.parse(io.read) {|progress| yield progress }}
        end

        resulter.new(stderr.to_s, stdout.to_s, wait_thread.value)
      end
    end
  end
end
