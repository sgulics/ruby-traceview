
module TraceView
  module MethodProfiling
    ##
    # instrument_wrapper
    #
    def instrument_wrapper(method, report_kvs, opts, *args, &block)
      report_kvs[:Backtrace] = TraceView::API.backtrace(2) if opts[:backtrace]
      report_kvs[:Arguments] = args if opts[:arguments]

      if opts[:profile]
        TraceView::API.log(nil, :profile_entry, report_kvs)
      else
        TraceView::API.log(opts[:name], :entry, report_kvs)
      end

      begin
        rv = self.send(method, *args, &block)
        report_kvs[:ReturnValue] = rv if opts[:result]
        rv
      rescue => e
        TraceView::API.log_exception(nil, e)
        raise
      ensure
        report_kvs.delete(:Backtrace)
        report_kvs.delete(:Controller)
        report_kvs.delete(:Action)
        if opts[:profile]
          TraceView::API.log(nil, :profile_exit, report_kvs)
        else
          TraceView::API.log(opts[:name], :exit, report_kvs)
        end
      end
    end
  end
end
