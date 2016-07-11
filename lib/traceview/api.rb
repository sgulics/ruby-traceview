# Copyright (c) 2013 AppNeta, Inc.
# All rights reserved.

module TraceView
  ##
  # This module implements the TraceView tracing API.
  # See: https://github.com/appneta/ruby-traceview#the-tracing-api
  #
  module API

    def self.extend_with_tracing
      extend TraceView::API::Util
      extend TraceView::API::Logging
      extend TraceView::API::Tracing
      extend TraceView::API::Profiling
      extend TraceView::API::LayerInit
      extend TraceView::API::Instrument
    end

    ##
    # Load the traceview tracing API
    #
    def self.require_api
      pattern = File.join(File.dirname(__FILE__), 'api', '*.rb')
      Dir.glob(pattern) do |f|
        require f
      end

      begin
        TraceView::API.extend_with_tracing
      rescue LoadError => e
        TraceView.logger.fatal "[traceview/error] Couldn't load API: #{e.message}"
      end
    end
  end
end

TraceView::API.require_api
