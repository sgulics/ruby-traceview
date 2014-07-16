# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

module Oboe
  module Collectors
    class GC
      attr_accessor :sleep_interval
      attr_accessor :time_to_exit

      def initialize
        @time_to_exit = false
        @sleep_interval = Oboe::Config[:collectors][:gc][:sleep_interval]
      end

      def perform
        begin
          kvs = [ :count, :minor_gc_count, :major_gc_count, :total_time, :total_allocated_object,
                  :total_freed_object, :heap_live_slot, :heap_live_num, :heap_free_slot, :head_free_num ]

          while true do
            report_kvs = {}
            report_kvs[:RubyVersion] = RUBY_VERSION
            report_kvs[:total_time] = GC::Profiler.total_time

            report_kvs = ::GC.stat.select{ |k, v| kvs.include?(k) }

            Oboe::API.start_trace('RubyGC', nil, { 'Force' => true, :ProcessName => Process.pid } ) do
              Oboe::API.log('RubyGC', 'metrics', report_kvs)
            end

            if @time_to_exit
              break
            else
              sleep @sleep_interval
            end
          end
        rescue StandardError => e
          Oboe.logger.warn "[oboe/warn] GC collector exiting on exception: #{e.message}"
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
