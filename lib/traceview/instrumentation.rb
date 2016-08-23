# Copyright (c) 2013 AppNeta, Inc.
# All rights reserved.

require 'yaml'

module TraceView
  ##
  # The Inst module holds all of the instrumentation extensions for various
  # libraries suchs as Redis, Dalli and Resque.
  module Inst
    ##
    # load_instrumentation
    #
    # This method simply loads all of the instrumentation files in
    # lib/traceview/inst/*.rb
    #
    def self.load_instrumentation
      # Load the general instrumentation
      pattern = File.join(File.dirname(__FILE__), 'inst', '*.rb')
      Dir.glob(pattern) do |f|
        begin
          require f
        rescue => e
          TraceView.logger.error "[traceview/loading] Error loading instrumentation file '#{f}' : #{e}"
          TraceView.logger.debug "[traceview/loading] #{e.backtrace.first}"
        end
      end
    end

    ##
    # load_custom_instrumentation
    #
    # Config file instrumentation (CFI) is stored in a YAML file such as 'traceview.yml'.
    # This method locates, loads and applies the specified instrumentation directives.
    #
    def self.load_custom_instrumentation
      # Locate the custom instrumentation file (if there is one)
      file = "#{Dir.pwd}/config/traceview.yml" if File.exist?("#{Dir.pwd}/config/traceview.yml")
      file = "#{Dir.pwd}/traceview.yml"        if File.exist?("#{Dir.pwd}/traceview.yml")
      #file = TV.custom_instrumentation_file    if File.exist?(File.custom_instrumentation_file)
      file = ENV['TV_INSTRUMENTATION_FILE']    if ENV['TV_INSTRUMENTATION_FILE'] && File.exist?(ENV['TV_INSTRUMENTATION_FILE'])

      if file
        TV.logger.debug "[traceview/loading] Found custom instrumentation file: #{file}"

        # Load YAML file
        ci = YAML.load(File.open(file))

        ci.keys.each do |cm|
          klass, method = cm.split('#')
          if ci[cm]['enabled']
            apply_custom_instrumentation(klass.constantize, method, ci[cm])
          end
        end
      else
        TraceView.logger.debug "[traceview/custom_instrumentation] Custom instrumentation file not found."
      end
    rescue => e
      TraceView.logger.warn "[traceview/custom_instrumentation] #{e.message}"
      TraceView.logger.debug e.backtrace.join("\n")
    end

    ##
    # apply_custom_instrumentation
    #
    #
    def self.apply_custom_instrumentation(klass, method, opts)
      TraceView::API.instrument_method(klass, method, opts)
    end
  end
end
