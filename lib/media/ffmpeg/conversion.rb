require_relative "process"

module Media
  module FFMPEG
    class Conversion

      attr_reader :command, :tracker

      def initialize(command, options = {})
        @command = ["ffmpeg", "-y"] + Array(command)
      end

      def call
        Process.new(command).call do |progress|
          yield progress if block_given?
        end
      end
    end
  end
end
