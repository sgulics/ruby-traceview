# Copyright (c) 2013 AppNeta, Inc.
# All rights reserved.

module TraceView
  module API
    ##
    # Provides the higher-level tracing interface for the API.
    module Tracing
      # Public: Trace a given block of code. Detect any exceptions thrown by
      # the block and report errors.
      #
      # layer - The layer the block of code belongs to.
      # opts - A hash containing key/value pairs that will be reported along
      # with the first event of this layer (optional).
      # protect_op - specify the operation being traced.  Used to avoid
      # double tracing between operations that call each other
      #
      # Example
      #
      #   def computation(n)
      #     fib(n)
      #     raise Exception.new
      #   end
      #
      #   def computation_with_oboe(n)
      #     trace('fib', { :number => n }) do
      #       computation(n)
      #     end
      #   end
      #
      #   result = computation_with_oboe(1000)
      #
      # Returns the result of the block.
      def trace(layer, opts = {}, protect_op = nil)
        log_entry(layer, opts, protect_op)
        begin
          yield
        rescue Exception => e
          log_exception(layer, e)
          raise
        ensure
          log_exit(layer, {}, protect_op)
        end
      end

      # Public: Trace a given block of code which can start a trace depending
      # on configuration and probability. Detect any exceptions thrown by the
      # block and report errors.
      #
      # When start_trace returns control to the calling context, the oboe
      # context will be cleared.
      #
      # layer - The layer the block of code belongs to.
      # opts - A hash containing key/value pairs that will be reported along
      # with the first event of this layer (optional).
      #
      # Example
      #
      #   def handle_request(request, response)
      #     # ... code that modifies request and response ...
      #   end
      #
      #   def handle_request_with_oboe(request, response)
      #     result, xtrace = start_trace('rails', request['X-Trace']) do
      #       handle_request(request, response)
      #     end
      #     result
      #   rescue Exception => e
      #     xtrace = e.xtrace
      #   ensure
      #     response['X-trace'] = xtrace
      #   end
      #
      # Returns a list of length two, the first element of which is the result
      # of the block, and the second element of which is the oboe context that
      # was set when the block completed execution.
      def start_trace(layer, xtrace = nil, opts = {})
        log_start(layer, xtrace, opts)
        begin
          result = yield
        rescue Exception => e
          log_exception(layer, e)
          e.instance_variable_set(:@xtrace, log_end(layer))
          raise
        end
        xtrace = log_end(layer)

        [result, xtrace]
      end

      # Public: Trace a given block of code which can start a trace depending
      # on configuration and probability. Detect any exceptions thrown by the
      # block and report errors. Insert the oboe metadata into the provided for
      # later user.
      #
      # The motivating use case for this is HTTP streaming in rails3. We need
      # access to the exit event's trace id so we can set the header before any
      # work is done, and before any headers are sent back to the client.
      #
      # layer - The layer the block of code belongs to.
      # target - The target object in which to place the oboe metadata.
      # opts - A hash containing key/value pairs that will be reported along
      # with the first event of this layer (optional).
      #
      # Example:
      #
      #   def handle_request(request, response)
      #     # ... code that does something with request and response ...
      #   end
      #
      #   def handle_request_with_oboe(request, response)
      #     start_trace_with_target('rails', request['X-Trace'], response) do
      #       handle_request(request, response)
      #     end
      #   end
      #
      # Returns the result of the block.
      def start_trace_with_target(layer, xtrace, target, opts = {})
        log_start(layer, xtrace, opts)
        exit_evt = TraceView::Context.createEvent
        begin
          target['X-Trace'] = TraceView::Event.metadataString(exit_evt) if TraceView.tracing?
          yield
        rescue Exception => e
          log_exception(layer, e)
          raise
        ensure
          exit_evt.addEdge(TraceView::Context.get)
          log_event(layer, :exit, exit_evt)
          TraceView::Context.clear
        end
      end

      ##
      # Public: Trace a method on a class or module.  That method can be of any (accessible)
      # type (instance, singleton, private, protected etc.).
      #
      # klass  - the class or module that has the method to trace
      # method - the method to trace.  Can be singleton, instance, private etc...
      # opts   - a hash specifying the one or more of the following options:
      #   * :arguments  - report the arguments passed to <tt>method</tt> on each trace (default: false)
      #   * :result     - report the return value of <tt>method</tt> on each layer (default: false)
      #   * :backtrace  - report the return value of <tt>method</tt> on each layer (default: false)
      #   * :name       - alternate name for the layer reported in the dashboard (default: method name)
      #   * :extra_kvs  - a hash containing any additional KVs you would like reported with the layer
      #
      # Example
      #
      #   opts = {}
      #   opts[:backtrace] = true
      #   opts[:arguments] = false
      #   opts[:name] = :array_sort
      #
      #   TraceView::API.trace_method(Array, :sort, opts)
      #
      def trace_method(klass, method, opts = {}, extra_kvs = {})
        opts[:called_method] = __method__
        opts[:profile] = false
        instrument_method(klass, method, opts, extra_kvs)
      end
    end
  end
end
