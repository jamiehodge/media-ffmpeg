require "open3"

require_relative "process/progress"
require_relative "process/result"
require_relative "process/stream"

module Media
  module FFMPEG
    class Process

      attr_reader :command, :bufferer, :resulter, :tracker

      def initialize(command, options = {})
        @command  = Array(command)
        @bufferer = options.fetch(:bufferer) { Stream }
        @resulter = options.fetch(:resulter) { Result }
        @tracker  = options.fetch(:tracker)  { Progress }
      end

      def call(&block)
        stdin, stdout, stderr, wait_thread = Open3.popen3(*command)

        stdin.close
        stderr = bufferer.new(stderr)

        progress = tracker.new

        while wait_thread.alive?
          read, _ = IO.select([stderr])
          read.each {|io| progress.parse(io.handle_read, &block) }
        end

        resulter.new(stderr.read, stdout.read, wait_thread.value)
      end
    end
  end
end
