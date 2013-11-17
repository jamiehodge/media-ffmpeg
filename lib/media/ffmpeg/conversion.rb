require "media/process"

require_relative "progress"

module Media
  module FFMPEG
    class Conversion

      attr_reader :command, :tracker

      def initialize(command = [], options = {})
        @command = ["ffmpeg", "-y", *command]
        @tracker = options.fetch(:tracker) { Progress }
      end

      def call
        progress = tracker.new

        Process.new(command).call do |data|
          progress.parse(data) do |progress|
            yield progress if block_given?
          end
        end
      end
    end
  end
end
