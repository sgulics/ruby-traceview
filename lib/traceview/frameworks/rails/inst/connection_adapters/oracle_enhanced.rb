# Copyright (c) 2016 SolarWinds, LLC.
# All rights reserved.

module TraceView
  module Inst
    module ConnectionAdapters
      module FlavorInitializers
        def self.oracle_enhanced
          TraceView.logger.info '[traceview/loading] Instrumenting activerecord oracle_enhanced' if TraceView::Config[:verbose]

          TraceView::Util.send_include(::ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter,
                                  ::TraceView::Inst::ConnectionAdapters::Utils)


          # ActiveRecord 3.1 and above
          TraceView::Util.method_alias(::ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter, :exec_insert)
          TraceView::Util.method_alias(::ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter, :exec_update)
          TraceView::Util.method_alias(::ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter, :exec_query)
          TraceView::Util.method_alias(::ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter, :exec_delete)

        end
      end
    end
  end
end
