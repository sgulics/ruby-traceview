# Copyright (c) 2016 SolarWinds, LLC.
# All rights reserved.

module TraceView
  module Inst
    module ConnectionAdapters
      module Utils

        def extract_trace_details(sql, name = nil, binds = [])
          opts = {}
          if TraceView::Config[:sanitize_sql]
            # Sanitize SQL and don't report binds
            opts[:Query] = TraceView::Util.sanitize_sql(sql)
          else
            # Report raw SQL and any binds if they exist
            opts[:Query] = sql.to_s
            opts[:QueryArgs] = binds.map { |col, val| [col.name, val.to_s] } unless binds.empty?
          end

          opts[:Name] = name.to_s if name
          opts[:Backtrace] = TraceView::API.backtrace if TraceView::Config[:active_record][:collect_backtraces]

          if ::Rails::VERSION::MAJOR == 2
            config = ::Rails.configuration.database_configuration[::Rails.env]
          else
            config = ActiveRecord::Base.connection.instance_variable_get(:@config)
          end

          if config
            opts[:Database]   = config['database'] if config.key?('database')
            opts[:RemoteHost] = config['host']     if config.key?('host')
            adapter_name = config[:adapter]

            case adapter_name
            when /mysql/i
              opts[:Flavor] = 'mysql'
            when /postgres/i
              opts[:Flavor] = 'postgresql'
            when /oracle_enhanced/i
              opts[:Flavor] = 'oracle_enhanced'
            end
          end
        rescue StandardError => e
          TraceView.logger.debug "Exception raised capturing ActiveRecord KVs: #{e.inspect}"
          TraceView.logger.debug e.backtrace.join('\n')
        ensure
          return opts
        end

        # We don't want to trace framework caches.  Only instrument SQL that
        # directly hits the database.
        def ignore_payload?(name)
          %w(SCHEMA EXPLAIN CACHE).include?(name.to_s) ||
            (name && name.to_sym == :skip_logging) ||
            name == 'ActiveRecord::SchemaMigration Load'
        end

        # def cfg
        #   @config
        # end

        def execute_with_traceview(sql, name = nil)
          if TraceView.tracing? && !ignore_payload?(name)

            opts = extract_trace_details(sql, name)
            TraceView::API.trace('activerecord', opts || {}) do
              execute_without_traceview(sql, name)
            end
          else
            execute_without_traceview(sql, name)
          end
        end

        def exec_query_with_traceview(sql, name = nil, binds = [])
          if TraceView.tracing? && !ignore_payload?(name)

            opts = extract_trace_details(sql, name, binds)
            TraceView::API.trace('activerecord', opts || {}) do
              exec_query_without_traceview(sql, name, binds)
            end
          else
            exec_query_without_traceview(sql, name, binds)
          end
        end

        def exec_delete_with_traceview(sql, name = nil, binds = [])
          if TraceView.tracing? && !ignore_payload?(name)

            opts = extract_trace_details(sql, name, binds)
            TraceView::API.trace('activerecord', opts || {}) do
              exec_delete_without_traceview(sql, name, binds)
            end
          else
            exec_delete_without_traceview(sql, name, binds)
          end
        end

        def exec_insert_with_traceview(sql, name = nil, binds = [], *args)
          if TraceView.tracing? && !ignore_payload?(name)

            opts = extract_trace_details(sql, name, binds)
            TraceView::API.trace('activerecord', opts || {}) do
              exec_insert_without_traceview(sql, name, binds, *args)
            end
          else
            exec_insert_without_traceview(sql, name, binds, *args)
          end
        end

        def exec_update_with_traceview(sql, name = nil, binds = [], *args)
          if TraceView.tracing? && !ignore_payload?(name)

            opts = extract_trace_details(sql, name, binds)
            TraceView::API.trace('activerecord', opts || {}) do
              exec_update_without_traceview(sql, name, binds, *args)
            end
          else
            exec_update_without_traceview(sql, name, binds, *args)
          end
        end

        def begin_db_transaction_with_traceview
          if TraceView.tracing?
            TraceView::API.trace('activerecord', :Query => 'BEGIN') do
              begin_db_transaction_without_traceview
            end
          else
            begin_db_transaction_without_traceview
          end
        end
      end # Utils
    end
  end
end
