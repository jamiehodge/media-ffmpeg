require_relative "process"

module Media
  module FFMPEG
    class Conversion

      attr_reader :command, :tracker

      def initialize(command, options = {})
        @command = Array(command)
      end

      def self.call(*args, &block)
        new(*args).call(&block)
      end

      def call
        Process.new(command).call do |progress|
          yield progress if block_given?
        end
      end
    end
  end
end
