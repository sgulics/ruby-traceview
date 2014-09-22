# Copyright (c) 2014 AppNeta, Inc.
# All rights reserved.

if defined?(::Unicorn)
  Oboe.collector.register do
    report_kvs = {}

    if defined?(::Raindrops::Linux)
      # Here we retrieve any/all Unicorn listeners
      # and we report statistics for each.
      listeners = Unicorn.listener_names

      if listeners.is_a?(Array) && !listeners.empty?
        listeners.each_with_index do |listener_addr, i|
          stats = Raindrops::Linux.tcp_listener_stats([ listener_addr ])[ listener_addr ]
          report_kvs["listener#{i}_addr"] = listener_addr
          report_kvs["listener#{i}_queued"] = stats.queued
          report_kvs["listener#{i}_active"] = stats.active
        end
      end
    end

    report_kvs
  end
end
