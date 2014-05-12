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
        while true do
          Oboe::API.start_trace('RubyGC', nil, { :ProcessName => Process.pid } ) do
            Oboe::API.log('RubyGC', 'metrics', ::GC.stat)
          end

          Oboe.logger.debug "GC collector run..."
          
          sleep @sleep_interval
        end
      end
    end
  end
end
