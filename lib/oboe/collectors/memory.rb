# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

module Oboe
  module Collectors
    class Memory
      attr_accessor :sleep_interval
      attr_accessor :time_to_exit

      def initialize
        @time_to_exit = false
        @sleep_interval = Oboe::Config[:collectors][:memory][:sleep_interval]
      end

      def perform
        begin
          while true do
            report_kvs = {}
            report_kvs[:ThreadCount] = Thread.list.count

            File.open("/proc/#{Process.pid}/status", "r").read_nonblock(4096) =~ /RSS:\s*(\d+) kB/i
            report_kvs[:VmRSS] = $1

            Oboe::API.start_trace('RubyMemory', nil, { :ProcessName => Process.pid } ) do
              Oboe::API.log('RubyMemory', 'metrics', report_kvs)
            end

            if @time_to_exit
              break
            else
              sleep @sleep_interval
            end
          end
        rescue StandardError => e
          Oboe.logger.warn "[oboe/warn] Memory collector exiting on exception: #{e.message}"
          raise
        end
      end
    end
  end
end

# Launch this collector on load
Oboe::CollectorThread.new(:memory) do
  Oboe::Collectors::Memory.new.perform
end

