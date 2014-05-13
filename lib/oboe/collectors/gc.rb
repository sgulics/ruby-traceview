# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

module Oboe
  module Collectors
    class GC
      attr_accessor :sleep_interval

      def initialize
        @sleep_interval = Oboe::Config[:collectors][:gc][:sleep_interval]
      end

      def perform
        begin
          while true do
            Oboe::API.start_trace('RubyGC', nil, { :ProcessName => Process.pid } ) do
              Oboe::API.log('RubyGC', 'metrics', ::GC.stat)
            end

            Oboe.logger.debug "[oboe/debug] GC collector run..."
            
            sleep @sleep_interval
          end
        rescue StandardError => e
          Oboe.logger.warn "[oboe/warn] GC Collector exiting on exception: #{e.message}"
          raise
        end
      end
    end
  end
end

# Launch this collector on load
Oboe::CollectorThread.new(:gc) do
  Oboe::Collectors::GC.new.perform
end
