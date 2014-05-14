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
            report_kvs = ::GC.stat
            report_kvs[:RubyVersion] = RUBY_VERSION

            Oboe::API.start_trace('RubyGC', nil, { :ProcessName => Process.pid } ) do
              Oboe::API.log('RubyGC', 'metrics', report_kvs)
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

if defined?(::GC::Profiler) and ::GC::Profiler.enabled?
  # Launch this collector on load
  Oboe::CollectorThread.new(:gc) do
    Oboe::Collectors::GC.new.perform
  end
end
