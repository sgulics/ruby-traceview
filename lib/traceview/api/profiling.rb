# Copyright (c) 2013 AppNeta, Inc.
# All rights reserved.

module TraceView
  module API
    ##
    # Module that provides profiling of arbitrary blocks of code
    module Profiling
      ##
      # Public: Profile a given block of code. Detect any exceptions thrown by
      # the block and report errors.
      #
      # profile_name - A name used to identify the block being profiled.
      # report_kvs - A hash containing key/value pairs that will be reported along
      #              with the event of this profile (optional).
      # with_backtrace - Boolean to indicate whether a backtrace should
      #                  be collected with this trace event.
      #
      # Example
      #
      #   def computation(n)
      #     TraceView::API.profile('fib', { :n => n }) do
      #       fib(n)
      #     end
      #   end
      #
      # Returns the result of the block.
      def profile(profile_name, report_kvs = {}, with_backtrace = false)
        report_kvs[:Language] ||= :ruby
        report_kvs[:ProfileName] ||= profile_name
        report_kvs[:Backtrace] = TraceView::API.backtrace if with_backtrace

        TraceView::API.log(nil, :profile_entry, report_kvs)

        begin
          yield
        rescue => e
          log_exception(nil, e)
          raise
        ensure
          exit_kvs = {}
          exit_kvs[:Language] = :ruby
          exit_kvs[:ProfileName] = report_kvs[:ProfileName]

          TraceView::API.log(nil, :profile_exit, exit_kvs)
        end
      end

      ##
      # Public: Profile a method on a class or module.  That method can be of any (accessible)
      # type (instance, singleton, private, protected etc.).
      #
      # klass  - the class or module that has the method to profile
      # method - the method to profile.  Can be singleton, instance, private etc...
      # opts   - a hash specifying the one or more of the following options:
      #   * :arguments  - report the arguments passed to <tt>method</tt> on each profile (default: false)
      #   * :result     - report the return value of <tt>method</tt> on each profile (default: false)
      #   * :backtrace  - report the return value of <tt>method</tt> on each profile (default: false)
      #   * :name       - alternate name for the profile reported in the dashboard (default: method name)
      # extra_kvs - a hash containing any additional KVs you would like reported with the profile
      #
      # Example
      #
      #   opts = {}
      #   opts[:backtrace] = true
      #   opts[:arguments] = false
      #   opts[:name] = :array_sort
      #
      #   TraceView::API.profile_method(Array, :sort, opts)
      #
      def profile_method(klass, method, opts = {}, extra_kvs = {})
        opts[:called_method] = __method__
        opts[:profile] = true
        instrument_method(klass, method, opts, extra_kvs)
      end
    end
  end
end
